TurtleColorWars
===============

Lua code for ComputerCraft to make ColorWars where turtles explore, build bases, reproduce and fight with each other. 

ComputerCraft 1.63 uses **Luaj 2.0.3**, that is based on Lua 5.2.3
For out-of-minecraft debugging, download this:
http://www.java2s.com/Code/Jar/l/Downloadluajjme203jar.htm
and run in the same dir "java -cp luaj-jse-2.0.3.jar lua test.lua"


Sidenotes & Debug trivia
----------------
nil = UndefinedVariable, but error()=UndefinedVariable.SubValue // Use pcall() if need to check.
table.insert(table,0,element) = table.insert(table,1,element) //