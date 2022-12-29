ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Logs

local function sendToDiscordWithSpecialURL(Color, Title, Description)
	local Content = {
	        {
	            ["color"] = Color,
	            ["title"] = Title,
	            ["description"] = Description,
		        ["footer"] = {
	            ["text"] = "Boss Menu",
	            ["icon_url"] = nil,
	            },
	        }
	    }
	PerformHttpRequest(xBoss.LogsDiscord, function(err, text, headers) end, 'POST', json.encode({username = Name, embeds = Content}), { ['Content-Type'] = 'application/json' })
end

local date = os.date('*t')

if date.day < 10 then date.day = '0' .. tostring(date.day) end
if date.month < 10 then date.month = '0' .. tostring(date.month) end
if date.hour < 10 then date.hour = '0' .. tostring(date.hour) end
if date.min < 10 then date.min = '0' .. tostring(date.min) end
if date.sec < 10 then date.sec = '0' .. tostring(date.sec) end

-- Money

ESX.RegisterServerCallback("xBoss:getMoney", function(source, cb, society)
    TriggerEvent('esx_addonaccount:getSharedAccount', society, function(account) cb(account.money) end)
end)

RegisterNetEvent("xBoss:addMoney")
AddEventHandler("xBoss:addMoney", function(society, count)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if (not xPlayer) then return end
    TriggerEvent('esx_addonaccount:getSharedAccount', society, function(account)
        if xPlayer.getMoney() >= count then
            xPlayer.removeMoney(count)
            account.addMoney(count)
            TriggerClientEvent('esx:showNotification', source, ("(~g~Succès~s~)\nVous avez déposez ~g~%s$~s~"):format(count))
            sendToDiscordWithSpecialURL(0, ("Ajout de %s$ dans %s"):format(count, society), ("Joueur: %s\nLicense: %s\nSteam: %s\nDiscord: %s\n\nDate: %s.%s.%s, Heure: %s:%s:%s"):format(xPlayer.getName(), xPlayer.getIdentifier(), GetPlayerIdentifier(source, 0), GetPlayerIdentifier(source, 2), date.day, date.month, date.year, date.hour, date.min, date.sec))
        else
            TriggerClientEvent('esx:showNotification', source, '(~r~Error~s~)\nVous n\'avez pas assez d\'argent !')
        end
    end)
end)

RegisterNetEvent("xBoss:removeMoney")
AddEventHandler("xBoss:removeMoney", function(society, count)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if (not xPlayer) then return end
    TriggerEvent('esx_addonaccount:getSharedAccount', society, function(account)
        if account.money >= count then
            xPlayer.addMoney(count)
            account.removeMoney(count)
            TriggerClientEvent('esx:showNotification', source, ("(~g~Succès~s~)\nVous avez retirez ~g~%s$~s~"):format(count))
            sendToDiscordWithSpecialURL(0, ("Retrait de %s$ dans %s"):format(count, society), ("Joueur: %s\nLicense: %s\nSteam: %s\nDiscord: %s\n\nDate: %s.%s.%s, Heure: %s:%s:%s"):format(xPlayer.getName(), xPlayer.getIdentifier(), GetPlayerIdentifier(source, 0), GetPlayerIdentifier(source, 2), date.day, date.month, date.year, date.hour, date.min, date.sec))
        else
            TriggerClientEvent('esx:showNotification', source, '(~r~Error~s~)\nL\'entreprise n\'a pas assez d\'argent !')
        end
    end)
end)

-- Salaire

ESX.RegisterServerCallback("xBoss:getSalary", function(source, cb, name)
    MySQL.Async.fetchAll("SELECT name, label, salary FROM job_grades WHERE job_name = @name", { ['@name'] = name }, function(result) cb(result) end)
end)

