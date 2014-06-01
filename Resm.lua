-- Defaults
local Period = 10 -- in mins, 10 = 10min


local PricelistSupply = {}
local PricelistDemand = {}
local PricelistEq = {}
local Deallist = {}

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