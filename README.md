Concept:

The idea here is to control your TiVo with Siri. For a lot of commands, this is really silly. For example, to pause or play, you say "tivo pause" or "tivo play". Then, after Siri has connected to the Apple server, interpreted your response, and sent it back, siriproxy intercepts it, I connect to your TiVo using TiVo's Network Remote protocol and send the "pause" or "play" commands. Your TiVo will then pause or play. This takes several seconds and is much less efficient than using your remote, but it's kind of fun (and you don't have to have possession of the remote).

Given that, the one thing I don't like about TiVo (and I _love_ TiVo!) is text entry for searches. This is where this plugin shines. You simply say "tivo search 'some show'", and it does all the dirty work for you. When it's done, you should have the show at the top of your list on the search screen, and you can proceed from there using your remote.

Installation:

IMPORTANT! Make sure you have enabled TiVo's Network Remote capabilities first. You can do this from "Messages & Settings > Settings > Remote > Network Remote Control". Set it to "Enabled". This plugin won't work unless this setting is enabled.

Next, copy config-info.yml into ~/.siriproxy/config.yml (don't just replace it). Modify the "host:" value to the IP address of your TiVo. If you don't know how to find this, Google it. I'm not implementing Bonjour or anything fancy like that yet, so you'll just have to enter it manually. Don't forget to change it if your TiVo uses DHCP and the IP changes. If you've got this far, it shouldn't be a problem. The "delay" and "short_delay" parameters represent the number of seconds the program will wait between sending keystrokes to the TiVo (short_delay is used only on the search screen). You can tweak these parameters if your TiVo isn't responding properly, but I make no guarantees.

Commands:

There are two basic modes: command mode and search mode. If you say "tivo search ____", it will go to the show search and look for what you said. Don't bother saying anything except words and numbers. Everything else will be stripped out, along with "the " at the beginning of any search.

If you say "tivo ____", it will relay that command directly to the TiVo, with a couple of modifications. If you say "tivo xxx", where "xxx" is a number, it will change the channel to that number. Use leading zeroes (e.g., "007" instead of "7") to make sure Siri parses the channel as digits. Otherwise, the complete list of commands is as follow:

How it works:

TiVo supports a limited set of commands to control it over a TCP/IP network (assuming you have Network Remote enabled). It listens on port 31339. The full protocol is described here: http://www.tivo.com/assets/images/abouttivo/resources/downloads/brochures/TiVo_TCP_Network_Remote_Control_Protocol_073108.pdf

With this protocol, you can do things like Up, Down, Select, etc. Pretty much whatever the remote can do. However, it's a stateless protocol, meaning it doesn't keep track of where you are each time you connect. As a result, to get to anywhere specific, you have to start fresh each time. In the case of search, you have to navigate the specific screen, and once you get to the search screen, you have to figure out how to get to each letter. It's sort of like guiding a blind man through a maze (e.g., right 3, down 2, select, etc.).

To do:

Maybe add Bonjour to discover your TiVo's IP automatically.

Do other types of searches (e.g., YouTube).

Create complete vocabulary for TiVo Network Remote protocol. Right now, certain commands will not be interpreted correctly by Siri, and thus can't be passed through to the TiVo.

Please send suggestions or bug reports to mrmosconi@gmail.com.

Here's a list of all the commands. You should be able to figure out which ones can't yet be processed:

UP
DOWN
LEFT
RIGHT
SELECT
TIVO
LIVETV
THUMBSUP
THUMBSDOWN
CHANNELUP
CHANNELDOWN
RECORD
DISPLAY
DIRECTV
NUM0
NUM1
NUM2
NUM3
NUM4
NUM5
NUM6
NUM7
NUM8
NUM9
ENTER
CLEAR
PLAY
PAUSE
SLOW
FORWARD
REVERSE
STANDBY
NOWSHOWING
REPLAY
ADVANCE
DELIMITER
GUIDE
INFO
STOP
WINDOW


TiVo is a registered trademark of TiVo Inc.
