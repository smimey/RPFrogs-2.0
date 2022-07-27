RegisterNUICallback("dataPost", function(data, cb)
    SetNuiFocus(false)
    if data.sv_event == true then 
        TriggerServerEvent(data.event, data.args)
    else
        TriggerEvent(data.event, data.args)
    end 

    cb('ok')
end)

RegisterNUICallback("cancel", function()
    SetNuiFocus(false)
end)


RegisterNetEvent('np-context:sendMenu', function(data)
    if not data then return end
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "OPEN_MENU",
        data = data
    })
end)

RegisterNetEvent('np-context:closemenu', function()
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "CLOSE_MENU",
        data = data
    })
end)