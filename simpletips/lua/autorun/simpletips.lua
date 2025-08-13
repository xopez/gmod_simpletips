--[[
	SimpleTips - Server sends config to clients
]]

if SERVER then
    util.AddNetworkString("SimpleTips_SendConfig")

    local defaultConfig = {
        interval = 120, -- seconds between tips
        tips = {
            "Tip 1",
            "Tip 2",
            "Tip 3",
        },
    }

    local configPath = "simpletips_config.json"

    local function loadOrCreateConfig()
        local configTable

        if file.Exists(configPath, "DATA") then
            configTable = util.JSONToTable(file.Read(configPath, "DATA"))
        end

        if
            not configTable
            or type(configTable.interval) ~= "number"
            or configTable.interval <= 0
            or type(configTable.tips) ~= "table"
            or #configTable.tips == 0
        then
            configTable = table.Copy(defaultConfig)
            file.Write(configPath, util.TableToJSON(configTable, false))
            print("[SimpleTips] Config file created or reset to default values.")
        end

        return configTable
    end

    local config = loadOrCreateConfig()
    local lastConfigJSON = util.TableToJSON(config, false)

    local function sendConfigToClient(ply)
        net.Start("SimpleTips_SendConfig")
        net.WriteUInt(config.interval, 16)
        net.WriteUInt(#config.tips, 16)
        for _, tip in ipairs(config.tips) do
            net.WriteString(tip)
        end
        net.Send(ply)
    end

    hook.Add("PlayerInitialSpawn", "SimpleTips_SendConfigOnJoin", function(ply)
        sendConfigToClient(ply)
    end)

    -- check every 10 seconds for changes
    timer.Create("SimpleTips_CheckConfig", 10, 0, function()
        local newConfig = loadOrCreateConfig()
        local newJSON = util.TableToJSON(newConfig, false)

        if newJSON ~= lastConfigJSON then
            config = newConfig
            lastConfigJSON = newJSON
            print("[SimpleTips] Config changed – sent to all players.")
            for _, ply in ipairs(player.GetAll()) do
                sendConfigToClient(ply)
            end
        end
    end)
end

if CLIENT then
    local tipconfig = {}

    net.Receive("SimpleTips_SendConfig", function()
        tipconfig.interval = net.ReadUInt(16)
        local tipCount = net.ReadUInt(16)
        tipconfig.tips = {}
        for i = 1, tipCount do
            table.insert(tipconfig.tips, net.ReadString())
        end

        -- Start timer only after config arrives
        if timer.Exists("simpletips_timer") then
            timer.Remove("simpletips_timer")
        end

        if #tipconfig.tips > 0 then
            local index = math.random(#tipconfig.tips)
            timer.Create("simpletips_timer", tipconfig.interval, 0, function()
                chat.AddText(
                    Color(4, 109, 6),
                    "[SimpleTips] ",
                    Color(255, 255, 255),
                    tipconfig.tips[index]
                )
                index = (index % #tipconfig.tips) + 1
            end)
        end
    end)
end
