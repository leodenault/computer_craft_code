local lua_helpers = dofile("./gitlib/turboCo/lua_helpers.lua")

local class = lua_helpers.class

--- An interpreter of key events. It translates the events into turtle commands, specializing in
-- mining.
-- @param event_handler The event handler implementation which this class will use to register
-- itself as a key handler.
Miner = class({}, function(event_handler)
    local function end_mining()
        event_handler.setListening(false)
    end

    local key_mappings = {
        [keys.up] = turtle.forward,
        [keys.down] = turtle.back,
        [keys.left] = turtle.turnLeft,
        [keys.right] = turtle.turnRight,
        [keys.pageUp] = turtle.up,
        [keys.pageDown] = turtle.down,
        [keys.space] = turtle.dig,
        [keys.w] = turtle.digUp,
        [keys.s] = turtle.digDown,
        [keys.backspace] = end_mining,
    }

    local function call_mapped_key_handler(event_data)
        local handler = key_mappings[event_data[2]]
        if handler ~= nil then
            handler()
        end
    end

    --- Starts listening to key events and translates them into turtle commands as they arrive.
    local function start()
        event_handler.addHandle("key", call_mapped_key_handler)
        event_handler.pullEvents()
    end

    return {
        start = start,
    }
end)

return Miner
