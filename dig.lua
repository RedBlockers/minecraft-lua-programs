local component = require("component")
local computer = require("computer")
local robot = require("robot")
local shell = require("shell")
local sides = require("sides")
local os =require('os')
x,y,z = 0,0,0
rot = 0

function goBack(oldX)
  if oldX % 2 == 0 then
    oldX = oldX-1
  end
  while oldX ~= x do
    robot.forward()
    x=x+1
  end
  return x
end
function test(slot)
  x= component.inventory_controller.getInventorySize(sides.front,slot).size
end
local function returnHome(actx_,actz_,rot)
  print("returning home")
  returning = true
  while returning  do
    print(actx_,actz_,rot)
    if actx_ ~= 0 then
      if rot == 0 then
        robot.turnAround()
        rot=180
      elseif rot == 90 then
        robot.turnRight()
        rot = 180
      elseif rot == -90 then
        robot.turnLeft()
        rot=180
      end
      robot.forward()
      actx_=actx_ - 1
    end  
    if actz_ ~= 0 then
      if rot ~= -90 then
        robot.turnRight()
        rot=-90
      end
      robot.forward()
      actz_ =actz_ - 1
      if actz_ == 0 then
        robot.turnLeft()
        rot = 180
      end
    end
    if actz_ ==0 and actx_==0 then
      returning = false
      robot.forward()
    end
    os.sleep(0.1)
  end
  return actx_,actz_,rot
        
end
dir = 0
while true do
  while robot.detect() do
    robot.swing()
    os.sleep(0.5)
  end
  while robot.detectUp() do
    robot.swingUp()
    os.sleep(0.5)
  end
  while robot.detectDown() do
    robot.swingDown()
    os.sleep(0.5)
  end
  while robot.detect() do
    robot.swing()
    os.sleep(0.5)
  end
  robot.forward()
  if dir == 0 then
    x = x+1
    dir = dir + 1
    robot.turnRight()
    rot=90
  elseif dir == 1 then
    z =z+ 1
    dir =dir+ 1
  elseif dir == 2 then
    z =z+ 1
    dir =dir+ 1
    robot.turnLeft()
    rot = 0
  elseif dir == 3 then
    x =x+ 1
    dir =dir+1
    robot.turnLeft()
    rot = -90
  elseif dir == 4 then
    z = z-1
    dir = dir+1
  elseif dir == 5 then
    z = z-1
    dir = 0
    robot.turnRight()
    rot = 0
  end
  if robot.count(32) >= 1 then
    for i=1,robot.inventorySize(),1 do
      print(i)
      item = component.inventory_controller.getStackInInternalSlot(i)
      print(item.name)
      if item.name == "minecraft:cobblestone" then
        robot.select(i)
        number = robot.count(i)
        robot.drop(number)
      end    
    end
    oldX = x
    x,z,rot=returnHome(x,z,rot)
    for i=1,robot.inventorySize(),1 do
      robot.select(i)
      print('droped item')
      number = robot.count(i)
      robot.drop(number)
    end
    robot.select(1)
    robot.turnAround()
    dir = 0
    rot = 0
    x=goBack(oldX)
  end
  if (computer.energy()/computer.maxEnergy())*100 <= 25 then
    oldX=x
    x,z,rot = returnHome(x,z,rot)
    while (computer.energy()/computer.maxEnergy())*100 <90 do
      os.sleep(1)
    end
    robot.turnAround()
    dir=0
    rot=0
    x=goBack(oldX) 
  end


os.sleep(0.1)
print(x,y,z,rot)
end