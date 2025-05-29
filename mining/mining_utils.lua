local self = {}
print("loaded mining_utils")
--print("max fuel", turtle.getFuelLimit())

function self.mine_height(height)
 turtle.dig() -- dig in front

 for i = 1, height -1 do -- dig up
  if turtle.up() then
   turtle.dig()
  else
   print("Blocked going up at level ".. i)
   break
  end
 end   
 
 for i = 1, height -1 do -- return down
  if not turtle.down() then
   print("Blocked going down while returning")
   break
  end
 end
end--end mine_height

function self.place_torch()
 local torch_slot = nil
 for slot = 1, 16 do
  local item = turtle.getItemDetail(slot)
  if item and item.name:lower():find("torch") then
   torchSlot = slot
   break
  end
 end
 
 if not torchSlot then
  print("No torch found in inventory.")
  return false
 end
 
 turtle.select(torchSlot)
 
 -- try placing torch right
 turtle.turnRight()
 if turtle.placeUp() then
  turtle.turnLeft()
  return true
 end
 turtle.turnLeft()
 
 -- try placing torch below
 --if turtle.placeDown() then return true end
 
 -- try placing torch left
 turtle.turnLeft()
 if turtle.placeUp() then
  turtle.turnRight()
  return true
 end
end-- end place_torch

function self.find_and_refuel(target_percent)
 local target_percent = math.max(0, math.min(100, target_percent))
 local fuel_level = turtle.getFuelLevel()
 local fuel_limit = turtle.getFuelLimit()
 local target_fuel = math.floor((target_percent / 100) * fuel_limit)
 
 if fuel_level >= target_fuel then
  print("Fuel OK")
  return true
 end
 
 for slot = 1, 16 do
  local item = turtle.getItemDetail(slot)
  if item then
   turtle.select(slot)
   if turtle.refuel(1) then --test if item is fuel
    print("Refueling with: " .. item.name)
    turtle.refuel()
    fuel_level = turtle.getFuelLevel()
    if fuel_level >= target_fuel then
     print("Reached target fuel level: " .. fuel_level)
     return true
    end
   end  
  end
 end
 print("Could not rerach target fuel level")
 return false
end-- end find_and_refuel

function self.is_inventory_full()
 for slot = 1, 16 do
  if turtle.getItemCount(slot) == 0 then
   return false
  end
 end
 return true
end-- end is_inventory_full

return self
