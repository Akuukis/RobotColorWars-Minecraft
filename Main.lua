--[[ Header
ColorWars algorithm for LUA
Authors: Akuukis, Hugo, LatvianModder, TomsG
Started: May 1, 2014
First Beta release: -
First Alpha release: -
Github address: https://github.com/Akuukis/TurtleColorWars
--]]
--[[Structure
Main - Starts Init. and afterwards runs Job,Supp,Comm in paralel. Subclasses Nav,Debug,Stats are present.
Init.## Initiation - Initiates the turtle so it could operate
Job.### Decision Making - Turtle weights alternatives, chooses his next AIM (strategy level) and does it (tactical level)
Supp.## Maintance - Turtle's AIM can be interrupted by inside events, like low on fuel, full backpack or afraid of night. Overrides AIM & does it.
Comm.## Communication - Turtle's AIM can be interrupted by outside events, like call for help or direct command. Sets AIM & does Job##.
Nav.### Navigation - Turtle goes to point XYZ (sub-tactical level) and constantly updates internal map.
Debug.# Debug - (sub-tactical level)
Stats.# Statistics - Turtle collents & stores individual statistics for fun purposes only.
--]]

Supp = {
  Refuel = function(self)
    if turtle.refuel()then 
      write("Refueled!\n")
      else 
      write("Fuel me!\n")
      end
    end
  }
Nav = {
  SurfaceMove = function(self)
    Debug:Hugo(x,y)
    if turtle.forward() then
      while turtle.detectDown()~=true do
        if turtle.down() then z=z-1 end
        end
      Stats:Step()
      if dir%4==0 then x=x+1 end
      if dir%4==1 then y=y+1 end
      if dir%4==2 then x=x-1 end
      if dir%4==3 then y=y-1 end
      else
      while turtle.detect() do
        if turtle.up() then z=z+1 end
        end
      end
    end,
  GetLost1 = function(self)
    for i=0,math.random(3,5) do
      write("GetLost No." .. i .. ": ")
      for j=0,math.random(0,3) do
        turtle.turnRight()
        dir=dir+1
        end
      write("Turned to " .. dir%4 .. ", ")  
      for j=0,math.random(5,10) do
        Nav:SurfaceMove()
        end
      write("Went " .. Stats:GetCountedSteps() .. "sq\n")
      Stats:ResetCountedSteps()
      end
    end,
  GoToStupid = function(self)
    write("I am at (" .. x .. "," .. y .. "). Going home!\n")
    turtle.up()
    turtle.down()
    if y<0 then
      while dir%4~=1 do
        turtle.turnRight()
        dir=dir+1
        end
      while y<0 do Nav:SurfaceMove() end
      end
    if y>0 then
      while dir%4~=3 do
        turtle.turnRight()
        dir=dir+1
        end
      while y>0 do Nav:SurfaceMove() end
      end
    if x<0 then
      while dir%4~=0 do
        turtle.turnRight()
        dir=dir+1
        end
      while x<0 do Nav:SurfaceMove() end
      end
    if x>0 then
      while dir%4~=2 do
        turtle.turnRight()
        dir=dir+1
        end
      while x>0 do Nav:SurfaceMove() end
      end
    write("I am home!\n")
    end,
  }
Debug = {
  Hugo = function(self, x, y)
    modem.transmit(3, 1337, x.." "..y)
    end
  }
Stats = {
  GlobalSteps = 0,
  CountedSteps = 0,
  Step = function(self, x)
    x = x or 1 -- create object if user does not provide one
    Stats.GlobalSteps = Stats.GlobalSteps + 1
    Stats.CountedSteps = Stats.CountedSteps + 1
    end,
  GetGlobalSteps = function(self)
    return Stats.GlobalSteps
    end,
  GetCountedSteps = function(self)
    return Stats.CountedSteps
    end,
  ResetCountedSteps = function(self)
    Stats.CountedSteps = 0
    end
  }

dir=0
x=0
y=0
z=0
modem = peripheral.wrap("left")

Supp:Refuel()
Nav:GetLost1()
Nav:GoToStupid()
 

