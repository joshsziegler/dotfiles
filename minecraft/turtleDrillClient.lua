-- Minecraft - Turtle - Drill down to bedrock and return to surface
local rednetProtocol = "ZigMT"
local wirelessModemPos = "right"
local pauseMining = false
local quit = false
local status = {
  name = os.getComputerLabel(),
  status = "OK", -- OK or ERR
  lastMessage = "Initializing...",
  drillLevel = 50, -- level the drill should use as the "top"
  originalFacing = nil,
  face = nil,
  xPos = nil,
  yPos = nil,
  zPos = nil,
  calibrated = false
}

function log(msg)
  status.lastMessage = msg
  print(msg)
  saveStatus()
end

function logError(msg)
  status.lastMessage =  msg
  status.status = "ERR"
  print("Error: " .. msg)
  saveStatus()
end

function statusOK()
  status.status = "OK"
end

function saveStatus()
  local file = fs.open("drillStatus", "w") -- overwrites old file
  local data = textutils.serialize(status)
  file.write(data)
  file.close()
end

function loadStatus()
  local file = fs.open("drillStatus", "r") -- returns nil if doesn't exist
  if not file then
    return false
  end
  data = file.readAll()
  status = textutils.unserialize(data)
  return true
end


function InitialSetup()
  log("Initial Manual Setup")
  print("Facing (noth, east, south, west): ")
  status.face = read()
  status.originalFacing = status.face
  print("X Position: ")
  status.xPos = read()
  print("Y Position: ")
  status.yPos = read()
  print("Z Position: ")
  status.zPos = read()
  print("Desired Mine Height (50): ")
  status.drillLevel = read()

  status.calibrated = true
  log("Initial Manual Setup Complete")
  saveStatus()
end

function PauseMining(pause)
  if pause then
    log("Mining Paused")
    pauseMining = true
  else
    pauseMining = false
    log("Mining Resumed")
  end
end

function ReturnToOriginalFacing()
  log("Returning to original facing")
  -- useful for recovering from chunk load/unload or server restart
  while status.face ~= status.originalFacing do
    right()
  end
end

-- Reliable Turtle code by SpeedR
-- http://www.computercraft.info/wiki/Robust_Turtle_API

function reliableDig()
  local tries = 0
  while turtle.detect() do
    turtle.dig()
    sleep(0.4)
    tries = tries + 1
    if tries>500 then
      logError("Error: dug for too long.")
      return false
    end
  end
  return true
end

function reliableDigUp()
  local tries = 0
  while turtle.detectUp() do
    turtle.digUp()
    sleep(0.4)
    tries = tries + 1
    if tries>500 then
      logError("Error: dug up for too long.")
      return false
    end
  end
  return true
end

-- GPS Self-Tracker code by Latias1290
-- http://www.computercraft.info/wiki/Turtle_GPS_self-tracker_expansion_(tutorial)

function forward() -- go forward
  if status.calibrated ~= true then
    logError("Cannot Move: Not Calibrated.")
    return false
  end

  if turtle.forward() ~= true then
    return false  
  end

  if status.face == "north" then
    status.zPos = status.zPos - 1
  elseif status.face == "west" then
    status.xPos = status.xPos - 1
  elseif status.face == "south" then
    status.zPos = status.zPos + 1
  elseif status.face == "east" then
    status.xPos = status.xPos + 1
  end
  saveStatus()
  return true
end

function back() -- go back
  if status.calibrated ~= true then
    logError("Cannot Move: Not Calibrated.")
    return false
  end

  if turtle.back() ~= true then
    return false
  end

  if status.face == "north" then
    status.zPos = status.zPos + 1
  elseif status.face == "west" then
    status.xPos = status.xPos + 1
  elseif status.face == "south" then
    status.zPos = status.zPos - 1
  elseif status.face == "east" then
    status.xPos = status.xPos - 1
  end
  saveStatus()
  return true
end

function up() -- go up
  if status.calibrated ~= true then
    logError("Cannot Move: Not Calibrated.")
    return false
  end

  if turtle.up() ~= true then
    return false
  end  
  status.yPos = status.yPos + 1
  saveStatus()
  return true
end

function down() -- go down
  if status.calibrated ~= true then
    logError("Cannot Move: Not Calibrated.")
    return false
  end

  if turtle.down() ~= true then
    return false
  end
  status.yPos = status.yPos - 1
  saveStatus()
  return true
end

function turnAround()
  right()
  right()
end

function right()
  if status.calibrated ~= true then
    logError("Cannot Move: Not Calibrated.")
    return false
  end

  turtle.turnRight()
   if status.face == "north" then
    status.face = "east"
   elseif status.face == "east" then
    status.face = "south"
   elseif status.face == "south" then
    status.face = "west"
   elseif status.face == "west" then
    status.face = "north"
   end
   saveStatus()
