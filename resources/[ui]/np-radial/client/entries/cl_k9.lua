local K9Entries, SubMenu = MenuEntries["k9"], {}

local K9 = {
    {
        id="k9Summon",
        title = "Summon",
        icon = "#k9-spawn",
        event = "K9:Create"
    },
    {
        id="k9Dismiss",
        title = "Dismiss",
        icon = "#k9-dismiss",
        event = "K9:Delete"
    },
    {
        id="k9Follow",
        title = "Follow",
        icon = "#k9-follow",
        event = "K9:Follow"
    },
    {
        id="k9GetInout",
        title = "Get in/out",
        icon = "#k9-vehicle",
        event = "K9:Vehicle"
    },
    {
        id="k9Sit",
        title = "Sit",
        icon = "#k9-sit",
        event = "K9:Sit"
    },
    {
        id="k9Lay",
        title = "Lay",
        icon = "#k9-lay",
        event = "K9:Lay"
    },
    {
        id="k9Stand",
        title = "Stand",
        icon = "#k9-stand",
        event = "K9:Stand"
    },
    {
        id="k9Sniff",
        title = "Sniff Person",
        icon = "#k9-sniff",
        event = "K9:Sniff"
    },
    {
        id="k9SniffVehicle",
        title = "Sniff Vehicle",
        icon = "#k9-sniff-vehicle",
        event = "sniffVehicle"
    },
    {
        id="k9Hunt",
        title = "Hunt nearest",
        icon = "#k9-huntfind",
        event = "K9:Huntfind"
    },
}

-- Citizen.CreateThread(function()
--     for index, data in ipairs(K9) do
--         SubMenu[index] = data.id
--         MenuItems[data.id] = {data = data}
--     end

--     K9Entries[#K9Entries+1] = {
--         data = {
--           id = "k9",
--           icon = "#k9",
--           title = "K9",
--         },
--         subMenus = SubMenu,
--         isEnabled = function ()
--             return not exports["np-base"]:getVar("dead") and exports["np-jobs"]:getJob(CurrentJob, "is_police")
--         end,
--     }
-- end)

