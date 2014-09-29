# Welcome to Robot Color Wars
> **Project is discontinued** until OpenComputers is ported to Minetest or other open-source alternative to Minecraft. 
> As you know, Minecraft is now owned by Microsoft. Because Microsoft is a money oriented company and has a bad reputation like leaking customer information to 3rd parties (Outlook backdoor) and suggesting misleading content for computer class programs in highschools (that should be called MS Office class, NOT general computer class), **I won't create content for Microsoft and also suggest you to turn to open-source alternatives**.

Robot Color Wars is a open-source project inside Minecraft's mod OpenComputers to make Artificial Intelligence in Lua language for robots where they independently sustain themselves, build bases, explore, reproduce, grow their own color colonies and fight other color colonies.

There will be "Official RoCoWa tournament" once every month where participants will compete for a prize by improving and upgrading his colony's code on-the-fly in real-time. The AI above will be used as a default code that every participant will start with.

I want to make writing AIs and coding in general more fun and rewarding in a way that results are easier to see. I see OpenComputers mod as a game-changer to accomplish this very easily inside Minecraft's environment.

# Contributing
During this "It is just started" phase mostly everything is coded by myself so I will be more than happy if you can help. You can contact me here on GitHub or you can also find me on IRC at irc.esper.net #OpenComputers and #OpenPrograms channels. You are welcome to contribute as you want to
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

To modify the code, I highly suggest to copy files to your own pastebin and take a look at "boot" file how to execute them. Edit your pastebin, execute it and test it. Have fun!

# What is working?

| [OPPM](https://github.com/OpenPrograms/Vexatos-Programs/tree/master/op-manager) name | Full name | Code | Documentation | Status |
|---|---|---|---|---|
| thread | Parallel Thread Manager | ~550 lines | ~500 lines | pre-release: expect to work |
| nav | Navigation | ~900 lines | ~350 lines | beta: expect to work, some bugs and missing features |

## Descriptions

### Parallel Thread Manager 

*Threads can spawn, manipulate, kill and do even more. Independent (doesn't need even OpenOS). Manual included.*

Any thread can sleep, filter, answer to requests and spawn, put to sleep, put filter, kill, gather return values, pause, unpause or send exclusive signals to any thread. Manual included at /usr/man. Bundled with simple console. Load & execute thread.manager(), all parameters are optional. See man/thread.demonstration for 'copy/paste' tour around library.

**Manage dynamic number of coroutines.** With `thread.spawn` you can spawn a new sister level thread. With `thread.kill` you can exclusively kill a sister level thread. Every thread has a property that at value 0 is unpaused and at positive value is paused, but negative values resets to 0, therefore `thread.unpause(threadUid, math.huge)` will effectively unpause anything.

**Compatibility with coroutine.yield().** With `thread.setFilter` you can set filter to any thread, for example for a thread you just spawned.

**Interact between coroutines.** With `thread.whisper` you can exclusively send arguments to a specific thread. When target thread is about to be resumed, it first resumes with first whispered arguments, then resumes again with next whispered arguments, ..., and lastly with event data from above as arguments if not filtered. Whispered arguments bypasses filters and alarm. With `thread.ask` you can ask values from a specific thread if it was readied correctly with `thread.setAnswer`. Pause and unpause other coroutines (therefore saving their state). Use `thread.pause` and `thread.unpause`

**Implement a task manager.** With `thread.getThreads` you can get info about all threads or `thread.getThread` will point to calling thread or return info about a specific thread. With `thread.setName` you can set human-friendly names for threads or use it to tag, group and filter coroutines. Get name with `thread.getName`

### Navigation ([Youtube video](https://www.youtube.com/watch?v=9P5eJZLDWl0))

*Use `go(coords)` to pathfind, go, map everything along the way and more. Independent (doesn't need even OpenOS). Manual included.*

Navigation library combines safe movement, pathfinding and world mapping into its core function go(). It is build with memory restrictions taken into account and aimed for general purpose use from solving little labyrinths to mapping and tagging whole regions. Pathfinding is bi-directional A* algorithm that supports 3D world, unexplored & changing map, multiple & weighted targets, weighted nodes, special tags, turning cost, succeeds even if runs into 'out-of-memory' few times during thinking, and lots of options are changable through extra flags.

**World mapping.** On every step and turn robot detects and saves the environment in a map that is organized in infinite chunks. (TODO!) Huge maps are stored in filesystem and only recently used chunks are loaded in RAM.

**Pathfinding.** Bi-directional A* algorithm that supports 3D world, unexplored & changing map, multiple & weighted targets, weighted nodes, special tags, turning cost, succeeds even if runs into "out-of-memory" few times during thinking, and lots of options are changable through extra flags. Use `m:go`

**Safe movement.** With `m:step` the library automatically checks for possible problems and solve them depending on options (or defaults) you pass to it.

**Compatible with thread library.** Compatible with Parallel Thread Library but not dependent on it.

**Compatible with OpenOS.** Compatible with OpenOS but not dependent on it.

**Multiple maps.** With advanced care you can have infinite maps as long you don't mess up. Create new objects with `nav:new`. Movement methods explore map for the object they are called upon. "Teleportion" happens with `m:setPos`. Manual map entries are created with `m:putMap` and `m:getMap`.

**Updates on-the-fly (TODO!)** If you get newer version of Navigation, you can use `nav = nav_NEW:update(nav); nav_NEW=nil` to preserve data and update methods.

# License
The code is open-source and you can feel free to use any part of this code as long as the original license and source credits are kept. 
```lua
-- Credits to RoCoWa @ github.com/Akuukis/RobotColorWars
-- Based upon RoCoWa @ github.com/Akuukis/RobotColorWars
-- Inspired by RoCoWa @ github.com/Akuukis/RobotColorWars
```

I reserve rights only on the name (and future logo) of the tournament, and you are free to organize your own tournaments unless you call it "Official". And if you do something with code or organize a tournament, it would be nice if you could share it or the results of it or whatever you find meaningful :)

# Official RoCoWa tournament

At the beginning "Official RoCoWa tournament" will be financed by participation fees, where at least 50% will go to prize pool and at most 50% will be held for organizational expenses and distributed to top and/or key contributors. I hope that at some point in time there will be someone or something that will contribute financially to the tournament so that 100% of participation fees could go to prize pool, and even exceed 100% mark.
