local TURTLE_MAX_FUEL = 20000

local tArgs = { ... }
if #tArgs ~= 1 then
	print( "Usage: excavate <diameter>" )
	return
end

-- Mine in a quarry pattern until we hit something we can't dig
local size = tonumber( tArgs[1] )
if size < 1 then
	print( "Excavate diameter must be positive" )
	return
end
	
local depth = 0
local unloaded = 0
local collected = 0

local xPos,zPos = 0,0
local xDir,zDir = 0,1

local goTo -- Filled in further down
local refuel -- Filled in further down

local function dumpCobblestoneStacks()
	for i=1,16 do
		local itemDetail = turtle.getItemDetail(i)
		if itemDetail ~= nil and itemDetail.name == "minecraft:cobblestone" and turtle.getItemSpace(i) == 0 then
			local selectedSlot = turtle.getSelectedSlot()
			turtle.select(i)
			turtle.drop()
			turtle.select(selectedSlot)
		end
	end
end

local function getBiggestFuelSlot()
  local biggestFuelCount = 0
  local biggestFuelSlot = 0 -- 0 means no fuel found yet
  for n=1,16 do
    turtle.select(n)
    if turtle.refuel(0) then
      local fuelCount = turtle.getItemCount()
      if fuelCount > biggestFuelCount then
        biggestFuelCount = fuelCount
        biggestFuelSlot = n
      end
    end
  end
  return biggestFuelSlot
end
 
local function unload( keepBiggestStack )
  print( "Unloading items..." )
  local biggestFuelSlot = getBiggestFuelSlot()
	for n=1,16 do
		local nCount = turtle.getItemCount(n)
		if nCount > 0 and n ~= biggestFuelSlot then
      turtle.select(n)
      turtle.drop()
      unloaded = unloaded + nCount
		end
	end
	collected = 0
	turtle.select(1)
end

local function returnSupplies(lowOnFuel)
	local x,y,z,xd,zd = xPos,depth,zPos,xDir,zDir
	print( "Returning to surface..." )
	goTo( 0,0,0,0,-1 )

	local refuelToLevel = nil
	if lowOnFuel then
		refuelToLevel = TURTLE_MAX_FUEL
	end
	if not refuel( refuelToLevel ) then
		unload( true )
    while not refuel( refuelToLevel ) do
      local fuelLevel = turtle.getFuelLevel()
      print(string.format("Waiting for fuel. Fuel level at %s. Needs %s.", fuelLevel, TURTLE_MAX_FUEL))
			os.pullEvent( "turtle_inventory" )
		end
	else
		unload( true )	
	end
	
	print( "Resuming mining..." )
	goTo( x,y,z,xd,zd )
end

local function collect()	
	local bFull = true
	local nTotalItems = 0
	for n=1,16 do
		local nCount = turtle.getItemCount(n)
		if nCount == 0 then
			bFull = false
		end
		nTotalItems = nTotalItems + nCount
	end
	
	if nTotalItems > collected then
		collected = nTotalItems
		if math.fmod(collected + unloaded, 50) == 0 then
			print( "Mined "..(collected + unloaded).." items." )
		end
	end
	
	if bFull then
		print( "No empty slots left." )
		return false
	end
	return true
end

function refuel( ammount )
	local fuelLevel = turtle.getFuelLevel()
	if fuelLevel == "unlimited" then
		return true
	end
	
  local needed = ammount or (xPos + zPos + depth + 2)
	if turtle.getFuelLevel() < needed then
		local fueled = false
		for n=1,16 do
			if turtle.getItemCount(n) > 0 then
				turtle.select(n)
				if turtle.refuel(1) then
					while turtle.getItemCount(n) > 0 and turtle.getFuelLevel() < needed do
						turtle.refuel(1)
					end
					if turtle.getFuelLevel() >= needed then
						turtle.select(1)
						return true
					end
				end
			end
		end
		turtle.select(1)
		return false
	end
	
	return true
end

local function tryForwards()
	if not refuel() then
		print( "Not enough Fuel" )
		returnSupplies(true)
	end
	while not turtle.forward() do
		if turtle.detect() then
			if turtle.dig() then
				--first try to dump extra cobble
				if not collect() then
					dumpCobblestoneStacks()
				end
				if not collect() then
					returnSupplies(false)
				end
			else
				return false
			end
		elseif turtle.attack() then
			--first try to dump extra cobble
			if not collect() then
				dumpCobblestoneStacks()
			end

			if not collect() then
				returnSupplies(false)
			end
		else
			sleep( 0.5 )
		end
	end
	
	xPos = xPos + xDir
	zPos = zPos + zDir
	return true
