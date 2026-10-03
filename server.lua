local ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('radio:getChannels', function(source, cb)
    MySQL.Async.fetchAll('SELECT * FROM radio_channels', {}, function(result)
        cb(result)
    end)
end)

RegisterNetEvent('radio:joinChannel')
AddEventHandler('radio:joinChannel', function(channel)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier

    MySQL.Async.execute('INSERT INTO player_radios (player_id, channel_id) VALUES (@player_id, (SELECT id FROM radio_channels WHERE frequency = @frequency))', {
        ['@player_id'] = identifier,
        ['@frequency'] = channel
    }, function(rowsChanged)
        if rowsChanged > 0 then
            TriggerClientEvent('esx:showNotification', source, 'Joined radio channel ' .. channel)
        else
            TriggerClientEvent('esx:showNotification', source, 'Failed to join radio channel')
        end
    end)
end)

-- Initialize default channels
Citizen.CreateThread(function()
    for i=1, #Config.DefaultChannels, 1 do
        MySQL.Async.execute('INSERT IGNORE INTO radio_channels (name, frequency) VALUES (@name, @frequency)', {
            ['@name'] = Config.DefaultChannels[i].name,
            ['@frequency'] = Config.DefaultChannels[i].frequency
        })
    end
end)