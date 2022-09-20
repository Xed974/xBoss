ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

--

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

local list = {}
RegisterNetEvent("xBoss:receiveList")AddEventHandler("xBoss:receiveList", function(result) list = result end)

--

local active = { money = 0, salary = {}, employes = {} }
local open = false
local mainMenu = RageUI.CreateMenu("Boss Menu", "Interaction", nil, nil, "root_cause5", "img_bleu")
local sub_argent = RageUI.CreateSubMenu(mainMenu, "Boss Menu", "Argent")
local sub_salaire = RageUI.CreateSubMenu(mainMenu, "Boss Menu", "Salaire")
local sub_gestion = RageUI.CreateSubMenu(mainMenu, "Boss Menu", "Gestion")
local sub_liste = RageUI.CreateSubMenu(mainMenu, "Boss Menu", "Liste employé")
mainMenu.Display.Header = true
mainMenu.Closed = function() FreezeEntityPosition(PlayerPedId(), false) active.money = 0 active.salary = {} active.employes = {} end

local function BossMenu(name, label, society)
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
                    RageUI.Separator(("Entreprise : ~b~%s~s~"):format(label))
                    RageUI.Line()
                    RageUI.Button("Gestion argent", nil, {RightBadge = RageUI.BadgeStyle.Star}, true, {
                        onSelected = function()
                            ESX.TriggerServerCallback("xBoss:getMoney", function(result) active.money = tonumber(result) end, society)
                        end
                    }, sub_argent)
                    RageUI.Button("Gestion salaire", nil, {RightBadge = RageUI.BadgeStyle.Star}, true, {
                        onSelected = function()
                            ESX.TriggerServerCallback("xBoss:getSalary", function(result) active.salary = result end, name)
                        end
                    }, sub_salaire)
                    RageUI.Button("Gestion employés", nil, {RightBadge = RageUI.BadgeStyle.Star}, true, {}, sub_gestion)
                    RageUI.Button("Liste employés", nil, {RightBadge = RageUI.BadgeStyle.Star}, true, {
                        onSelected = function()
                            ESX.TriggerServerCallback("xBoss:getEmployes", function(result) active.employes = result end, name)
                        end
                    }, sub_liste)
                end)
                RageUI.IsVisible(sub_argent, function()
                    RageUI.Separator(("Solde: ~g~%s$~s~"):format(active.money))
                    RageUI.Line()
                    RageUI.Button("Déposer de l'argent", nil, {RightLabel = "→"}, true, {
                        onSelected = function()
                            local keyboard = KeyboardInput("", "", 8)
                            if keyboard ~= nil and keyboard ~= "" then
                                if tonumber(keyboard) then
                                    TriggerServerEvent("xBoss:addMoney", society, tonumber(keyboard))
                                    Wait(1000)
                                    ESX.TriggerServerCallback("xBoss:getMoney", function(result) active.money = tonumber(result) end, society)
                                else
                                    ESX.ShowNotification("(~r~Error~s~)\nMontant incorrect.")
                                end
                            else
                                ESX.ShowNotification("(~r~Error~s~)\nMontant incorrect.")
                            end
                        end
                    })
                    RageUI.Button("Retirer de l'argent", nil, {RightLabel = "→"}, true, {
                        onSelected = function()
                            local keyboard = KeyboardInput("", "", 8)
                            if keyboard ~= nil and keyboard ~= "" then
                                if tonumber(keyboard) then
                                    TriggerServerEvent("xBoss:removeMoney", society, tonumber(keyboard))
                                    Wait(1000)
                                    ESX.TriggerServerCallback("xBoss:getMoney", function(result) active.money = tonumber(result) end, society)
                                else
                                    ESX.ShowNotification("(~r~Error~s~)\nMontant incorrect.")
                                end
                            else
                                ESX.ShowNotification("(~r~Error~s~)\nMontant incorrect.")
                            end
                        end
                    })
                end)
                RageUI.IsVisible(sub_salaire, function()
                    for _,v in pairs(active.salary) do
                        RageUI.Button(("~b~→~s~ %s"):format(v.label), nil, {RightLabel = ("~g~%s$~s~"):format(v.salary)}, true, {
                            onSelected = function()
                                local keyboard = KeyboardInput("", "", 4)
                                if tonumber(keyboard) then
                                    TriggerServerEvent("xBoss:updateSalary", v.name, name, tonumber(keyboard))
                                    Wait(1000)
                                    ESX.TriggerServerCallback("xBoss:getSalary", function(result) active.salary = result end, name)
                                else
                                    ESX.ShowNotification("(~r~Error~s~)\nNouveau salaire incorrect.")
                                end
                            end
                        })
                    end
                end)
                RageUI.IsVisible(sub_gestion, function()
                    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                    if closestPlayer ~= -1 and closestDistance <= 2.0 then
                        RageUI.Button("Recruter une personne", nil, {RightLabel = "→"}, true, {
                            onSelected = function()
                                TriggerServerEvent("xBoss:recruit", name, GetPlayerServerId(closestPlayer))
                            end
                        })
                        RageUI.Button("Promouvoir une personne", nil, {RightLabel = "→"}, true, {
                            onSelected = function()
                                TriggerServerEvent("xBoss:upGrade", name, GetPlayerServerId(closestPlayer))
                            end
                        })
                        RageUI.Button("Retrograder une personne", nil, {RightLabel = "→"}, true, {
                            onSelected = function()
                                TriggerServerEvent("xBoss:downGrade", name, GetPlayerServerId(closestPlayer))
                            end
                        })
                        RageUI.Button("Licencier une personne", nil, {RightLabel = "→"}, true, {
                            onSelected = function()
                                TriggerServerEvent("xBoss:leave", name, GetPlayerServerId(closestPlayer))
                            end
                        })
                    else
                        RageUI.Button("Recruter une personne", nil, {RightLabel = "→"}, false, {})
                        RageUI.Button("Promouvoir une personne", nil, {RightLabel = "→"}, false, {})
                        RageUI.Button("Retrograder une personne", nil, {RightLabel = "→"}, false, {})
                        RageUI.Button("Licencier une personne", nil, {RightLabel = "→"}, false, {})
                    end
                end)
                RageUI.IsVisible(sub_liste, function()
                    for _,v in pairs(active.employes) do
                        RageUI.Button(("~b~→~s~ %s %s"):format(v.firstname, v.lastname), nil, {RightLabel = ("~b~%s~s~"):format(v.grade)}, true, {})
                    end
                end)
            end
        end)
    end
