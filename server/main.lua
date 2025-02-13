local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP", "vrp_housing")

local ox_target = exports.ox_target
local ox_lib = exports.ox_lib
local MySQL = exports['mysql-async'] -- Brug mysql-async eksport

-- Database setup (Ensure you have a 'houses' table in MySQL)
MySQL.Async.execute("CREATE TABLE IF NOT EXISTS vrp_houses (id INT AUTO_INCREMENT PRIMARY KEY, owner VARCHAR(50), x FLOAT, y FLOAT, z FLOAT)", {})

local houses = {} -- Table to store house data in runtime

-- Load houses from the database
Citizen.CreateThread(function()
    MySQL.Async.fetchAll("SELECT * FROM vrp_houses", {}, function(rows)
        for _, row in pairs(rows) do
            houses[row.id] = { owner = row.owner, x = row.x, y = row.y, z = row.z }
        end
    end)
end)

-- Function to buy a house
RegisterServerEvent("vrp_housing:buyHouse")
AddEventHandler("vrp_housing:buyHouse", function(x, y, z, price)
    local source = source
    local user_id = vRP.getUserId({source})
    
    if not user_id then
        print("Error: Could not retrieve user ID for source " .. tostring(source))
        return
    end
    
    -- Attempt to charge the user
    local success = vRP.tryFullPayment({user_id, price})
    
    if success then
        -- Insert the house details into the database
        MySQL.Async.execute("INSERT INTO vrp_houses (owner, x, y, z) VALUES (@owner, @x, @y, @z)", {
            ['@owner'] = user_id,
            ['@x'] = x,
            ['@y'] = y,
            ['@z'] = z
        }, function(affectedRows)
            if affectedRows > 0 then
                TriggerClientEvent("vrp_housing:houseBought", source, x, y, z)
                vRPclient.notify(source, {"~g~Du har købt et hus!"})
            else
                vRPclient.notify(source, {"~r~Der opstod en fejl ved køb af huset!"})
            end
        end)
    else
        vRPclient.notify(source, {"~r~Du har ikke råd!"})
    end
end)

-- Function to enter a house
RegisterServerEvent("vrp_housing:enterHouse")
AddEventHandler("vrp_housing:enterHouse", function(house_id)
    local source = source
    local user_id = vRP.getUserId({source})
    
    if not user_id then
        print("Error: Could not retrieve user ID for source " .. tostring(source))
        return
    end
    
    local house = houses[house_id]
    if house and (house.owner == user_id or vRP.hasPermission({user_id, "house.access"})) then
        TriggerClientEvent("vrp_housing:teleportInside", source, house.x, house.y, house.z)
    else
        vRPclient.notify(source, {"~r~Du har ikke adgang til dette hus!"})
    end
end)

-- Example of adding an interaction zone using ox_target
ox_target:addBoxZone({
    coords = vector3(100.0, 200.0, 300.0), -- Replace with actual house position
    size = vector3(1.5, 1.5, 1.5),
    options = {
        {
            event = "vrp_housing:enterHouse",
            icon = "fa-solid fa-door-open",
            label = "Gå ind i huset"
        }
    },
    distance = 2.5
})

-- Registering interaction for an entity (e.g., door or object)
-- Make sure to replace 'entity' with your actual entity if you're targeting an object.
-- If you don't have a specific entity, this part is optional
ox_target:addTargetEntity(entity, {
    options = {
        {
            event = "vrp_housing:enterHouse",
            icon = "fa-solid fa-door-open",
            label = "Gå ind i huset"
        }
    },
    distance = 2.5 -- Adjust interaction distance as necessary
})
