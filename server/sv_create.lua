ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local bossList = {}

local function getBoss()
    local load = LoadResourceFile("xBoss", "data.json")
    bossList = json.decode(load)
end

RegisterNetEvent("xBoss:refreshList")
AddEventHandler("xBoss:refreshList", function()
    getBoss()
    TriggerClientEvent("xBoss:receiveList", -1, bossList)
end)

ESX.RegisterServerCallback("xBoss:getGroup", function(source, cb)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if (not xPlayer) then return end
    cb(xPlayer.getGroup())
end)

RegisterNetEvent("xBoss:createBoss")
AddEventHandler("xBoss:createBoss", function(add)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if (not xPlayer) then return end
    getBoss()
    table.insert(bossList, add)
    SaveResourceFile("xBoss", "data.json", json.encode(bossList), -1)
    TriggerEvent("xBoss:refreshList")
end)

--- Xed#1188 | https://discord.gg/HvfAsbgVpM