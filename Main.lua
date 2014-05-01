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
  CalcMoves = function(mapmat, px, py, tx, ty)	-- Based on some code of LMelior but made it work and improved way beyond his code.
  --[[
  A* algorithm for LUA
  Ported to LUA by Altair
  21 septembre 2006
  --]]
  --[[ PRE:
  mapmat is a 2d array
  px is the player's current x
  py is the player's current y
  tx is the target x
  ty is the target y

  Note: all the x and y are the x and y to be used in the table.
  By this I mean, if the table is 3 by 2, the x can be 1,2,3 and the y can be 1 or 2.
  --]]

  --[[ POST:
  closedlist is a list with the checked nodes.
  It will return nil if all the available nodes have been checked but the target hasn't been found.
  --]]

    -- variables
    local openlist={}                 				-- Initialize table to store possible moves
    local closedlist={}						-- Initialize table to store checked gridsquares
    local listk=1                   				-- List counter
          local closedk=0                					-- Closedlist counter
    local tempH=math.abs(px-tx)+math.abs(py-ty)
    local tempG=0
    openlist[1]={x=px, y=py, g=0, h=tempH, f=0+tempH ,par=1}   	-- Make starting point in list
    local xsize=table.getn(mapmat[1]) 				-- horizontal map size
    local ysize=table.getn(mapmat)					-- vertical map size
    local curbase={}						-- Current square from which to check possible moves
    local basis=1							-- Index of current base

    -- Growing loop
    while listk>0 do

            -- Get the lowest f of the openlist
            local lowestF=openlist[listk].f
            basis=listk
      for k=listk,1,-1 do
            if openlist[k].f<lowestF then
               lowestF=openlist[k].f
                         basis=k
                end
      end

      closedk=closedk+1
      table.insert(closedlist,closedk,openlist[basis])

      curbase=closedlist[closedk]				 -- define current base from which to grow list

      local rightOK=true
      local leftOK=true           				 -- Booleans defining if they're OK to add
      local downOK=true             				 -- (must be reset for each while loop)
      local upOK=true

      -- Look through closedlist
      if closedk>0 then
          for k=1,closedk do
        if closedlist[k].x==curbase.x+1 and closedlist[k].y==curbase.y then
          rightOK=false
        end
        if closedlist[k].x==curbase.x-1 and closedlist[k].y==curbase.y then
          leftOK=false
        end
        if closedlist[k].x==curbase.x and closedlist[k].y==curbase.y+1 then
          downOK=false
        end
        if closedlist[k].x==curbase.x and closedlist[k].y==curbase.y-1 then
          upOK=false
        end
          end
      end
      
      -- Check if next points are on the map and within moving distance
      if curbase.x+1>xsize then
        rightOK=false
      end
      if curbase.x-1<1 then
        leftOK=false
      end
      if curbase.y+1>ysize then
        downOK=false
      end
      if curbase.y-1<1 then
        upOK=false
      end

      -- If it IS on the map, check map for obstacles
      --(Lua returns an error if you try to access a table position that doesn't exist, so you can't combine it with above)
      if curbase.x+1<=xsize and mapmat[curbase.y][curbase.x+1]~=0 then
        rightOK=false
      end
      if curbase.x-1>=1 and mapmat[curbase.y][curbase.x-1]~=0 then
        leftOK=false
      end
      if curbase.y+1<=ysize and mapmat[curbase.y+1][curbase.x]~=0 then
        downOK=false
      end
      if curbase.y-1>=1 and mapmat[curbase.y-1][curbase.x]~=0 then
        upOK=false
      end
      
      -- check if the move from the current base is shorter then from the former parrent
      tempG=curbase.g+1
      for k=1,listk do
          if rightOK and openlist[k].x==curbase.x+1 and openlist[k].y==curbase.y and openlist[k].g>tempG then
        tempH=math.abs((curbase.x+1)-tx)+math.abs(curbase.y-ty)
        table.insert(openlist,k,{x=curbase.x+1, y=curbase.y, g=tempG, h=tempH, f=tempG+tempH, par=closedk})
        rightOK=false
          end
      
          if leftOK and openlist[k].x==curbase.x-1 and openlist[k].y==curbase.y and openlist[k].g>tempG then
        tempH=math.abs((curbase.x-1)-tx)+math.abs(curbase.y-ty)
        table.insert(openlist,k,{x=curbase.x-1, y=curbase.y, g=tempG, h=tempH, f=tempG+tempH, par=closedk})
        leftOK=false
          end

          if downOK and openlist[k].x==curbase.x and openlist[k].y==curbase.y+1 and openlist[k].g>tempG then
        tempH=math.abs((curbase.x)-tx)+math.abs(curbase.y+1-ty)
        table.insert(openlist,k,{x=curbase.x, y=curbase.y+1, g=tempG, h=tempH, f=tempG+tempH, par=closedk})
        downOK=false
          end

          if upOK and openlist[k].x==curbase.x and openlist[k].y==curbase.y-1 and openlist[k].g>tempG then
        tempH=math.abs((curbase.x)-tx)+math.abs(curbase.y-1-ty)
        table.insert(openlist,k,{x=curbase.x, y=curbase.y-1, g=tempG, h=tempH, f=tempG+tempH, par=closedk})
        upOK=false
          end
        end

      -- Add points to openlist
      -- Add point to the right of current base point
      if rightOK then
        listk=listk+1
        tempH=math.abs((curbase.x+1)-tx)+math.abs(curbase.y-ty)
        table.insert(openlist,listk,{x=curbase.x+1, y=curbase.y, g=tempG, h=tempH, f=tempG+tempH, par=closedk})
      end

      -- Add point to the left of current base point
      if leftOK then
        listk=listk+1
        tempH=math.abs((curbase.x-1)-tx)+math.abs(curbase.y-ty)
        table.insert(openlist,listk,{x=curbase.x-1, y=curbase.y, g=tempG, h=tempH, f=tempG+tempH, par=closedk})
      end

      -- Add point on the top of current base point
      if downOK then
        listk=listk+1
        tempH=math.abs(curbase.x-tx)+math.abs((curbase.y+1)-ty)
        table.insert(openlist,listk,{x=curbase.x, y=curbase.y+1, g=tempG, h=tempH, f=tempG+tempH, par=closedk})
      end

      -- Add point on the bottom of current base point
      if upOK then
        listk=listk+1
        tempH=math.abs(curbase.x-tx)+math.abs((curbase.y-1)-ty)
        table.insert(openlist,listk,{x=curbase.x, y=curbase.y-1, g=tempG, h=tempH, f=tempG+tempH, par=closedk})
      end

      table.remove(openlist,basis)
      listk=listk-1

                  if closedlist[closedk].x==tx and closedlist[closedk].y==ty then
                     return closedlist
                  end
    end

    return nil
  end,
  CalcPath = function(closedlist)
  --[[ PRE:
  closedlist is a list with the checked nodes.
  OR nil if all the available nodes have been checked but the target hasn't been found.
  --]]

  --[[ POST:
  path is a list with all the x and y coords of the nodes of the path to the target.
  OR nil if closedlist==nil
  --]]

      if closedlist==nil then
         return nil
      end
     local path={}
     local pathIndex={}
     local last=table.getn(closedlist)
     table.insert(pathIndex,1,last)

     local i=1
     while pathIndex[i]>1 do
      i=i+1
      table.insert(pathIndex,i,closedlist[pathIndex[i-1]].par)
     end

     for n=table.getn(pathIndex),1,-1 do
         table.insert(path,{x=closedlist[pathIndex[n]].x, y=closedlist[pathIndex[n]].y})
       end

     closedlist=nil
     return path
  end
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


