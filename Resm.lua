--------------------------------------------------------------------------------------------------------------------------------
--[[------------ Descriptions of function calls --------------------------------------------------------------------------------
-- Resm API accounts for anything that is valuable from resources to imaginery "safety" points, thus it is The economy of turtles.
WiP
--]]
--------------------------------------------------------------------------------------------------------------------------------
---------------- Dependencies --------------------------------------------------------------------------------------------------
-- Name Section: 
-- Declare the name library will use. Leave it alone and
local Lib = {}
if type(Resm) == "table" then Lib = Resm end
Resm = Lib

-- Import Section:
-- declare everything this library needs from outside
-- FYI You can change or shorten names if you wish so.

---- Luaj unmodified libraries. Import only needed sub-functions.
-- Full list (functions): assert, collectgarbage, error, _G, ipairs, load, loadstring, next, pcall, rawequal, rawget, rawset, select, setfenv, setmetatable, tonumber, tostring, unpack, _VERSION, xpcall, require, module
-- Full list (tables): coroutine, package, table, math
-- local 
-- local

---- CC libraries. Import only needed sub-functions.
-- Full list (modified Luaj functions): getfenv, getmetatable, loadfile, dofile, print, type, string.sub, string.find, write
-- Full list (modified Luaj tables): string, os, io
-- Full list (new tables): os, colors, disk, gps, help, keys, paintutils, parallel, peripheral, rednet, term, textutils, turtle, vector, window
-- local 
-- local
-- local

---- TuCoWa libraries. Import only needed sub-functions.
-- Full list: Gui, Rui, Hud, Logger, Stats, Comm, Utils, Nav, Jobs, Resm, Logic, Init
local Gui, Rui, Hud, Logger, Stats, Comm, Utils, Nav, Jobs = Gui, Rui, Hud, Logger, Stats, Comm, Utils, Nav, Jobs

-- no more external access after this point
setfenv(1, Lib)

--------------------------------------------------------------------------------------------------------------------------------
---------------- Library wide variables ----------------------------------------------------------------------------------------

