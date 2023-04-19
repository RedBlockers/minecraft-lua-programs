local component = require("component")
local os = require("os")
local sides = require("sides")
local computer = require('computer')
outputSas = component.proxy("8df4721d-28d6-43e4-b7c7-0e2d1a3557f4")
ButtonSas = component.proxy("2ebed15f-0486-4965-ad34-50fbc68990a2")
while true do
  if computer.energy() < 150 then
    computer.beep(200,2)
  end
  if ButtonSas.getInput(sides.south) == 0 then
    if ButtonSas.getInput(sides.north) > 0 then
      computer.beep(2000,0.5)
      outputSas.setOutput(sides.west,15)
      os.sleep(2)
      outputSas.setOutput(sides.west,0)
      outputSas.setOutput(sides.south,15)
      os.sleep(2)
      computer.beep(1000,0.5)
      outputSas.setOutput(sides.south,0)
    end
    if ButtonSas.getInput(sides.west) > 0 and ButtonSas.getInput(sides.bottom) == 0 then
      computer.beep(2000,0.5)
      outputSas.setOutput(sides.south,15)
      os.sleep(2)
      outputSas.setOutput(sides.south,0)
      outputSas.setOutput(sides.west,15)
      os.sleep(2)
      computer.beep(1000,0.5)
      outputSas.setOutput(sides.west,0)
    end  
  else
    if ButtonSas.getInput(sides.north) > 0 or ButtonSas.getInput(sides.west) > 0 then
      outputSas.setOutput(sides.north,15)
      os.sleep(1)
      outputSas.setOutput(sides.north,0)
      os.sleep(2)
    end
  end
  os.sleep(0.5)
end  