local mining = require("mining_utils")

-- editable variables --
local tunnel_length = 5
local tunnel_spacing = 2
local number_of_tunnels = 2
local tunnel_height = 3
local fuel_item_names = {
    ["minecraft:coal"] = true,
    ["modern_industrialization:lignite_coal"] = true,
}
-- ------------------ --

print("mining...")

local main_tunnel_length = 0

local tunnel_left = false
local tunnel_right = true

local relative_pos_x = 0
local relative_pos_y = 0
local relative_rot = 0


function main()
    for i = 1, number_of_tunnels*2 do

        -- move to correct tunnel lenght
        local helper_var_1 = math.floor((i-1) / 2)
        local helper_var_2 = tunnel_spacing * math.floor((i-1) / 2)
        main_tunnel_length = helper_var_1 + helper_var_2
        print("i =",i,"main_tunnel_length =",main_tunnel_length)
        for j = 1, main_tunnel_length do
            mining.mine_height(tunnel_height)
            turtle.forward()
            relative_pos_y = relative_pos_y + 1
        end

        -- set direction
        if tunnel_left then
            tunnel_left = false
            tunnel_right = true
        elseif tunnel_right then
            tunnel_right = false
            tunnel_left = true
        else
            error("DEBUG: no tunnel side set")
        end
        mine_tunnel(tunnel_length)

        -- set up for next dig
        normalize_rotation()
        while relative_rot ~= 0 do
            turtle.turnLeft()
            relative_rot = relative_rot + 1
            normalize_rotation()
        end

        
    end
end


function modulo(a, b)
    return a - math.floor(a/b)*b
end

function normalize_rotation()
    local normalized_rotation = modulo(relative_rot, 4)
    relative_rot = normalized_rotation
end

function dump_inventory(dump_position_x, dump_position_y, return_position_x, return_position_y, do_return)
    print("Dumping inventory")
    normalize_rotation()

    -- return to dump position
    local rotation_correction = nil
    if tunnel_left and tunnel_right then
        error("LEFT AND RIGHT AT ONCE")
        return false
    end
    if tunnel_left then
        rotation_correction = math.abs(3-relative_rot)
    end
    if tunnel_right then
        rotation_correction = math.abs(1-relative_rot)
    end
    for i = 1, rotation_correction do
        turtle.turnLeft()
        relative_rot = relative_rot + 1
    end

    local travel_to_zero_y = math.abs(dump_position_y - return_position_y)
    for i = 1, travel_to_zero_y do
        turtle.forward()
        relative_pos_y = relative_pos_y -1
    end

    if tunnel_left then
        turtle.turnRight()
        relative_rot = relative_rot -1
    end
    if tunnel_right then
        turtle.turnLeft()
        relative_rot = relative_rot +1
    end

    local travel_to_zero_x = math.abs(dump_position_x - return_position_x)
    for i = 1, travel_to_zero_x do
        turtle.forward()
        relative_pos_x = relative_pos_x -1
    end

    -- dump all items except for one torch stack and one fuel stack
    local found_fuel = false
    local found_torches = false

    for slot = 1, 16 do
        turtle.select(slot)
        local item = turtle.getItemDetail()

        if item then
            local item = item.name
    
            if fuel_item_names[item] and not found_fuel then
                found_fuel = true
            elseif item == "minecraft:torch" and not found_torches then
                found_torches = true
            else
                turtle.drop()
            end
        end
    end

    if do_return then
        -- return to return position
        while relative_rot ~= 0 do
            turtle.turnLeft()
            relative_rot = relative_rot +1
            normalize_rotation()
        end
        for i = 1, return_position_x do
            turtle.forward()
            relative_pos_x = relative_pos_x +1
        end

        if tunnel_left then
            turtle.turnLeft()
            relative_rot = relative_rot +1
        end
        if tunnel_right then
            turtle.turnRight()
            relative_rot = relative_rot -1
        end

        for i = 1, return_position_y do
            turtle.forward()
            relative_pos_y = relative_pos_y +1
        end
    end
end


function mine_tunnel(length)
    mining.find_and_refuel(50)
    normalize_rotation()

    if tunnel_left and tunnel_right then
        error("LEFT AND RIGHT AT ONCE")
        return false
    end
    if tunnel_left then
        turtle.turnLeft()
        relative_rot = relative_rot + 1
    elseif tunnel_right then
        turtle.turnRight()
        relative_rot = relative_rot - 1
    end

    for i = 1, length do
        mining.find_and_refuel(50)
        mining.mine_height(tunnel_height)
        turtle.forward()
        relative_pos_y = relative_pos_y + 1

        if mining.is_inventory_full() then
            dump_inventory(0,0,relative_pos_x,relative_pos_y, true)
        end
    end
    print("Dug a tunnel")
    dump_inventory(0,0,relative_pos_x,relative_pos_y, false)
end



main()