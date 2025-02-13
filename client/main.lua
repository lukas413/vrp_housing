RegisterNetEvent("vrp_housing:houseBought")
AddEventHandler("vrp_housing:houseBought", function(x, y, z)
    print("Hus købt på koordinater:", x, y, z)
end)

RegisterNetEvent("vrp_housing:teleportInside")
AddEventHandler("vrp_housing:teleportInside", function(x, y, z)
    SetEntityCoords(PlayerPedId(), x, y, z)
end)