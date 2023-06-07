local com = require ("component")
local os = require("os")
local event = require("event")
local gpu = com.gpu
local term = require("term")
local minTemp = 250
local maxTemp = 800
local minEnergy = 50
local maxEnergy = 90
local production = 0
local maxProduction = 1000
local background = gpu.setBackground
local foreground = gpu.setForeground
local reactor = com.br_reactor

local turbines = {}
local i = 1
for address, type in com.list("br_turbine") do
  turbines[i] = com.proxy(address)
  i = i + 1
end


term.clear()



local function drawTempBar(min,max,value)
  foreground(0x000000)
  background(0x353535)
  gpu.fill(40,4,80,5," ")
  background(0x00FF00)
  if math.ceil(value/max*80) >= 80 then
    background(0xFF4400)
    gpu.fill(40,4,80,5," ")
  elseif math.ceil(value)<= min then
    background(0xFFFF00)
    gpu.fill(40,4,math.ceil(value/max*80),5," ")
  else 
    gpu.fill(40,4,math.ceil(value/max*80),5," ")
  end
  foreground(0xFFFFFF)
  background(0x000000)
  gpu.set(70,3,"température:"..value.." °C  ")
end

local function drawEnergyBar(min,max,totalStored,totalMax)
  foreground(0x000000)
  background(0x353535)
  gpu.fill(40,12,80,5," ")
  background(0x00FF00)
  gpu.fill(40,12,math.ceil(totalStored/totalMax*80),5," ")
  foreground(0xffffff)
  background(0x000000)
  gpu.set(65,11,"Energy stored:"..totalStored / 1000 .."/"..totalMax / 1000 .." KiRF    ")  
end

local function drawButtons(trigger)
  gpu.set(10,3,"min Temp:"..minTemp.." °C")
  gpu.set(135,3,"max Temp:"..maxTemp.."°C")
  gpu.set(10,11,"min Energy:"..minEnergy.."%")
  gpu.set(135,11,"max Energy:"..maxEnergy.."%")
  foreground(0x000000)
  background(0xFF0000)
  if trigger == 1 then background(0x00FF00) end
  --draw the left buttons
  gpu.fill(5,4,10,5," ")--draw the box for the negative sign
  background(0x353535)--gray color
  gpu.fill(6,6,8,1," ")-- draw the negative sign
  background(0xFF0000)
  if trigger == 2 then background(0x00FF00) end
  gpu.fill(20,4,10,5," ")--draw the box for the positive sign
  background(0x353535)
  --draw the cross sign
  gpu.fill(21,6,8,1," ")
  gpu.fill(24,5,2,3," ")
  --draw Energy bar buttons
  background(0xFF0000)
  if trigger == 3 then background(0x00FF00) end
  --draw the right buttons
  gpu.fill(145,4,10,5," ")--draw the box for the negative sign
  background(0x353535)
  gpu.fill(146,6,8,1," ")--draw negative sign
  background(0xff0000)
  if trigger==4 then background(0x00FF00) end
  gpu.fill(130,4,10,5," ")--draw the box for the positive sign
  background(0x353535)
  --draw positive sign
  gpu.fill(131,6,8,1," ")
  gpu.fill(134,5,2,3," ")
  background(0xFF0000)
  if trigger == 5 then background(0x0ff00) end
  gpu.fill(5,12,10,5," ")--draw the box for the negative sign
  background(0x353535)
  gpu.fill(6,14,8,1," ")-- draw the negative sign
  background(0xFF0000)
  if trigger == 6 then background(0x00FF00) end
  gpu.fill(20,12,10,5," ")--draw the box for the positive sign
  background(0x353535)
  gpu.fill(21,14,8,1," ")
  gpu.fill(24,13,2,3," ")
  background(0xFF0000)
  if trigger == 7 then background(0x0ff00) end
  gpu.fill(145,12,10,5," ")--draw the box for the negative sign
  background(0x353535)
  gpu.fill(146,14,8,1," ")-- draw the negative sign
  background(0xFF0000)
  if trigger == 8 then background(0x00FF00) end
  gpu.fill(130,12,10,5," ")--draw the box for the positive sign
  background(0x353535)
  gpu.fill(131,14,8,1," ")
  gpu.fill(134,13,2,3," ")
  foreground(0xFFFFFF)
  background(0x000000)