RegisterNetEvent("xBoss:updateSalary")
AddEventHandler("xBoss:updateSalary", function(grade, job, salary)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if (not xPlayer) then return end
    MySQL.Async.execute("UPDATE job_grades SET salary = @salary WHERE job_name = @job AND name = @grade", {
        ['@salary'] = salary,
        ['@job'] = job,
        ['@grade'] = grade
    }, function(callback) if callback ~= nil then TriggerClientEvent('esx:showNotification', source, '(~g~Succès~s~)\nSalaire modifier.') sendToDiscordWithSpecialURL(0, ("Nouveau salaire (%s$) pour %s dans l'entreprise %s"):format(salary, grade, job), ("Joueur: %s\nLicense: %s\nSteam: %s\nDiscord: %s\n\nDate: %s.%s.%s, Heure: %s:%s:%s"):format(xPlayer.getName(), xPlayer.getIdentifier(), GetPlayerIdentifier(source, 0), GetPlayerIdentifier(source, 2), date.day, date.month, date.year, date.hour, date.min, date.sec)) end end)
end)

-- Gestion

RegisterNetEvent("xBoss:recruit")
AddEventHandler("xBoss:recruit", function(job, target)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(target)

    if (not xPlayer) then return end
    if (xPlayer.getJob().name) == job and (xPlayer.getJob().grade_name) == "boss" then
        if (xTarget.getJob().name) == "unemployed" then
            xTarget.setJob(job, 0)
            TriggerClientEvent('esx:showNotification', source, '(~g~Succès~s~)\nLa personne à été recruté.')
            TriggerClientEvent('esx:showNotification', xTarget.source, '(~y~Information~s~)\nVous avez un nouveau métier.')
            sendToDiscordWithSpecialURL(0, "Recrutement", ("RECRUTEUR :\n\nJoueur: %s\nLicense: %s\nSteam: %s\nDiscord: %s\n\nRECRUTER : \n\nJoueur: %s\nLicense: %s\nSteam: %s\nDiscord: %s\n\nDate: %s.%s.%s, Heure: %s:%s:%s"):format(xPlayer.getName(), xPlayer.getIdentifier(), GetPlayerIdentifier(source, 0), GetPlayerIdentifier(source, 2), xTarget.getName(), xTarget.getIdentifier(), GetPlayerIdentifier(target, 0), GetPlayerIdentifier(target, 2), date.day, date.month, date.year, date.hour, date.min, date.sec))
        else
            TriggerClientEvent('esx:showNotification', source, '(~r~Error~s~)\nLa personne à déjà un métier.')
        end
    end
end)

RegisterNetEvent("xBoss:upGrade")
AddEventHandler("xBoss:upGrade", function(job, target)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(target)

    if (not xPlayer) then return end
    if (xPlayer.getJob().name) == job and (xPlayer.getJob().grade_name) == "boss" then
        if (xTarget.getJob().name) == job then
            local grade = xTarget.getJob().grade
            if grade + 1 ~= xPlayer.getJob().grade  then
                xTarget.setJob(job, (grade + 1))
                TriggerClientEvent('esx:showNotification', source, '(~g~Succès~s~)\nLa personne à été promu.')
                TriggerClientEvent('esx:showNotification', xTarget.source, '(~y~Information~s~)\nVous avez été promu.')
                sendToDiscordWithSpecialURL(0, ("Promotion en tant que %s"):format(xTarget.getJob().grade_label), ("RECRUTEUR :\n\nJoueur: %s\nLicense: %s\nSteam: %s\nDiscord: %s\n\nRECRUTER : \n\nJoueur: %s\nLicense: %s\nSteam: %s\nDiscord: %s\n\nDate: %s.%s.%s, Heure: %s:%s:%s"):format(xPlayer.getName(), xPlayer.getIdentifier(), GetPlayerIdentifier(source, 0), GetPlayerIdentifier(source, 2), xTarget.getName(), xTarget.getIdentifier(), GetPlayerIdentifier(target, 0), GetPlayerIdentifier(target, 2), date.day, date.month, date.year, date.hour, date.min, date.sec))
            else
                TriggerClientEvent('esx:showNotification', source, '(~r~Error~s~)\nVous ne pouvez pas autant promouvoir une personne.')
            end
        else
            TriggerClientEvent('esx:showNotification', source, '(~r~Error~s~)\nLa personne ne travaille pas dans cette entreprise.')
        end
    end
end)

