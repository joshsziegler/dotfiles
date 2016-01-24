-- Minecraft - Turtle - Drill Server
local rednetProtocol = "ZigMT"
local continueServer = true -- continue even loop
local pauseMining = false
local turtleStatus = nil -- supports 10

function RednetRecvForever()
    while true do
        senderId, message, rednetProtocol = rednet.receive(rednetProtocol)
        turtleStatus[senderId] = message -- save this status message
        PrintStatusScreen()
    end
end

function RednetBroadcastForever()
  while true do
    rednet.broadcast(pauseMining, rednetProtocol)
    sleep(1.0)
  end
end

function KeyInput()
  while true do
    local _, keyEvent = os.pullEvent("key")
    if keyEvent == keys.q then
      continueServer = false
      return
    elseif keyEvent == keys.s then
      pauseMining = true -- pause turtles when they reach the top of their bore holes
    elseif keyEvent == keys.g then 
      pauseMining = false -- continue or start mining turtles
    elseif keyEvent == keys.r then
      RefreshTurtleStatus()
      PrintStatusScreen()
    end
  end
end

function RefreshTurtleStatus()
  turtleStatus = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil}
end

-- Returns term to white text after writing
function WriteWithColor(msg, color)
  term.setTextColor(color)
  term.write(msg)
  term.setTextColor(colors.white)
end

function NewLine()
  oldx, oldy = term.getCursorPos()
  term.setCursorPos(1,oldy+1)
end

function ClearTerm()
  term.clear()
  term.setCursorPos(1,1)
end

function PrintStatusScreen()
  ClearTerm()
  term.write("Turtles ")
  if pauseMining then
    WriteWithColor("paused", colors.red)
  else
    WriteWithColor("mining", colors.green)
  end
  NewLine()

  for i=0, table.getn(turtleStatus) do
    if turtleStatus[i] then
      local tmp = turtleStatus[i]
      WriteWithColor(tmp.name, colors.orange)
      WriteWithColor(" X", colors.blue)
      term.write(tmp.xPos)
      WriteWithColor(" Y", colors.blue)
      term.write(tmp.yPos)
      WriteWithColor(" Z", colors.blue)
      term.write(tmp.zPos)
      NewLine()
      term.write(tmp.lastMessage)
      NewLine()
    else
      NewLine()
      NewLine()
    end
  end
  term.write("(q)uit (s)top (g)o (r)efresh") -- commands
end


print("Opening Rednet Modem")
rednet.open("back")
rednet.host(rednetProtocol, os.getComputerLabel())

-- Setup monitor if it exists
local mon = peripheral.find("monitor")
if mon then
  term.redirect(mon)
end

print("Mining Server Started")
RefreshTurtleStatus()
while continueServer do
  parallel.waitForAny(RednetRecvForever, RednetBroadcastForever, KeyInput)
end

rednet.unhost(rednetProtocol, os.getComputerLabel())
print("Mining Server Shutdown")