NAME
  nav.go

CALLS
  nav:go([table pos or poslist][, table optionlist]) 
  
RETURNS
  boolean ok[, errMsg]

DESCRIPTION
  Uses pathfinding with given options to go to position pos or nearest pos from poslist.
  See nav.options and nav.convention for more info on arguments.

EXAMPLES 
  m = nav:new()
  m:go() -- go to coords 0,0,0 with default options
  m:go({2,3,0}) -- goes to position 2 blocks north and 3 blocks east
  m:go({2,3,0,2}) -- the same but at the end turns to face south
  m:go({2,3,0},{"careful","euclidean"}) -- the same but with other options
  m:go({{2,3,0},{0,0,4}}) -- goes to position pathfinding thinks is the nearest. On hitting obstacle target may change to another position from poslist.
  