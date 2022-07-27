--[[

    Variables

]]

local weedPlants = {}

--[[

    RPCs

]]

RPC.register("np-weed:getPlants", function(src)
    return weedPlants
end)

RPC.register("np-weed:plantSeed", function(src, pCoords, pStrain)
    local pGender = 0
    local pTimestamp = os.time()

    local insertId = MySQL.insert.await([[
        INSERT INTO weed (gender, coords, strain, timestamp)
        VALUES (?, ?, ?, ?)
    ]],
    { pGender, json.encode(pCoords), json.encode(pStrain), pTimestamp })

    if not insertId or insertId < 1 then
        return false
    end

    local data = {
        id = insertId,
        gender = pGender,
        coords = pCoords,
        strain = pStrain,
        timestamp = pTimestamp,
        last_harvest = 0
    }

    weedPlants[insertId] = data
    TriggerClientEvent("np-weed:trigger_zone", -1, 1, data)

    return true
end)

RPC.register("np-weed:addWater", function(src, pPlantId)
    local plant = weedPlants[pPlantId]

    if plant == nil then
        return false
    end

    local strain = plant["strain"]
    strain["water"] = strain["water"] + PlantConfig.WaterAdd

    local affectedRows = MySQL.update.await([[
        UPDATE weed
        SET strain = ?
        WHERE id = ?
    ]],
    { json.encode(strain), pPlantId })

    if not affectedRows or affectedRows < 1 then
        return false
    end

    weedPlants[pPlantId]["strain"] = strain
    TriggerClientEvent("np-weed:trigger_zone", -1, 2, weedPlants[pPlantId])

    return true
end)

RPC.register("np-weed:addFertilizer", function(src, pPlantId, pType)
    local plant = weedPlants[pPlantId]

    if plant == nil then
        return false
    end

    local strain = plant["strain"]
    strain[pType] = strain[pType] + PlantConfig.FertilizerAdd

    local affectedRows = MySQL.update.await([[
        UPDATE weed
        SET strain = ?
        WHERE id = ?
    ]],
    { json.encode(strain), pPlantId })

    if not affectedRows or affectedRows < 1 then
        return false
    end

    weedPlants[pPlantId]["strain"] = strain
    TriggerClientEvent("np-weed:trigger_zone", -1, 2, weedPlants[pPlantId])

    return true
end)

RPC.register("np-weed:addMaleSeed", function(src, pPlantId)
    local plant = weedPlants[pPlantId]

    if plant == nil then
        return false
    end

    local affectedRows = MySQL.update.await([[
        UPDATE weed
        SET gender = 1
        WHERE id = ?
    ]],
    { pPlantId })

    if not affectedRows or affectedRows < 1 then
        return false
    end

    weedPlants[pPlantId]["gender"] = 1
    TriggerClientEvent("np-weed:trigger_zone", -1, 2, weedPlants[pPlantId])

    return true
end)

RPC.register("np-weed:removePlant", function(src, pPlantId, pFertilizer)
    local plant = weedPlants[pPlantId]

    if plant == nil then
        return false
    end

    local affectedRows = MySQL.update.await([[
        DELETE FROM weed
        WHERE id = ?
    ]],
    { pPlantId })

    if not affectedRows or affectedRows < 1 then
        return false
    end

    weedPlants[pPlantId] = nil
    TriggerClientEvent("np-weed:trigger_zone", -1, 3, { id = pPlantId })

    return true
end)

RPC.register("np-weed:harvestPlant", function(src, pPlantId)
    local plant = weedPlants[pPlantId]

    if plant == nil then
        return false
    end

    local pTimestamp = os.time()

    local affectedRows = MySQL.update.await([[
        UPDATE weed
        SET last_harvest = ?
        WHERE id = ?
    ]],
    { pTimestamp, pPlantId })

    if not affectedRows or affectedRows < 1 then
        TriggerEvent("DoLongHudText", src, "ERROR: affectedRows == nil or affectedRows < 1", 2)
        return false
    end

    weedPlants[pPlantId]["last_harvest"] = pTimestamp
    TriggerClientEvent("np-weed:trigger_zone", -1, 2, weedPlants[pPlantId])

    if weedPlants[pPlantId]["gender"] == 0 then
        TriggerClientEvent("player:receiveItem", src, "weedq", 5)
    elseif weedPlants[pPlantId]["gender"] == 1 then
        if PlantConfig.RemoveMaleOnHarvest then
            local affectedRows2 = MySQL.update.await([[
                DELETE FROM weed
                WHERE id = ?
            ]],
            { pPlantId })

            if not affectedRows2 or affectedRows2 < 1 then
                TriggerEvent("DoLongHudText", src, "ERROR: affectedRows2 == nil or affectedRows2 < 1", 2)
                return false
            end

            weedPlants[pPlantId] = nil
            TriggerClientEvent("np-weed:trigger_zone", -1, 3, { id = pPlantId })
        end

        local seedAmount = math.random(PlantConfig.SeedsFromMale[1], PlantConfig.SeedsFromMale[2])
        for i = 1, seedAmount do
            local chance = roundDecimals(math.random(), 2)
            if chance <= PlantConfig.MaleChance then
                TriggerClientEvent("player:receiveItem", src, "maleseed", 1)
            else
                TriggerClientEvent("player:receiveItem", src, "femaleseed", 1)
            end
        end
    end

    return true
end)

--[[

    Threads

]]

Citizen.CreateThread(function()
    local plants = MySQL.query.await([[
        SELECT *
        FROM weed
    ]])

    for idx, plant in ipairs(plants) do
        plant["coords"] = json.decode(plant.coords)
        plant["strain"] = json.decode(plant.strain)
        plant["coords"] = vector3(plant["coords"]["x"], plant["coords"]["y"], plant["coords"]["z"])
        weedPlants[plant.id] = plant
    end

    while true do
        local time = os.time()

        for id, plant in pairs(weedPlants) do
            if (time - plant.timestamp) >= (PlantConfig.LifeTime * 60) then
                local affectedRows = MySQL.update.await([[
                    DELETE FROM weed
                    WHERE id = ?
                ]],
                { id })

                if affectedRows and affectedRows > 0 then
                    weedPlants[id] = nil
                    TriggerClientEvent("np-weed:trigger_zone", -1, 3, plant)
                end
            end
        end

        Citizen.Wait(PlantConfig.UpdateTimer)
    end
end)