end

local function tryDown()
	if not refuel() then
		print( "Not enough Fuel" )
		returnSupplies(true)
	end
	
	while not turtle.down() do
		if turtle.detectDown() then
			if turtle.digDown() then
				--first try to dump extra cobble
				if not collect() then
					dumpCobblestoneStacks()
				end

				if not collect() then
					returnSupplies(false)
				end
			else
				return false
			end
		elseif turtle.attackDown() then
			--first try to dump extra cobble
			if not collect() then
				dumpCobblestoneStacks()
			end

			if not collect() then
				returnSupplies(false)
			end
		else
			sleep( 0.5 )
		end
	end

	depth = depth + 1
	if math.fmod( depth, 10 ) == 0 then
		print( "Descended "..depth.." metres." )
	end

	return true
end

local function turnLeft()
	turtle.turnLeft()
	xDir, zDir = -zDir, xDir
end

local function turnRight()
	turtle.turnRight()
	xDir, zDir = zDir, -xDir
end

function goTo( x, y, z, xd, zd )
	while depth > y do
		if turtle.up() then
			depth = depth - 1
		elseif turtle.digUp() or turtle.attackUp() then
			collect()
		else
			sleep( 0.5 )
		end
	end

	if xPos > x then
		while xDir ~= -1 do
			turnLeft()
		end
		while xPos > x do
			if turtle.forward() then
				xPos = xPos - 1
			elseif turtle.dig() or turtle.attack() then
				collect()
			else
				sleep( 0.5 )
			end
		end
	elseif xPos < x then
		while xDir ~= 1 do
			turnLeft()
		end
		while xPos < x do
			if turtle.forward() then
				xPos = xPos + 1
			elseif turtle.dig() or turtle.attack() then
				collect()
			else
				sleep( 0.5 )
			end
		end
	end
	
	if zPos > z then
		while zDir ~= -1 do
			turnLeft()
		end
		while zPos > z do
			if turtle.forward() then
				zPos = zPos - 1
			elseif turtle.dig() or turtle.attack() then
				collect()
			else
				sleep( 0.5 )
			end
		end
	elseif zPos < z then
		while zDir ~= 1 do
			turnLeft()
		end
		while zPos < z do
			if turtle.forward() then
				zPos = zPos + 1
			elseif turtle.dig() or turtle.attack() then
				collect()
			else
				sleep( 0.5 )
			end
		end	
	end
	
	while depth < y do
		if turtle.down() then
			depth = depth + 1
		elseif turtle.digDown() or turtle.attackDown() then
			collect()
		else
			sleep( 0.5 )
		end
	end
	
	while zDir ~= zd or xDir ~= xd do
		turnLeft()
	end
end

if not refuel() then
	print( "Out of Fuel" )
	return
end

print( "Excavating..." )

local reseal = false
turtle.select(1)
if turtle.digDown() then
	reseal = true
end

local alternate = 0
local done = false
while not done do
	for n=1,size do
		for m=1,size-1 do
			if not tryForwards() then
				done = true
				break
			end
		end
		if done then
			break
		end
		if n<size then
			if math.fmod(n + alternate,2) == 0 then
				turnLeft()
				if not tryForwards() then
					done = true
					break
				end
				turnLeft()
			else
				turnRight()
				if not tryForwards() then
					done = true
					break
				end
				turnRight()
			end
		end
	end
	if done then
		break
	end
	
	if size > 1 then
		if math.fmod(size,2) == 0 then
			turnRight()
		else
			if alternate == 0 then
				turnLeft()
			else
				turnRight()
			end
			alternate = 1 - alternate
		end
	end
	
	if not tryDown() then
		done = true
		break
	end
end

print( "Returning to surface..." )

-- Return to where we started
goTo( 0,0,0,0,-1 )
unload( false )
goTo( 0,0,0,0,1 )

-- Seal the hole
if reseal then
	turtle.placeDown()
end

print( "Mined "..(collected + unloaded).." items total." )