local ESX = nil
local PlayerData = {}
local currentChannel = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

function OpenRadioMenu()
    local elements = {}

    ESX.TriggerServerCallback('radio:getChannels', function(channels)
        for i=1, #channels, 1 do
            table.insert(elements, {label = channels[i].name, value = channels[i].frequency})
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'radio_menu', {
            title    = 'Radio Channels',
            align    = 'top-left',
            elements = elements
        }, function(data, menu)
            currentChannel = data.current.value
            TriggerServerEvent('radio:joinChannel', currentChannel)
            menu.close()
        end, function(data, menu)
            menu.close()
        end)
    end)
end

RegisterCommand('radio', function(source, args, rawCommand)
    OpenRadioMenu()
end, false)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if currentChannel ~= nil then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)

            for _, player in ipairs(GetActivePlayers()) do
                local targetPed = GetPlayerPed(player)
                local targetCoords = GetEntityCoords(targetPed)
                local distance = #(playerCoords - targetCoords)

                if distance <= Config.RadioRange then
                    NetworkSetVoiceChannel(currentChannel)
                    NetworkSetTalkerProximity(Config.RadioRange)
                else
                    NetworkSetVoiceChannel(0)
                end
            end
        end
    end
end)