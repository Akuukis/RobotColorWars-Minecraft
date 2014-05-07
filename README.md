TurtleColorWars
===============

Lua code for ComputerCraft to make ColorWars where coloured turtles explore, build bases, reproduce and fight other colours. 

To check it out:
----------------
There's a Lua code around the web to download&run script straight from github!

To contribute:
----------------
First, set up for easy testing. For that I highly suggest to make a Pastebin account and make a paste for each file. Then make the program (see below) in turtle to pull & run it! Play around, show&share to friends, then improve something and branch it on github.

-- Start of code
-- Code (May 04, 2014) by LatvianModder
shell.run("delete PB_Test")
shell.run("pastebin get xxxxxxxx PB_Test/Main")
shell.run("pastebin get xxxxxxxx PB_Test/Nav")
shell.run("pastebin get xxxxxxxx PB_Test/Logger")
shell.run("pastebin get xxxxxxxx PB_Test/Jobs")
shell.run("pastebin get xxxxxxxx PB_Test/Utils")
shell.run("pastebin get xxxxxxxx PB_Test/Logic")
shell.run("pastebin get xxxxxxxx PB_Test/Gui")
shell.run("pastebin get xxxxxxxx PB_Test/Rui")
shell.run("pastebin get xxxxxxxx PB_Test/Hud")
shell.run("pastebin get xxxxxxxx PB_Test/Stats")
shell.run("pastebin get xxxxxxxx PB_Test/Comm")
shell.run("PB_Test/Main")
-- End of code

Versions:
----------------
ComputerCraft 1.63 uses **Luaj 2.0.3**, that is based on Lua 5.2.3
For out-of-minecraft debugging, consider this:
http://www.java2s.com/Code/Jar/l/Downloadluajjme203jar.htm
and run in the same dir "java -cp luaj-jse-2.0.3.jar lua test.lua"

Sidenotes & Debug trivia
----------------
nil = UndefinedVariable, but error()=UndefinedVariable.SubValue // Use pcall() if need to check.
table.insert(table,0,element) = table.insert(table,1,element) //
num ~= string, if num=tonumber(string) //

