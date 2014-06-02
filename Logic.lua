--[[ How it Works?

Work in Progress, nothing works! // Akuukis
based on Longterm/Shortterm coefficient and Risk factor. 

--]]

--Defaults
local function CollectTk(x) return x end
local function PrepareTk(x) return x end
local function PrepareStd(x) return -2*x end
local function InputStd(x) return -2*x end
local function OutputStd(x) return -2*x end
local function CollectStd(x) return -2*x end
local function Interest(x,y) return (1-y)/x end -- TODO


-- Variables
local Tk = 1 -- Short-term / Long-term coefficient
local Alt = {} -- table of alternatives

function UpdateTk()
	Tk = (turtle.getFuelLevel()/1000) ^ 2
end

function UpdateAlternatives()
	local Jobs = Job.GetJobs()
	for i in pairs(Jobs) do
		local SumCapital = 0
		local SumPrepare = 0
		local SumInput = 0
		local SumOutput = 0
		local SumCollect = 0
		local Capital = Job.GetCapital(i)
		local Prepare = Job.GetPrepare(i)
		local Input = Job.GetInput(i) -- per worktime in min
		local Output = Job.GetOutput(i) -- per worktime in min
		local Collect = Job.GetCollect(i)
		local WorkTime = Job.GetWorkTime(i)
		local FreeTime = Job.GetFreeTime(i)
		local Distance = Nav.GetDistance(Job.GetLocation(i))
		SumPrepare = SumPrepare + ( Resm.GetPriceSupply("Fuel") + Resm.GetPriceSupply("Time") ) * Distance
		for j in pairs(Capital) do SumCapital = SumCapital + Resm.GetPriceEq(Capital[j].Id) * Capital[j].Average * InputStd(Capital[j].std) end
		for j in pairs(Prepare) do SumPrepare = SumPrepare + Resm.GetPriceSupply(Prepare[j].Id) * Prepare[j].Average * PrepareStd(Prepare[j].std) end
		for j in pairs(Input) do SumInput = SumInput + Resm.GetPriceSupply(Input[j].Id) * Input[j].Average * InputStd(Input[j].std) end
		for j in pairs(Output) do SumOutput = SumOutput + Resm.GetPriceDemand(Output[j].Id) * Output[j].Average * OutputStd(Output[j].std) end
		for j in pairs(Collect) do SumCollect = SumCollect + Resm.GetPriceDemand(Collect[j].Id) * Collect[j].Average * CollectStd(Collect[j].std) end
		Alt[i] = {}
		Alt[i].Income = SumOutput + WorkTime * math.max(0, SumCollect / CollectTk(Tk))
		Alt[i].Cost = SumInput + WorkTime * ( SumPrepare / PrepareTk(Tk) + math.min(0, SumCollect / CollectTk(Tk)) + SumCapital * Interest(Tk, Job.GetRisk[i]) )
		Alt[i].Roi = (Alt[i].Income - Alt[i].Cost) / SumCapital
		Alt[i].MaxRot = (Alt[i].Income - Alt[i].Cost) / WorkTime
		Alt[i].MinRot = (Alt[i].Income - Alt[i].Cost) / (WorkTime + FreeTime)
	end
end

function UpdateTop()
	local Top = {Job = "Idle", Roi = 0}
	for i in pairs(Alt) do
		if Top.Roi < Alt[i].Roi then Top = Alt[i]; Top.Job = i; Alt[i] = {} end
	end
	return Top
end

function Think()
	while 1 do
		--Job.BuyFuel()
		UpdateTk()
		UpdateAlternatives()
		Resm.ClearMyDemand()
		local Top = {}
		local Demand = {}
		local i
		repeat
			i = i + 1
			Top[i] = UpdateTop()
			Demand = Utils.MergeTables(Job.GetCapital(Top[i].Job), Job.GetPrepare(Top[i].Job), Job.GetInput(Top[i].Job))
		until not Resm.AddDemand(Demand)
		if Resm.CloseDeal(Demand) then Job.Execute(Top[i].Job) end
	end
end