RegisterNetEvent("xBoss:downGrade")
AddEventHandler("xBoss:downGrade", function(job, target)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(target)

    if (not xPlayer) then return end
    if (xPlayer.getJob().name) == job and (xPlayer.getJob().grade_name) == "boss" then
        if (xTarget.getJob().name) == job then
            local grade = xTarget.getJob().grade
            if grade > 0 then
                xTarget.setJob(job, (grade - 1))
                TriggerClientEvent('esx:showNotification', source, '(~g~Succès~s~)\nLa personne à été retrograder.')
                TriggerClientEvent('esx:showNotification', xTarget.source, '(~y~Information~s~)\nVous avez été retrograder.')
                sendToDiscordWithSpecialURL(0, ("Retrograder en tant que %s"):format(xTarget.getJob().grade_label), ("RECRUTEUR :\n\nJoueur: %s\nLicense: %s\nSteam: %s\nDiscord: %s\n\nRECRUTER : \n\nJoueur: %s\nLicense: %s\nSteam: %s\nDiscord: %s\n\nDate: %s.%s.%s, Heure: %s:%s:%s"):format(xPlayer.getName(), xPlayer.getIdentifier(), GetPlayerIdentifier(source, 0), GetPlayerIdentifier(source, 2), xTarget.getName(), xTarget.getIdentifier(), GetPlayerIdentifier(target, 0), GetPlayerIdentifier(target, 2), date.day, date.month, date.year, date.hour, date.min, date.sec))
            else
                TriggerClientEvent('esx:showNotification', source, '(~g~Error~s~)\nVous ne pouvez pas plus retrograder.')
            end
        else
            TriggerClientEvent('esx:showNotification', source, '(~r~Error~s~)\nLa personne ne travaille pas dans cette entreprise.')
        end
    end
end)

RegisterNetEvent("xBoss:leave")
AddEventHandler("xBoss:leave", function(job, target)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(target)

    if (not xPlayer) then return end
    if (xPlayer.getJob().name) == job and (xPlayer.getJob().grade_name) == "boss" then
        if (xTarget.getJob().name) == job then
            xTarget.setJob("unemployed", 0)
            TriggerClientEvent('esx:showNotification', source, '(~g~Succès~s~)\nLa personne à été licencier.')
            TriggerClientEvent('esx:showNotification', xTarget.source, '(~y~Information~s~)\nVous avez été licencier.')
            sendToDiscordWithSpecialURL(0, "Licenciement", ("RECRUTEUR :\n\nJoueur: %s\nLicense: %s\nSteam: %s\nDiscord: %s\n\nRECRUTER : \n\nJoueur: %s\nLicense: %s\nSteam: %s\nDiscord: %s\n\nDate: %s.%s.%s, Heure: %s:%s:%s"):format(xPlayer.getName(), xPlayer.getIdentifier(), GetPlayerIdentifier(source, 0), GetPlayerIdentifier(source, 2), xTarget.getName(), xTarget.getIdentifier(), GetPlayerIdentifier(target, 0), GetPlayerIdentifier(target, 2), date.day, date.month, date.year, date.hour, date.min, date.sec))
        else
            TriggerClientEvent('esx:showNotification', source, '(~r~Error~s~)\nLa personne ne travaille pas dans cette entreprise.')
        end
    end
end)

-- Employes

ESX.RegisterServerCallback("xBoss:getEmployes", function(source, cb, name)
    local send = {}
    MySQL.Async.fetchAll("SELECT firstname, lastname, job_grade FROM users WHERE job = @job", { ['@job'] = name }, function(result)
        if result ~= nil then
            for _,v in pairs(result) do
                MySQL.Async.fetchAll("SELECT label FROM job_grades WHERE job_name = @job_name AND grade = @grade", {
                    ['@job_name'] = name,
                    ['@grade'] = v.job_grade
                }, function(result2) 
                    for k, j in pairs(result2) do
                        table.insert(send, {firstname = v.firstname, lastname = v.lastname, grade = j.label})
                    end
                    Wait(1000)
                    cb(send)
                end)
            end
        end
    end)
end)

--- Xed#1188 | https://discord.gg/HvfAsbgVpM
