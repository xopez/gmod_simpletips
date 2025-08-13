--[[
	SimpleTips - Single File Version with Config in /data + Detailed Validation
]]
--

local defaultConfig = {
    interval = 120, -- seconds between tips
    tips = {
        "Tip 1",
        "Tip 2",
        "Tip 3",
    },
}

local configFile = "simpletips_config.json"
local tipconfig = table.Copy(defaultConfig)
local enabled = true

-- Validation function
local function validateConfig(cfg)
    if type(cfg) ~= "table" then
        return false, "Config is not a table."
    end
    if type(cfg.interval) ~= "number" or cfg.interval <= 0 then
        return false, "'interval' must be a positive number."
    end
    if type(cfg.tips) ~= "table" or #cfg.tips == 0 then
        return false, "'tips' must be a non-empty table."
    end
    for i, tip in ipairs(cfg.tips) do
        if type(tip) ~= "string" or tip == "" then
            return false, ("Tip at index %d is not a valid non-empty string."):format(i)
        end
    end
    return true
end

-- Load config from /data
local function loadConfig()
    if file.Exists(configFile, "DATA") then
        local content = file.Read(configFile, "DATA")
        local loaded = util.JSONToTable(content)
        local valid, reason = validateConfig(loaded)
        if valid then
            tipconfig = loaded
        else
            print("[SimpleTips] Invalid config detected! Tips have been disabled.")
            print("[SimpleTips] Reason: " .. tostring(reason))
            print("[SimpleTips] Expected format:")
            print(util.TableToJSON(defaultConfig, true))
            enabled = false
        end
    else
        file.Write(configFile, util.TableToJSON(defaultConfig, true))
        print("[SimpleTips] Default config created at /data/" .. configFile)
    end
end

loadConfig()

-- Client-side tip loop
if CLIENT and enabled then
    local tipCount = #tipconfig.tips
    if tipCount > 0 then
        local index = math.random(tipCount) -- random start
        timer.Create("simpletips_timer", tipconfig.interval, 0, function()
            chat.AddText(
                Color(4, 109, 6),
                "[SimpleTips] ",
                Color(255, 255, 255),
                tipconfig.tips[index]
            )
            index = (index % tipCount) + 1
        end)
    end
end
