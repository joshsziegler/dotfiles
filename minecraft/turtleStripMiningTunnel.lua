-- Strip mining turtle program.
 
--[[fuel must be placed in slot 15,
torches must be placed in slot 16.]]
 
-- Create the function for refueling
function checkFuel()
  if turtle.getFuelLevel() <= 10 then
    turtle.select(15)
    turtle.refuel(1)
    turtle.select(1)
  end --if
end --checkFuel()
 
-- Create the turnAround function
function turnAround()
  turtle.turnRight()
  turtle.turnRight()
end --turnAround()

-- Check block in front of us against black list of blocks we don't want (dirt, stone)
function blockValuable(name)
  if name == "minecraft:dirt" then return false
  elseif name == "minecraft:stone" then return false
  elseif name == "minecraft:cobblestone" then return false
  end
  return true
end

function mineValuableBlocks()
  -- check block in front of us
  local success, data = turtle.inspect()
  if success then 
    if blockValuable(data.name) then
      turtle.dig()
    end
  end

  -- check below us
  local success, data = turtle.inspectDown()
  if success then 
    if blockValuable(data.name) then
      turtle.digDown()
    end
  end

  -- check above us
  local success, data = turtle.inspectUp()
  if success then 
    if blockValuable(data.name) then
      turtle.digUp()
    end
  end

  -- check to the left
  turtle.turnLeft()
  local success, data = turtle.inspect()
  if success then 
    if blockValuable(data.name) then
      turtle.dig()
    end
  end

  -- check to the right
  turnAround()
  local success, data = turtle.inspect()
  if success then 
    if blockValuable(data.name) then
      turtle.dig()
    end
  end

  -- return to original facing
  turtle.turnLeft()
end

-- place torch every 10 blocks, using the 16th inventory slot
function placeTorch(dist)
  if (dist-1) % 10 == 0 then
    turtle.select(16)
    turnAround()
    turtle.place()
    turnAround()
    checkFuel()
  end --if
end

-- Dig start of tunnel branch every 3 blocks
function digStartOfBranch(branches, dist)
  if branches and (dist-1) % 3 == 0 then
    turtle.turnRight()
    turtle.dig()
    turnAround()
    turtle.dig()
    turtle.turnRight()
  end
end

 
-- Digs the tunnel for the given length
function tunnel(givenLength, branches, tmpMineValuableBlocks)
  for index = 1, givenLength do
    turtle.dig()
    turtle.forward() 
    turtle.digUp()

    if mineValuableBlocks then
      mineValuableBlocks()
    end

    -- create walkway if needed for player
    turtle.select(1)
    turtle.placeDown()

    digStartOfBranch(branches, index)
    placeTorch(index)
  end --for
 
-- Sends the turtle back to the start
    turtle.up()
    for index = 1,givenLength do
      turtle.back()
    end --for
    turtle.down()
end --tunnel()
 

-- Main script
local tArgs = { ... }
if #tArgs ~= 3 then
  print( "Usage: mine length branches mineValuableBlocks" )
  return
end

local length = tonumber( tArgs[1] )
if length < 1 then
  print( "length must be positive" )
  return
end

local branches = tArgs[2]
if branches == 'y' then
  branches = true 
elseif branches == 'n' then
  branches = false
else
  print("branches argument must be either 'y' or 'n'")
  return
end

local mineValuableBlocks = tArgs[3]
if mineValuableBlocks == 'y' then
  mineValuableBlocks = true 
elseif mineValuableBlocks == 'n' then
  mineValuableBlocks = false
else
  print("mineValuableBlocks argument must be either 'y' or 'n'")
  return
end

print("Starting tunnel of length " .. length)
checkFuel()
tunnel(length, branches, mineValuableBlocks)
print("The tunnel has been excavated!")