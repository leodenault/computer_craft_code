local EventHandler = dofile("./gitlib/turboCo/event/eventHandler.lua")

local radar = peripheral.find("radar")
if not radar then
  error("connect a radar.")
end
local chatBox = peripheral.find("chat_box")
if not chatBox then
  error("connect a chatBox.")
end
local RADAR_APPROX_DOOR_DISTANCE = 4.6

if not chatBox.getName() then
  chatBox.setName("PartyHouse")
end

local function greetPlayer(playerName)
  if playerName == "Corpsefire03" then
    chatBox.say(string.format("Welcome home, %s", playerName))
  else
    chatBox.say(string.format("Welcome to the party house, %s", playerName))
  end
end

local function handleRestone(eventData)
  local plateActivated = rs.getInput("top")
  if plateActivated then
    local closestPlayer = nil
    local closestDistance = 999999
    for _,player in ipairs(radar.getPlayers()) do
        local distanceToRadar = math.abs(player.distance - RADAR_APPROX_DOOR_DISTANCE)
        if distanceToRadar < closestDistance then
          closestDistance = distanceToRadar
          closestPlayer = player
        end
    end
    if closestPlayer then
      greetPlayer(closestPlayer.name)
      print(string.format("greeting player: \"%s\" with distance to plate: \"%s\". distance to radar: \"%s\"", closestPlayer.name, closestDistance, closestPlayer.distance))
    end
  end
end

local eventHandler = EventHandler.create()
eventHandler.addHandle("redstone", handleRestone)
eventHandler.pullEvents()