# Welcome to Robot Color Wars
Robot Color Wars is a open-source project inside Minecraft's mod OpenComputers to make Artificial Intelligence in Lua language for robots where they independently sustain themselves, build bases, explore, reproduce, grow their own color colonies and fight other color colonies.

There will be "Official RoCoWa tournament" once every month where participants will compete for a prize by improving and upgrading his colony's code on-the-fly in real-time. The AI above will be used as a default code that every participant will start with.

I want to make writing AIs and coding in general more fun and rewarding in a way that results are easier to see. I see OpenComputers mod as a game-changer to accomplish this very easily inside Minecraft's environment.

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
* Start Minecraft 1.7.10 with OpenComputers 1.3.2 (for testing we use [these mods](https://www.dropbox.com/sh/up2tbxepsdw38vv/AAAkkdKuUFM7CsZu5oNUNaxNa))
* Make robot with internet card, 
* Run inside the robot "pastebin run DvZXGEGh 2"
* Press 2 (or something else, usually not everyone works but at least someone works)

To modify the code, I highly suggest to copy files to your own pastebin and take a look at "boot" file how to execute them. Edit your pastebin, execute it and test it. Have fun!

# What is working?
Feel free to use any part of this code as long as the license & source credits are kept.
```lua
-- Credits to RoCoWa @ github.com/Akuukis/RobotColorWars
-- Based upon RoCoWa @ github.com/Akuukis/RobotColorWars
-- Inspired by RoCoWa @ github.com/Akuukis/RobotColorWars
```

You can also find those libraries in [OPPM](https://github.com/OpenPrograms/Vexatos-Programs/tree/master/op-manager).

### Parallel Thread Manager 
~ 550 code lines at lib/parallel.lua and ~500 documentation lines at usr/man/parallel*
Coroutine Manager that can do several new things and is compatible with OpenComputer coroutine.yield(). Threads are now fully independent and can spawn new sister-level threads, pause and unpause them, kill them, whisper (exclusively send arguments) to them, ask (if target thread is prepared to answer to asks) them for arguments, exclusively set filters for them, dig (get) finished threads to get their returning values and get info about all active threads (like a Task Manager).

### Navigation 
~ 900 code lines at lib/nav.lua and ~100 (WIP!) documentation lines at usr/man/nav*
It is replacement for robot.forward and a A* based pathfinder that also supports 3D world, unexplored environment (and changes to environment), different weights for different blocks, tagging, multiple targets and different modes. And it builds his own map of the world and constantly updates it.

# License & Finances
The code is open-source and you are free to do anything you like with it. I reserve rights only on the name (and future logo) of the tournament, and you are free to organize your own tournaments unless you call it "Official". And if you do something with code or organize a tournament, it would be nice if you could share it or the results of it or whatever you find meaningful :)

At the beginning "Official RoCoWa tournament" will be financed by participation fees, where at least 50% will go to prize pool and at most 50% will be held for organizational expenses and distributed to top and/or key contributors. I hope that at some point in time there will be someone or something that will contribute financially to the tournament so that 100% of participation fees could go to prize pool, and even exceed 100% mark.
