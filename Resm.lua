-- Resm API accounts for anything that is valuable from resources to imaginery "safety" points, thus it is The economy of turtles.

--[[ Dependencies
--]]
--[[ APIs
--]]
--[[ How does it work? 

Process: Exchange -- Add value by exchange. 
Goal: Build a lot Turtles! -- The only demand is a new turtle.
Optimization: Growth -- Decisions are made by maximizing Added value per period.

There are Valuables (Resources, Space, Points, Containers), 
there are entities (Turtles, Bases) that can own Valuables by holding them (mostly in Containers), 
there are entities (Turtles, Farms) that can make ("make"="exchange"="add value") Valuables.

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
...
--]=]
--[=[ (WiP!) Making. Jobs
--]=]


--[=[ Classes

Turtle = { Universal, Worker, Major, Computer, President }
Base = { Central, Proximity }
Farm = { Surface, Underground }
Valuables = { Resource, Space, Point, Container }

--]=]
--]]

-- Defaults
local Period = 600 -- in secs ( 600=10min, 3'600=1h, 86'400=1d, 604'800=1w, 1'814'400=3w=tournament lenght ) (tournament period = 3024 Periods)

-- Classes
local Pricelist = {}
do -- Pricelist.Supply[ResId][UniqId] = { Origin, Amount, Value, Date, Location }
end
do -- Pricelist.Demand[ResId][UniqId] = { Origin, Parent, Amount, SurplusValue, SurplusShareList, ChildrenList, Location }
end
do -- Pricelist.Exchange[ResId] = { [ModulusOfPeriod] = { AvgValue, AvgAmount }, AvgValue, AvgAmount } 
end



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