end

function left()
  if status.calibrated ~= true then
    logError("Cannot Move: Not Calibrated.")
    return false
  end

  turtle.turnLeft()
  if status.face == "north" then
    status.face = "west"
  elseif status.face == "west" then
    status.face = "south"
   elseif status.face == "south" then
    status.face = "east"
   elseif status.face == "east" then
    status.face = "north"
   end
   saveStatus()
end

-- Check block in front of us against black list of blocks we don't want (dirt, stone)
function blockValuable(name)
  if name == "minecraft:dirt" then return false
  elseif name == "minecraft:stone" then return false
  elseif name == "minecraft:cobblestone" then return false
  elseif name == "minecraft:gravel" then return false
  elseif name == "minecraft:sand" then return false  
  elseif name == "minecraft:grass" then return false
  elseif name == "chisel:diorite" then return false
  elseif name == "chisel:andesite" then return false
  elseif name == "chisel:limestone" then return false
  elseif name == "chisel:granite" then return false
  end
  return true
end

-- mine block in front of us if it is valuable
function mineValuableBlock()
  local success, data = turtle.inspect()
  if success then 
    if blockValuable(data.name) then
      turtle.dig()
    end
  end
end
 
-- Digs down until we reach bed rock 
function drillDown()
  log("Drilling down to bedrock.. ")
  local depth = 0
  turtle.digDown()

  while down() do
    depth = depth + 1 -- change this to use location and desired height!
    mineValuableBlock()
    right()
    mineValuableBlock()
    right()
    mineValuableBlock()
    right()
    mineValuableBlock()

    turtle.digDown()
  end
  log("drilled down " .. depth .. " blocks")
 
  -- Sends the turtle back to the start/desired drilling level
  for index = 2,status.drillLevel do
    while not up() do
      logError("Cannot return to surface (blocked)")
      turtle.attackUp() -- if it's a mob
      turtle.digUp()    -- if it's sand/gravel
      sleep(0.4)
    end
  end --for    

  ReturnToOriginalFacing()
end 

-- Assumes there is an Ender chest in slot 1, which we place in front of us and then dump all of our inventory in it
-- picking up the chest after we are done
function dumpInventoryInChest()
  log("Dumping inventory into Ender Chest")

  while turtle.detect() do
    turtle.dig()    -- if it's a block 
    turtle.attack() -- it it's a mob
  end
  turtle.select(1)
  turtle.place() -- assumes the block in front of us is ok
  for slot=2, 16 do
    turtle.select(slot)
    turtle.drop()
  end
  -- pick Ender Chest back up
  turtle.select(1)
  turtle.dig()
end

-- Move forward 5 blocks, which efficiently covers a space in drill holes without checking any blocks twice
function moveToNextDrillLocation()
  log("Moving to next drill location")
  -- try to move forward, there may be something in front of us however, so dig it out
  
  local i = 0
  while i<5 do
    if not reliableDig() then 
      return false
    end
    if not reliableDigUp() then
      return false
    end
    forward()
    i = i + 1
  end
  return true
end 

function BroadcastStatusForever()
  while not quit do
    rednet.broadcast(status, rednetProtocol)
    sleep(1.0)
  end
end

function RednetRecvForever()
    while not quit do
        senderId, message, rednetProtocol = rednet.receive(rednetProtocol)
        if type(message) == "boolean" then
          -- pauseMining command from server
          if message ~= pauseMining then
            PauseMining(message)
          end
        end 
    end
end

function MineForever()
  while not quit do
    if turtle.getFuelLevel() < 130 then
      logError("Out of Fuel")
      return
    end

    while pauseMining do
      -- this is a server directive to pause a the top of the drill site
      sleep(1.0)
    end
    drillDown()
    dumpInventoryInChest() 

    if not moveToNextDrillLocation() then
      logError("Failed to move to next drill position")
      return 
    end

  end
end

function KeyInput()
  while true do
    local _, keyEvent = os.pullEvent("key")
    if keyEvent == keys.q then
      quit = true
      return
    elseif keyEvent == keys.p then
      PauseMining(true)
    elseif keyEvent == keys.g then
      PauseMining(false)
    end
  end
end


--  Initial Setup
rednet.open(wirelessModemPos)
if not loadStatus() then
  InitialSetup()
end
-- There might have been a server restart or chunk unload, causing this to be wrong
-- If we just started mining, we might "turn" and might the wrong strip
ReturnToOriginalFacing() 


-- Main 
parallel.waitForAll(BroadcastStatusForever, RednetRecvForever, MineForever, KeyInput)