local Period = 600 -- in secs ( 600=10min, 3'600=1h, 86'400=1d, 604'800=1w, 1'814'400=3w=tournament lenght ) (tournament period = 3024 Periods)

--------------------------------------------------------------------------------------------------------------------------------
---------------- Classes -------------------------------------------------------------------------------------------------------



--------------------------------------------------------------------------------------------------------------------------------
---------------- Public functions ----------------------------------------------------------------------------------------------

function GetPriceSupply() end
function AddSupply() end
function ClearSupply() end

function GetPriceDemand() end
function AddDemand() end
function ClearDemand() end
function ClearMyDemand() end

function GetPriceEq() end
function CloseDeal() end

function ReserveDemand() end
function CollectDemand() end
function ClosePeriod() end -- resets Deallist

--------------------------------------------------------------------------------------------------------------------------------
---------------- Private functions ---------------------------------------------------------------------------------------------

-- none

--------------------------------------------------------------------------------------------------------------------------------
---------------- Details & Notes -----------------------------------------------------------------------------------------------

--[[ How does it work? 

Process: Exchange -- Add value by exchange. 
Goal: Build a lot Wonders! -- The only demand is a new turtle.
Optimization: Growth -- Decisions are made by maximizing Added value per period.

There are Valuables (Resources, Space, Points, Containers, Time) that can be used (otherwise they Depreciate)
there are Entities (Turtles, Bases) that can own Valuables by holding them (mostly in Containers), 
there are Entities (Turtles, Farms) that can make ("make"="exchange"="add value") Valuables and Entities.

--[=[ Value & Amount

Value is measured in "virtual cookies". Resources and Points can be exchanged for a given value, but Resources and Space can be lended for a given interest (value/time). Valuables have a dynamic value that is assigned according to its demand and supply. 

	There is always a demand for a brand new main turtle for 1'000'000 cookies. Demand value is calculated like in the following example. Lets suppose that Resource Fuel has a supply value of 20, Resource "Coal" has a Demand value of 800, and it can be acquired by Job "Burn Wood". In Job #1 description says that for 1 Coal there is needed 10+20 fuel and 1 Wood. Because fuel has a price (20), the unallocated value is 800-20*(10+20) = 200, therefore the Demand value for Resource "Wood" becomes 200. Demand is virtual (heurestic) and may not be accurate but is the best we have.

	Supply value is determined at the point of production. Supply value is calculated simply as a sum of input Supply value divided by amount outputted. Bear in mind that Supply value used in decision making is heurestic and thus may deviate from real Supply value used for Exchange value. If there is more than 1 type of item outputted, then the values are distributed proportionally to Demand values. Supply value lags in time but lets say that we are ok with that.
	
	Exchange value is determined at the point of exchange. Sum of Exchange values is proportionally between sum of Demand values and sum of Supply values. For statistics and heurestics it is advised to use Exchange value. Fun Fact: we can say that parties negotiated for a middle price to evenly and honestly distribute the Added value. What a perfect free market economy!
	
Amount is measured in items/mB/1RFs for Resources, in blocks for Space and in "grams" for Points. Demand and Supply always comes in Amount, and there may be different combinations of Demand/Supply and Amount at the same time per each Valuable.

	Amount Demanded is simply the Amount of Valuable that has been demanded. If Amount Demanded can be satisfied with Amount Supplied then the deal closes, both Amount Demanded and Amount Supplied are cleared and written into statistics and heurestics. If Amount Demanded is not satisfied, then it hangs and waits to be cleared by either someone Supplying it or by creator cancelling it. If turtle or base demands more than once, then both Demands are combinded in a complex way (simply: not by sum, but by max).
	
	Amount of Supply is either a present Supply or a future Supply. Present Supply is ready to be taken and depreciates over time (by paying rent to the owner of Container). Future Supply needs to be waited for but doesn't depreciates over time, yet.
	
	Amount cleared is the Amount that was successfully exchanged.

--]=]
--[=[ (WiP!) Owning. Interest & depreciation rate 

Interest rate is valuation of opportunity cost for other Entities for not being able to use the Valuable. Any Entity that has reserved a Valuable exchanges it's future Added Value for value of Interest rate for a given time period in future.
 
Depreciation is valuation of rent for Container or Space for its holder. Valuables that lays in Containers or Space for a long time will depreciate a lot of value away, thus will be cheaper until a point where someone will be ready to buy it (or discard if value manages to go into negative). 

	Example: Lets say that we have a base with some infrastructure (computer, wires, defence, etc.) with a chest that holds bucklet that holds water. The base has a lot of Valuables reserved (all of its infrastructure) therefore it has to pay interest of, lets say, 100c per period (100c/p). It collects exchangable value from renting out Space to its 0 farms and 4 chests (1 chest is double sized), and each chest relative to its space occupied has to transfer 100c/p together, or 20c/p each (or 40c/p for double-sized one). Our chest has to transfer value for rent of 20c/p, therefore it collects it from its contents relative to its space occupied (stack of 1 transfers the same amount as stack of 64 together). Lets say that chest holds our water bucklet, 2 full stacks of cobblestone and 1 sole cobblestone. The sole cobblestone has to transfer 5c/p, therefore it depreciates by 5c/p until it reaches 0, but the full stack of cobblestone depreciates by 5c/p altogether or by 0.078c/p each cobblestone. The bucklet of water also has to transfer 5c/p, but it has content, therefore it doesn't depreciate but collects it from it's contents first. The only content is water so the water will depreciate 5c/p. If water reacher value 0, then bucklet cannot collect transferable value anymore so it will start to depreciate itself.

Owning chains can be like this, everything optional except TheEverything and Resource: 
TheEverything, Base, Farm, Inventory, Bag, Bag, Bag, ..., Container, Resource.

	TheEverything has all the placeable blocks in the world. Base, Farm and Turtle is a bunch of blocks, Turtle always is exactly 1 block and that is a Inventory. Bag is like "Bag of Holding", that is a inventory within inventory. Container is something like bucklet, energy cell or compressed cobblestone. Resource is the resource within Container, Inventory or placed as a single block. Resources may stack within Containers and Inventories. If Resource are dropped in TheEverything, its considered deleted and don't register in the Resm, but individual Jobs may take drops into account (like collection saplings in tree farms).
	
--]=]
--[=[ (WiP!) Making. Jobs
--]=]
--[=[ Classes

Turtle = { Universal, Worker, Major, Computer, President }
Base = { Central, Proximity }
Farm = { Surface, Underground }
Valuables = { Resource, Space, Point, Container, Time }

--]=]
--]]



