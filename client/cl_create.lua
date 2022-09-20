ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

--

function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)

    AddTextEntry('FMMC_KEY_TIP1', TextEntry) 
    
    blockinput = true 
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "Somme", ExampleText, "", "", "", MaxStringLenght) 
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do 
        Citizen.Wait(0)
    end 
         
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Citizen.Wait(500) 
        blockinput = false
        return result 
    else
        Citizen.Wait(500) 
        blockinput = false 
        return nil 
    end
end


local add = {
    name = "",
    label = "",
    society = "",
    pos = ""
}

--

local open = false
local mainMenu = RageUI.CreateMenu("Boss Menu", "Création", nil, nil, "root_cause5", "img_bleu")
mainMenu.Display.Header = true
mainMenu.Closed = function() open = false add.name = "" add.society = "" add.pos = "" end

local function CreateMenu()
    if open then
        open = false
        RageUI.Visible(mainMenu, false)
    else
        open = true
        RageUI.Visible(mainMenu, true)
        Citizen.CreateThread(function()
            while open do
                Wait(0)
                RageUI.IsVisible(mainMenu, function()
                    RageUI.Button("Nom de l'entreprise", nil, {RightLabel = add.name}, true, {
                        onSelected = function()
                            local keyboard = KeyboardInput("", "", 20)
                            if keyboard ~= nil and keyboard ~= "" then
                                add.name = keyboard
                            end
                        end
                    })
                    RageUI.Button("Label de l'entreprise", nil, {RightLabel = add.label}, true, {
                        onSelected = function()
                            local keyboard = KeyboardInput("", "", 20)
                            if keyboard ~= nil and keyboard ~= "" then
                                add.label = keyboard
                            end
                        end
                    })
                    RageUI.Button("Society de l'entreprise", nil, {RightLabel = add.society}, true, {
                        onSelected = function()
                            local keyboard = KeyboardInput("", "", 20)
                            if keyboard ~= nil and keyboard ~= "" then
                                add.society = keyboard
                            end
                        end
                    })
                    RageUI.Button("Position du menu", nil, {RightLabel = "→"}, true, {
                        onSelected = function()
                            add.pos = GetEntityCoords(PlayerPedId())
                        end
                    })
                    RageUI.Line()
                    RageUI.Button("Valider la création", nil, {RightBadge = RageUI.BadgeStyle.Tick}, true, {
                        onSelected = function()
                            if add.name ~= nil and add.name ~= "" then
                                if add.label ~= nil and add.label ~= "" then
                                    if add.society ~= nil and add.society ~= "" then
                                        if add.pos ~= nil and add.pos ~= "" then
                                            TriggerServerEvent("xBoss:createBoss", add)
                                            RageUI.CloseAll()
                                            Wait(1000)
                                            TriggerServerEvent("xBoss:refreshList")
                                        else
                                            ESX.ShowNotification("(~r~Error~s~)\nPosition mal défini.")
                                        end
                                    else
                                        ESX.ShowNotification("(~r~Error~s~)\nSociety mal défini.")
                                    end
                                else
                                    ESX.ShowNotification("(~r~Error~s~)\nLabel de l'entreprise mal défini.")
                                end
                            else
                                ESX.ShowNotification("(~r~Error~s~)\nNom de l'entreprise mal défini.")
                            end
                        end
                    })
                end)
            end
        end)
    end
end

RegisterCommand("createBoss", function()
    ESX.TriggerServerCallback("xBoss:getGroup", function(group) 
        for _,v in pairs(xBoss.RankAcces) do
            if v == group then
                CreateMenu()
            end
        end
    end)
end)

RegisterKeyMapping("createBoss", "Création Boss Menu", "keyboard", "f2")

--- Xed#1188 | https://discord.gg/HvfAsbgVpM