end

local function drawColdCoolantTankBar()
  foreground(0x000000)
  background(0x00FF00)
  gpu.fill(5,20,10,20," ")
  background(0x353535)
  gpu.fill(5,20,10,math.floor(20-reactor.getCoolantAmount()/reactor.getCoolantAmountMax()*20)," ")
  foreground(0xFFFFFF)
  background(0x000000)
  gpu.set(4,19,"Coolant:"..math.ceil(reactor.getCoolantAmount()/reactor.getCoolantAmountMax()*100) .."%  ")
end

local function drawHotCoolantTankBar()
  foreground(0x000000)
  background(0x00FF00)
  gpu.fill(20,20,10,20," ")
  background(0x353535)
  gpu.fill(20,20,10,math.floor(20-reactor.getHotFluidAmount()/reactor.getHotFluidAmountMax()*20)," ")
  foreground(0xFFFFFF)
  background(0x000000)
  gpu.set(20,19,"Steam:"..math.ceil(reactor.getHotFluidAmount()/reactor.getHotFluidAmountMax()*100) .."% ")
end

local function drawFuelTankBar()
  foreground(0x000000)
  background(0x0000FF)
  gpu.fill(40,20,10,20," ")
  background(0xFFFF00)
  gpu.fill(40,20,10,(math.ceil(((1-(reactor.getFuelAmount()+reactor.getWasteAmount())/reactor.getFuelAmountMax())*20)+reactor.getFuelAmount()/(reactor.getFuelAmountMax()-reactor.getWasteAmount())*20))," ")
  background(0x353535)
  gpu.fill(40,20,10,math.ceil((1-(reactor.getFuelAmount()+reactor.getWasteAmount())/reactor.getFuelAmountMax())*20)," ")
  background(0x000000)
  foreground(0xFFFFFF)
  gpu.set(41,19,"Fuel:"..math.ceil(reactor.getFuelAmount()/reactor.getFuelAmountMax()*100) .."%  ")
end

local function drawControlRodLevelBar()
  foreground(0x000000)
  if reactor.getControlRodLevel(1) > 80 or reactor.getControlRodLevel(1) < 20 then
    background(0xFF8F00)
  else 
    background(0x00FF00)
  end
  gpu.fill(110,20,10,20," ")
  background(0x353535)
  gpu.fill(110,20,10,20-reactor.getControlRodLevel(1)/100*20," ")
  background(0x000000)
  foreground(0xFFFFFF)
  gpu.set(111,19,"Rods:"..reactor.getControlRodLevel(1).."%  ")
end

local function drawProductionBar(production,maxProduction)
  foreground(0x000000)
  if production/maxProduction*100 < 20 then background(0xFF0000)
  else background(0x00FF00) end
  gpu.fill(130,20,10,20," ")
  background(0x353535)
  gpu.fill(130,20,10,20-math.ceil(production/maxProduction*20)," ")
  background(0x000000)
  foreground(0xFFFFFF)
  gpu.set(129,18,"Production:")
  gpu.set(129,19,""..math.ceil(production)/1000 .." KiRF/t   ")
end

local function drawFlowBar(maxFlow)
  foreground(0x000000)
  if reactor.getHotFluidProducedLastTick()/maxFlow*100 < 80 then
    background(0xFF0000)
  else background(0x00FF00) end
  gpu.fill(145,20,10,20," ")
  background(0x353535)
  gpu.fill(145,20,10,20-reactor.getHotFluidProducedLastTick()/maxFlow*20," ")
  background(0x000000)
  foreground(0xFFFFFF)
  gpu.set(144,19,"flow:"..math.ceil(reactor.getHotFluidProducedLastTick()).." mB/t  ")
