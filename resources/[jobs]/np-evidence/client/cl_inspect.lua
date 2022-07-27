CachedEvidence, InspectViewEnabled, InspectViewForced = {}, false, false

local EvidenceItems = {
    ["blood"] = "np_evidence_marker_red",
    ["casing"] = "np_evidence_marker_white",
    ["glass"] = "np_evidence_marker_light_blue",
    ["projectile"] = "np_evidence_marker_orange",
    ["vehiclefragment"] = "np_evidence_marker_purple",
}

local activeEvidence = CacheableMap(function (ctx)
    local success, evidence = RPC.execute("np-evidence:fetchEvidence")

    if success ~= true then return false, nil end

    return true, evidence
end, { timeToLive = 60 * 1000 })

local pickUpItem = function (pItem, pData)
    TriggerEvent("player:receiveItem", pItem, 1, true, pData)
end

local getNearbyEvidence = function(pCoords, pDist)
    local evidence = {}

    for k, v in pairs(CachedEvidence) do
        if not v then goto continue end

        local dist = Vdist(v.x, v.y, v.z, pCoords)

        if dist < pDist then
            evidence[#evidence+1] = k
        end

        ::continue::
    end

    return evidence
end

local collectEvidence = function (pCoords)
    local evidence = getNearbyEvidence(pCoords, 2)

    local collected = {}

    for _, id in ipairs(evidence) do
        if not CachedEvidence[id] then goto continue end

        local currentEvidence = CachedEvidence[id]
        local currentEvidenceData = currentEvidence["meta"]

        local evidenceInfo = currentEvidenceData["identifier"] or "FADED"
        local evidenceType = currentEvidenceData["type"] or "blood"

        local pickupId = evidenceInfo .. "_" .. evidenceType

        if collected[pickupId] then goto continue end
        collected[pickupId] = true

        local evidenceItem = EvidenceItems[evidenceType] or "np_evidence_marker_yellow"
        pickUpItem(evidenceItem, currentEvidenceData)

        Citizen.Wait(500)

        ::continue::
    end

    RPC.execute("np-evidence:clearEvidence", pCoords, evidence)
end

RegisterNetEvent("np-evidence:clearCache", function()
    activeEvidence.reset("inspect")

    if not InspectViewEnabled then return end

    CachedEvidence = activeEvidence.get("inspect")
end)

RegisterNetEvent("np-evidence:startInspectView", function()
    if InspectViewEnabled then return end

    InspectViewEnabled = true

    CachedEvidence = activeEvidence.get("inspect")

    while InspectViewEnabled do
        for _, v in pairs(CachedEvidence) do
            if not v then goto continue end

            local evidenceDistance = Vdist(v.x, v.y, v.z, Ped.coords)

            if (evidenceDistance < 20) then
                if v["meta"]["type"] == "blood" then
                    DrawMarker(28, v.x, v.y, v.z, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.1, 202, 22, 22, 141, 0, 0, 0, 0)
                    DrawText3Ds(v.x, v.y, v.z+0.5, v["meta"]["text"])
                elseif v["meta"]["type"] == "casing" then
                    DrawText3Ds(v.x, v.y, v.z+0.5, v["meta"]["text"])
                    DrawMarker(25, v.x, v.y, v.z, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.1, 252, 255, 1, 141, 0, 0, 0, 0)
                elseif v["meta"]["type"] == "projectile" then
                    DrawText3Ds(v.x, v.y, v.z+0.5, v["meta"]["text"])
                    DrawMarker(41, v.x, v.y, v.z+0.2, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.1, 13, 245, 1, 231, 0, 0, 0, 0)
                elseif v["meta"]["type"] == "glass" then
                    DrawText3Ds(v.x, v.y, v.z+0.5, v["meta"]["text"])
                    DrawMarker(23, v.x, v.y, v.z+0.2, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.1, 13, 10, 0, 191, 0, 0, 0, 0)
                elseif v["meta"]["type"] == "vehiclefragment" then
                    DrawText3Ds(v.x, v.y, v.z+0.5, v["meta"]["text"])
                    DrawMarker(36, v.x, v.y, v.z+0.2, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.1, v["meta"]["rgb"]["r"], v["meta"]["rgb"]["g"], v["meta"]["rgb"]["b"], 255, 0, 0, 0, 0)
                else
                    DrawText3Ds(v.x, v.y, v.z+0.5, v["meta"]["text"])
                    DrawMarker(21, v.x, v.y, v.z, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.1, 222, 255, 51, 91, 0, 0, 0, 0)
                end
            end

            ::continue::
        end

        Citizen.Wait(0)
    end
end)

RegisterNetEvent("np-evidence:stopInspectView", function()
    InspectViewEnabled = false
end)

local counter = 0

RegisterNetEvent("evidence:trigger", function()
    if InspectViewForced then
        counter = 5
        return
    else
        counter = 5
        InspectViewForced = true
        while counter > 0 do
            Wait(1000)
            if not IsPedUsingScenario(Ped.handle, "WORLD_HUMAN_PAPARAZZI") then
                counter = counter - 1
            end
        end
        InspectViewForced = false
    end
end)

RegisterCommand("+collectEvidence", function () end)

RegisterCommand("-collectEvidence", function ()
    if not InspectViewEnabled then return end

    local myjob = exports["np-base"]:getChar("job")
    local hasGatheringKit = exports["np-inventory"]:hasEnoughOfItem("gatheringkit", 1, false)

    if myjob ~= "cid" and not hasGatheringKit then return end

    local timer = 5000

    if myjob ~= "cid" and hasGatheringKit then
        timer = 60000
    end

    local finished = exports["np-taskbar"]:taskBar(timer, "Getting Evidence", "What?", true)

    if finished ~= 100 then return end

    collectEvidence(Ped.coords)
end)

Citizen.CreateThread(function ()
    exports["np-keybinds"]:registerKeyMapping("", "Evidence", "Get Evidence", "+collectEvidence", "-collectEvidence", "E")

    while true do
        local idle = 1000

        local canInspect = InspectViewForced or Ped.isAiming and Ped.weaponHash == `WEAPON_FLASHLIGHT`

        if canInspect and not InspectViewEnabled then
            idle = 100

            TriggerEvent("np-evidence:startInspectView")
        elseif not canInspect and InspectViewEnabled then
            idle = 100

            TriggerEvent("np-evidence:stopInspectView")
        end

        Citizen.Wait(idle)
    end
end)