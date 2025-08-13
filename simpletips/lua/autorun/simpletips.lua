-- SimpleTips configuration
local configPath = "data/simpletips/file"
local defaultConfig = {
    interval = 120,
    tips = {
        "Tip 1",
        "Tip 2",
        "Tip 3",
    },
}

-- Load configuration
local function loadConfig()
    if not file.Exists(configPath, "DATA") then
        file.Write(configPath, util.TableToJSON(defaultConfig, true))
        return defaultConfig
    end
    local data = file.Read(configPath, "DATA")
    local config = util.JSONToTable(data)
    if not config or type(config) ~= "table" or not config.interval or not config.tips then
        print("SimpleTips: Invalid configuration, addon disabled.")
        return nil
    end
    return config
end

local tipconfig = loadConfig()

-- Show tips regularly if configuration is valid
if tipconfig then
    local lastTip
    timer.Create("simpletips_timer", tipconfig.interval, 0, function()
        local Tip = table.Random(tipconfig.tips)
        if Tip == lastTip then
            Tip = table.Random(tipconfig.tips)
        end
        lastTip = Tip
        chat.AddText(Color(4, 109, 6), "[SimpleTips] ", Color(255, 255, 255), Tip)
    end)
end
