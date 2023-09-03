local function toNumber(nStr)
    local n = tonumber(nStr)
    if type(n) ~= "number" then
        error(("The argument %s is not a valid number"):format(nStr))
    end

    return n
end

local function trySendToDiscord(title, message, footer)
    if Config.Webhook == "Webhook url" then
        return
    end

    local embed = {}
    embed = {
        {
            ["color"] = 65280, -- GREEN = 65280 --- RED = 16711680
            ["title"] = "**" .. title .. "**",
            ["description"] = "" .. message .. "",
            ["footer"] = {
                ["text"] = footer
            }
        }
    }

    PerformHttpRequest(Config.Webhook, function(err, text, headers)
    end, 'POST', json.encode({
        embeds = embed
    }), {
        ['Content-Type'] = 'application/json'
    })
end

local objects = {}

AddEventHandler("onResourceStop", function(name)
    if (name ~= GetCurrentResourceName()) then
        return
    end

    for _, netId in pairs(objects) do
        local handle = NetworkGetEntityFromNetworkId(netId)
        if DoesEntityExist(handle) then
            DeleteEntity(handle)
        end
    end

    print("All objects have been succesfully deleted")
end)

RegisterCommand("placeobject", function(source, args)
    if #args < 4 then
        error("Wrong placeobject command syntax: placeobject <x> <y> <z> <object_model>")
    end

    local x = toNumber(args[1])
    local y = toNumber(args[2])
    local z = toNumber(args[3])
    local model = args[4]

    local handle = CreateObjectNoOffset(joaat(model), x, y, z, true, false, false)
    local netId = NetworkGetNetworkIdFromEntity(handle)
    table.insert(objects, netId)

    local objectMessage = ("The object (ID: %s) has been succesfully placed!"):format(netId)
    trySendToDiscord("Object Create", ("%s\nName: %s\nPosition: %s, %s, %s"):format(objectMessage, model, x, y, z))
    print(objectMessage)
end, false)

RegisterCommand("deleteobject", function(source, args)
    if #args ~= 1 then
        error("Wrong deleteobject command syntax: deleteobject <object_net_id>")
    end

    local netId = toNumber(args[1])
    local handle = NetworkGetEntityFromNetworkId(netId)
    if not DoesEntityExist(handle) then
        error(("The entity for the net id %s does not exists"):format(netId))
    end

    DeleteEntity(handle)
    for index, _netId in pairs(objects) do
        if _netId == netId then
            table.remove(objects, index)
        end
    end

    local objectMessage = ("The object (ID: %s) has been succesfully deleted!"):format(netId)
    trySendToDiscord("Object Delete", objectMessage)
    print(objectMessage)
end, false)
