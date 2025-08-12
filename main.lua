local event = require("event")
local r = require("robot")
local component = require("component")
local na = component.navigation
local inv = component.inventory_controller
--
local movexy = { 4, 1 }
--
local function moveX(x)
  for i = 1, x do
    r.forward()
  end
end
local function moveZ(x)
  local bool = (x > 0)
  local y = math.abs(x)
  if bool then
    r.turnLeft()
  else
    r.turnRight()
  end
  moveX(y)
  if bool then
    r.turnRight()
  else
    r.turnLeft()
  end
end
local function contains(a, b)
  for k, v in ipairs(a) do
    if v == b then
      return true
    end
  end
  return false
end
local function printXX(a)
  for k, v in ipairs(a) do
    print(v)
  end
end
local function spStr(str)
  local a = {}
  for c in str:gmatch(".") do
    table.insert(a, c)
  end
  return a
end
--
local function build(rec, item)
  print("start")
  local x = 1
  local z = 1 --5x5 matrix
  local y = 1
  local cala = false
  local cur = nil
  local ti = nil
  for k, v in ipairs(rec) do
    print(v, tonumber(v))
    --os.sleep(2)
    if tonumber(v) ~= nil then
      cur = tonumber(v)
      if cur > 0 then
        ti = item[cur]
        for n = 1, 16 do
          r.select(n)
          local ci = inv.getStackInInternalSlot(n)
          if ci ~= nil and ci.name == ti then
            break
          end
        end
        if not cala then
          r.placeDown()
        else
          r.dropDown(1)
          os.sleep(1)
          while y > 0 do
            y = y - 1
            r.down()
          end
          moveZ(0 - movexy[2])
          r.turnRight()
          r.turnRight()
          moveX(movexy[1])
          r.turnRight()
          r.turnRight()
          while true do
            local wl = na.findWaypoints(16)
            local wait
            for k, v in ipairs(wl) do
              if v.label == "wait" then
                wait = v
                break
              end
            end
            if wait.redstone > 0 then
              os.sleep(1)
            else
              break
            end
          end
        end
      end
      if not cala then
        x = x + 1
        if x <= 5 then
          r.forward()
        else
          x = 1
          z = z + 1
          for u = 1, 4 do
            r.back()
          end
          moveZ(-1)
        end
      end
    else
      while x > 1 do
        x = x - 1
        r.back()
      end
      r.turnLeft()
      while z > 1 do
        z = z - 1
        r.forward()
      end
      r.turnRight()
      r.up()
      y = y + 1
      if v == "/" then
        while y < 7 do
          y = y + 1
          r.up()
        end
        cala = true
      end
    end
  end
end
--
local wp = na.findWaypoints(16)
local rsget
local run = true
while run do
  local list = {}
  local eName = event.pull(1)
  if eName == "key_down" then
    print("exit")
    run = false
  else
    print("waiting")
    wp = na.findWaypoints(16)
    for k, v in ipairs(wp) do
      if v.redstone == 15 and v.label ~= "wait" then
        rsget = v
        break
      end
    end
    if rsget ~= nil and inv.getStackInSlot(1, 1) ~= nil then
      local tar = rsget.label
      print("find recipe:" .. tar)
      local file = io.open("./recipes/" .. tar .. ".txt", "r")
      io.input(file)
      local rec = io.read()
      print(rec)
      os.sleep(0.5)
      while r.suckUp() do
        local checkinv = true
        local n = 16
        while checkinv do
          local it = inv.getStackInInternalSlot(n)
          if it ~= nil then
            checkinv = false
            if not contains(list, it.name) then
              table.insert(list, it.name)
            end
          else
            n = n - 1
          end
        end
      end
      printXX(list)
      moveX(movexy[1])
      moveZ(movexy[2])
      r.up()
      local sprec = spStr(rec)
      printXX(sprec)
      build(sprec, list)
    end
  end
end
