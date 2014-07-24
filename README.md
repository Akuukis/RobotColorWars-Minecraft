# Welcome to Turtle Color Wars
Turtle Color Wars is a open-source project inside Minecraft's mod ComputerCraft to make Artificial Intelligence in Lua language for turtles where they independently sustain themselves, build bases, explore, reproduce, grow their own color colonies and fight other color colonies.

There will be "Official TuCoWa tournament" once every month where 16 participants will compete for a prize by improving and upgrading his colony's code on-the-fly in real-time. The AI above will be used as a default code that every participant will start with.

I want to make writing AIs and coding in general more fun and rewarding in a way that results are easier to see. I see ComputerCraft mod as a game-changer to accomplish this very easily inside Minecraft's environment.

# Contributing
During this "It is just started" phase you are welcome to contribute as you want and can to
* test,
* report bugs,
* solve and pull-requesting bugfixes,
* request new features in Github issues,
* join discussions of new features,
* build and pull-request accepted and missing features,
* join discussions of "Big questions" like Minimum mod requirements, Code conventions, etc. and draw attention to ones that hasn't been discussed yet,
* ask questions,
* write down documentation to Wiki, 
* keep documentation updated and add new answers to it,
* and update this list.

## How to test it?
* Start Minecraft with ComnputerCraft 1.63 and OpenPeripherials 0.4.1 mods enabled
* Run inside the turtle "pastebin run m1Tnt0wv"
* Press 2 (or something else, usually not everyone works but at least someone works)

To modify the code, I highly suggest to copy files to your own pastebin and take a look at "Loader" file how to execute them. Edit your pastebin, execute it and test it. Have fun!

# What is working?
Feel free to take any part of this code as long as the license & source credits are kept.
```lua
-- Credits to TuCoWa @ github.com/Akuukis/TurtleColorWars
```

### Coroutine Manager (~ 300 lines, located in Main.lua)
Coroutine Manager that can do several new things and is compatible with original ComputerCraft coroutines. Threads are now fully independent and can spawn new sister-level threads, pause and unpause them, kill them, whisper (exclusively send arguments) to them, ask (if target thread is prepared to answer to asks) them for arguments, exclusively set filters for them, dig (get) finished threads to get their returning values and get info about all active threads (like in Task Manager).

### Navigation (~ 600 lines, all Nav.lua)
It has A* based pathfinding that also supports 3D world, unexplored environment (and changes to environment), different weights for different blocks, tagging, multiple targets and different modes. And it builds his own map of the world and constantly updates it.

# License & Finances
The code is open-source and you are free to do anything you like with it, including making your own tournaments unless you call it "Official". And if you do something with it, it would be nice if you could share it or the results of it or whatever you find meaningful :)

At the beginning "Official TuCoWa tournament" will be financed by participation fees, where at least 50% will go to prize pool and at most 50% will be held for organizational expenses and distributed to top and/or key contributors. I hope that at some point in time there will be someone or something that will contribute financially to the tournament so that 100% of participation fees could go to prize pool, and even exceed 100% mark.
