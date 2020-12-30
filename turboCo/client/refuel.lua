local inventory = dofile("./gitlib/carlos/inventory.lua")
local json = dofile("./gitlib/turboCo/json.lua")
local modem = dofile("./gitlib/turboCo/modem.lua")
local movement = dofile("./gitlib/turboCo/movement.lua")

local protocol = "fuel_station"

local function connect()
    local server = rednet.lookup(protocol, "fuel_station_host")
    while not server do
        print("Can't connect to reful server, trying again")
        sleep(5)
        server = rednet.lookup(protocol)
    end
    return server
end

local function request_refuel(position)
    modem.openModems()

    local id = os.getComputerID()
    local server = connect()

    while true do
        local request = {}
        request["type"] = "refuel"
        request["position"] = position

        rednet.send(server, json.encode(request), protocol)

        local server_id, message = rednet.receive(protocol, 5)
        if server_id then
            local response = json.decode(message)

            if response["status"] == "success" then
                modem.closeModems()
                return response["position"]
            end
        end
    end
end

local function done_refuel()
    modem.openModems()

    local id = os.getComputerID()
    local server = connect()

    while true do
        local request = {}
        request["type"] = "refuel_done"

        rednet.send(server, json.encode(request), protocol)

        local server_id, message = rednet.receive(protocol, 5)
        if server_id then
            local response = json.decode(message)
            modem.closeModems()
            return
        end
    end
end

function refuel(position, facing)
    local start_pos = position
    local start_facing = facing
    local target = request_refuel(position)
    facing, position = movement.navigate(position, facing, target)
    turtle.suckDown(64)
    success = inventory.selectItemWithName("minecraft:coal")
            or inventory.selectItemWithName("minecraft:charcoal")
            or inventory.selectItemWithName("actuallyadditions:block_misc") --block of charcoal
    turtle.refuel()
    done_refuel()
    facing, position = movement.navigate(position, facing, start_pos)
    movement.turn_to_face(facing, start_facing)
end

return {
    refuel = refuel,
}