end

--

Citizen.CreateThread(function()
    TriggerServerEvent("xBoss:refreshList")
    while true do
        local wait = 1000
        for _,v in pairs(list) do
            if ESX.PlayerData.job and ESX.PlayerData.job.name == v.name and ESX.PlayerData.job.grade_name == "boss" then
                local pos = v.pos
                local pPos = GetEntityCoords(PlayerPedId())
                local dst = Vdist(pPos.x, pPos.y, pPos.z, pos.x, pos.y, pos.z)

                if dst <= 3.0 then
                    wait = 0
                    DrawMarker(xBoss.MarkerType, pos.x, pos.y, (pos.z)-1.0, 0.0, 0.0, 0.0, 0.0,0.0,0.0, xBoss.MarkerSizeLargeur, xBoss.MarkerSizeEpaisseur, xBoss.MarkerSizeHauteur, xBoss.MarkerColorR, xBoss.MarkerColorG, xBoss.MarkerColorB, xBoss.MarkerOpacite, xBoss.MarkerSaute, true, p19, xBoss.MarkerTourne)
                end
                if dst <= 1.0 then
                    wait = 0
                    if (not open) then ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour ~b~intéragir~s~.") end
                    if IsControlJustPressed(1, 51) then
                        FreezeEntityPosition(PlayerPedId(), true)
                        BossMenu(v.name, v.label, v.society)
                    end
                end
            end
        end
        Citizen.Wait(wait)
    end
end)

--- Xed#1188 | https://discord.gg/HvfAsbgVpM