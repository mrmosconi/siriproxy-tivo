require 'net/telnet'

class SiriProxy::Plugin::Tivo < SiriProxy::Plugin
	attr_accessor :host, :delay, :short_delay

	def initialize(config = {})
		self.host = config["host"]
		self.delay = config["delay"]
		self.short_delay = config["short_delay"]
	end

	listen_for /tivo search (.*)/i do |show|
		error = tivoSearch(show)
		say "I'm sorry, a problem occurred connecting to your TiVo" if error < 0
		request_completed
	end

	listen_for /tivo (.*)/i do |command|
		tivoCommand(command)
		request_completed
	end

def tivoSearch(show)
	delay = self.delay
	begin
		tivo = Net::Telnet::new("Host" => self.host, "Timeout" => 10, "Telnetmode" => false, "Port" => 31339)
	rescue
		return -1 #some sort of connection error
	end
	tivo.puts "TELEPORT TIVO" #go directly to main TiVo screen
	sleep(delay*2) #sometimes it takes a while to get to the home screen
	tivo.puts "IRCODE DOWN" #Watch Live TV
	sleep(delay)
	tivo.puts "IRCODE DOWN" #Find Programs
	sleep(delay)
	tivo.puts "IRCODE SELECT"
	sleep(delay)
	#make sure we're at top 'Find Programs' (7 "ups" at most)
	(1..7).each { tivo.puts "IRCODE UP" }
	sleep(delay)
	tivo.puts "IRCODE SELECT" #select "Search by Title"
	sleep(delay*2) #sometimes sluggish
	tivo.puts "IRCODE SELECT" #select "All programs"
	sleep(delay*2) #now we're at the search screen
	do_search(show, tivo)
	res = tivo.waitfor(/^[A-Z]/) { |c| print c } #echo socket response (diag)
	tivo.close #shut down TCP conn to TiVo
	return 0
end

def tivoCommand(command)
	command.upcase! #all commands are uppercase
	tivo = Net::Telnet::new("Host" => self.host, 
			"Timeout" => 10, "Telnetmode" => false, "Port" => 31339)
	thisCommand = ''
	digit = command.scan(/\d+/)
	if digit[0].to_i > 0
		thisCommand = "FORCECH " + digit[0]
	else
		thisCommand = "IRCODE " + command
	end
	tivo.puts(thisCommand)
	tivo.close
	return 0
end

#search routine. Intercepts "tivo search ____"
#first parameter is whatever you were searching for; second is TCP
#connection to your TiVo
def do_search(searchTerm, tivo)
	return unless searchTerm #ignore empty searches
	say 'Continue with your TiVo remote'
	term = searchTerm.dup
	term.downcase! #convert to lowercase (simplify processing)
	term.sub!(/^the /,"") #get rid of "The " at the start of any searches
	term.gsub!(/[^a-z0-9 ]/,"") #get rid of non-TiVo-search chars
	term += '@' # add our EOF char (possible special processing at end)
	#need to navigate the TiVo search screen, using only UP DOWN LEFT RIGHT
	#this is a row/column map of the screen, which looks as follows:
	#
	#DEL SPC CLR
	#A B C D
	#E F G H
	#I J K L
	#M N O P
	#Q R S T
	#U V W X
	#Y Z 0 1
	#2 3 4 5
	#6 7 8 9
	#
	#no need to map the DEL or CLR keys, but the others are mapped here
	
	keys = { 
		'a' => { 'row' => 1, 'col' => 0 },
		'b' => { 'row' => 1, 'col' => 1 },
		'c' => { 'row' => 1, 'col' => 2 },
		'd' => { 'row' => 1, 'col' => 3 },
		'e' => { 'row' => 2, 'col' => 0 },
		'f' => { 'row' => 2, 'col' => 1 },
		'g' => { 'row' => 2, 'col' => 2 },
		'h' => { 'row' => 2, 'col' => 3 },
		'i' => { 'row' => 3, 'col' => 0 },
		'j' => { 'row' => 3, 'col' => 1 },
		'k' => { 'row' => 3, 'col' => 2 },
		'l' => { 'row' => 3, 'col' => 3 },
		'm' => { 'row' => 4, 'col' => 0 },
		'n' => { 'row' => 4, 'col' => 1 },
		'o' => { 'row' => 4, 'col' => 2 },
		'p' => { 'row' => 4, 'col' => 3 },
		'q' => { 'row' => 5, 'col' => 0 },
		'r' => { 'row' => 5, 'col' => 1 },
		's' => { 'row' => 5, 'col' => 2 },
		't' => { 'row' => 5, 'col' => 3 },
		'u' => { 'row' => 6, 'col' => 0 },
		'v' => { 'row' => 6, 'col' => 1 },
		'w' => { 'row' => 6, 'col' => 2 },
		'x' => { 'row' => 6, 'col' => 3 },
		'y' => { 'row' => 7, 'col' => 0 },
		'z' => { 'row' => 7, 'col' => 1 },
		'0' => { 'row' => 7, 'col' => 2 },
		'1' => { 'row' => 7, 'col' => 3 },
		'2' => { 'row' => 8, 'col' => 0 },
		'3' => { 'row' => 8, 'col' => 1 },
		'4' => { 'row' => 8, 'col' => 2 },
		'5' => { 'row' => 8, 'col' => 3 },
		'6' => { 'row' => 9, 'col' => 0 },
		'7' => { 'row' => 9, 'col' => 1 },
		'8' => { 'row' => 9, 'col' => 2 },
		'9' => { 'row' => 9, 'col' => 3 },
		'@' => { 'row' => 0, 'col' => 4 } #internal EOF
}
	row = 1 #TiVo starts search at 'A' in the second row
	col = 0
	term.each_char {|c| 
		if c == ' ' #deal with the space key separately
			tivo.puts 'IRCODE FORWARD'
		else
			row_change = keys[c]['row'] - row
			col_change = keys[c]['col'] - col
			if row_change > 0
				(0...row_change).each { tivo.puts 'IRCODE DOWN' }
			elsif row_change < 0
				(row_change...0).each { tivo.puts 'IRCODE UP' }
			end
			if col_change > 0
				(0...col_change).each { tivo.puts 'IRCODE RIGHT' }
			elsif col_change < 0
				(col_change...0).each { tivo.puts 'IRCODE LEFT' }
			end
			tivo.puts 'IRCODE SELECT' unless c == '@' #don't select at end
			sleep short_delay #give keyboard a chance to catch up
			row = keys[c]['row']
			col = keys[c]['col']
		end
	}
end
end
