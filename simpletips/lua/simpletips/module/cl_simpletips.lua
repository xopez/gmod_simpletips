--[[
	SimpleTips Configuration
]]--

local tipconfig = tipconfig or {}

tipconfig.interval = 120
tipconfig.tips = {
	"Tip 1",
	"Tip 2",
	"Tip 3"
}

--[[
	End SimpleTips Configuration
]]--

timer.Create("simpletips_timer", tipconfig.interval, 0, function()
	local lastTip
	local Tip = table.Random(tipconfig.tips)
	if Tip == lastTip then
		Tip = table.Random(tipconfig.tips)
	end
	lastTip = Tip
	chat.AddText( Color( 4, 109, 6 ), "[SimpleTips] ", Color( 255, 255, 255), Tip )
end)