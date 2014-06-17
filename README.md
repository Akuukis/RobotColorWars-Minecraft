TurtleColorWars
===============

Lua code for ComputerCraft to make ColorWars where coloured turtles explore, build bases, reproduce, grow into colonies and fight other coloured colonies.

How to check it out?
----------------
1. Start Minecraft with ComnputerCraft mod enabled
2. Run inside the turtle "pastebin run m1Tnt0wv"
3. Press 1 (or 2 or 3, usually not everyone works but at least someone works)
4. Fuel the turtle & have fun! ... execute Nav.Go({3,2,1},false,"Normal")

How to tinker with it?
----------------
1. I highly suggest to copy files to your own pastebin and take a look at "Loader" file how to execute them.
2. Edit your pastebin, execute it and test it. Have fun!

How to contribute?
----------------
1. Ask for documentation. We haven't wrote any because there are only few friends involved at the moment.
2. Branch the master.
3. Contact others and ask questions. 


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