end

local function getClick(_,_,x,y,_,player)
  --local _,_,x,y,_,player = event.pull()
  if 4<x and x<16 and 3<y and y<9 then 
    trigger = 1 
    minTemp = minTemp - 10
  elseif 19<x and x<31 and 3<y and y<9 then
    trigger = 2  
    minTemp = minTemp + 10
  elseif 144<x and x<156 and 3<y and y<9 then
    trigger = 3
    maxTemp = maxTemp - 10
  elseif 129<x and x<141 and 3<y and y<9 then
    trigger = 4
    maxTemp = maxTemp + 10 
  elseif 4<x and x<16 and 11<y and y<18 then
    trigger = 5
    minEnergy = minEnergy - 10
  elseif 19<x and x<31 and 11<y and y<18 then
    trigger = 6
    minEnergy = minEnergy + 10
  elseif 144<x and x<156 and 11<y and y<18 then
    trigger = 7
    maxEnergy = maxEnergy - 10
  elseif 129<x and x<141 and 11<y and y<18 then
    trigger = 8
    maxEnergy = maxEnergy + 10
  end
  drawButtons(trigger)
  trigger = 0
  os.sleep(0.5)
  drawButtons(trigger)
end

drawTempBar(0,0,0)
drawEnergyBar(0,0,0,0)
drawButtons(0)
event.listen("touch", getClick)

while true do
  local totalEnergyStored = 0
  local maxEnergyCapacity = 0
  local averageRPM = 0
  production = 0
  maxFlow = 0
  x = 0
  local reactorTemp = math.floor(reactor.getFuelTemperature())
  if reactorTemp > maxTemp and reactor.getActive() then
    reactor.setAllControlRodLevels(reactor.getControlRodLevel(1)+1)
  elseif reactorTemp < minTemp and reactor.getActive() then
    reactor.setAllControlRodLevels(reactor.getControlRodLevel(1)-1)
  end
  for _,turbine in pairs(turbines) do
    totalEnergyStored = totalEnergyStored + turbine.getEnergyStored()
    maxEnergyCapacity = maxEnergyCapacity + 1000000
    production = production + turbine.getEnergyProducedLastTick()
    averageRPM = averageRPM + turbine.getRotorSpeed()
    maxFlow =maxFlow + turbine.getFluidFlowRateMax()
    x = x + 1
  end
  averageRPM = averageRPM/x 
  if production > maxProduction then maxProduction = production end
  if totalEnergyStored/maxEnergyCapacity*100 >= maxEnergy and reactor.getActive() then
    reactor.setActive(false)
    reactor.setAllControlRodLevels(100)
  elseif totalEnergyStored/maxEnergyCapacity*100 <= minEnergy and not reactor.getActive() then
    reactor.setActive(true)
  end
  drawEnergyBar(0,0,totalEnergyStored,maxEnergyCapacity)
  x,y = 0,0
  drawProductionBar(production,maxProduction)
  drawFuelTankBar()
  drawHotCoolantTankBar()
  drawColdCoolantTankBar()
  drawTempBar(minTemp,maxTemp,reactorTemp)
  drawControlRodLevelBar()
  drawFlowBar(maxFlow)
  gpu.set(67,23,"Turbines RPM  :"..math.ceil(averageRPM*10)/10 .."   ")
  gpu.set(66,24,"Fuel Reactivity:"..math.ceil(reactor.getFuelReactivity()).." %  ")
  gpu.set(67,25,"Consumption   :"..math.ceil(reactor.getFuelConsumedLastTick()*100)/100 .." mB/t  ")
  os.sleep(1)
  trigger = 0
end
event.ignore("touch", getClick)