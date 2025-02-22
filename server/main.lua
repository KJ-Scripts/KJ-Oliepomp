ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local ownedWells = {}

local function SaveWells()
    MySQL.Async.execute('CREATE TABLE IF NOT EXISTS `KJ-Oliepomp` (owner VARCHAR(50), well_index INT)', {}, function(success)
        if not success then
            print('^1Error met de database!^7')
            return
        end

        MySQL.Async.execute('DELETE FROM `KJ-Oliepomp`', {}, function(success)
            if not success then
                print('^1Error met de database^7')
                return
            end

            for owner, wells in pairs(ownedWells) do
                for wellIndex, _ in pairs(wells) do
                    MySQL.Async.execute('INSERT INTO `KJ-Oliepomp` (owner, well_index) VALUES (@owner, @well_index)', {
                        ['@owner'] = owner,
                        ['@well_index'] = wellIndex
                    }, function(success)
                        if not success then
                            print('^1Error met opslaan van: ' .. owner .. '^7')
                        end
                    end)
                end
            end
        end)
    end)
end

local function LoadWells()
    MySQL.Async.fetchAll('SELECT * FROM `KJ-Oliepomp`', {}, function(results)
        if not results then
            print('^1Error met pompen inladen^7')
            return
        end

        for _, result in ipairs(results) do
            if not ownedWells[result.owner] then
                ownedWells[result.owner] = {}
            end
            ownedWells[result.owner][result.well_index] = true
        end
        print('^2Succesvol ' .. #results .. ' oliepompen uit de database gehaald^7')
    end)
end

local function GenerateIncome()
    for owner, wells in pairs(ownedWells) do
        local xPlayer = ESX.GetPlayerFromIdentifier(owner)
        if xPlayer then
            local wellCount = 0
            for _ in pairs(wells) do
                wellCount = wellCount + 1
            end

            local income = wellCount * Config.IncomeAmount
            local success = pcall(function()
                xPlayer.addMoney(income)
            end)

            if success then
                TriggerClientEvent('KJ-Oliepomp:notify', xPlayer.source, {
                    description = ('Je hebt $%s verdiend met je %d oliepompen'):format(income, wellCount),
                    type = 'success'
                })
            else
                print('^1Error met het geven van geld aan: ' .. owner .. '^7')
            end
        end
    end
end

local function IsWellOwned(wellIndex)
    for _, wells in pairs(ownedWells) do
        if wells[wellIndex] then
            return true
        end
    end
    return false
end

CreateThread(function()
    LoadWells()

    while true do
        Wait(Config.IncomeInterval * 60 * 1000)
        GenerateIncome()
    end
end)

RegisterServerEvent('KJ-Oliepomp:purchaseWell')
AddEventHandler('KJ-Oliepomp:purchaseWell', function(wellIndex)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then return end

    if IsWellOwned(wellIndex) then
        TriggerClientEvent('KJ-Oliepomp:notify', source, {
            description = 'Deze oliepomp is al in gebruik!',
            type = 'error'
        })
        return
    end

    if xPlayer.getMoney() >= Config.OilWellPrice then
        local success = pcall(function()
            xPlayer.removeMoney(Config.OilWellPrice)
        end)

        if not success then
            TriggerClientEvent('KJ-Oliepomp:notify', source, {
                description = 'Transactie mislukt!',
                type = 'error'
            })
            return
        end

        if not ownedWells[xPlayer.identifier] then
            ownedWells[xPlayer.identifier] = {}
        end

        ownedWells[xPlayer.identifier][wellIndex] = true
        SaveWells()

        TriggerClientEvent('KJ-Oliepomp:notify', source, {
            description = ('Gefeliciteerd! Je hebt oliepomp #%d gekocht voor $%s'):format(wellIndex, Config.OilWellPrice),
            type = 'success'
        })

        TriggerClientEvent('KJ-Oliepomp:updateOwnedWells', source, ownedWells[xPlayer.identifier])
    else
        TriggerClientEvent('KJ-Oliepomp:notify', source, {
            description = 'Je hebt niet genoeg geld voor deze oliepomp!',
            type = 'error'
        })
    end
end)

RegisterServerEvent('KJ-Oliepomp:sellWell')
AddEventHandler('KJ-Oliepomp:sellWell', function(wellIndex)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then return end

    if not ownedWells[xPlayer.identifier] or not ownedWells[xPlayer.identifier][wellIndex] then
        TriggerClientEvent('KJ-Oliepomp:notify', source, {
            description = 'Je bezit deze oliepomp niet!',
            type = 'error'
        })
        return
    end

    -- De verkoop prijs
    local sellPrice = Config.OilWellPrice * 0.5

    ownedWells[xPlayer.identifier][wellIndex] = nil

    local hasWells = false
    for _ in pairs(ownedWells[xPlayer.identifier]) do
        hasWells = true
        break
    end
    if not hasWells then
        ownedWells[xPlayer.identifier] = nil
    end

    SaveWells()

    local success = pcall(function()
        xPlayer.addMoney(sellPrice)
    end)

    if success then
        TriggerClientEvent('KJ-Oliepomp:notify', source, {
            description = ('Je hebt oliepomp #%d verkocht voor $%s'):format(wellIndex, sellPrice),
            type = 'success'
        })
    else
        TriggerClientEvent('KJ-Oliepomp:notify', source, {
            description = 'Transactie mislukt!',
            type = 'error'
        })
        if not ownedWells[xPlayer.identifier] then
            ownedWells[xPlayer.identifier] = {}
        end
        ownedWells[xPlayer.identifier][wellIndex] = true
        SaveWells()
        return
    end

    TriggerClientEvent('KJ-Oliepomp:updateOwnedWells', source, ownedWells[xPlayer.identifier] or {})
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        SaveWells()
    end
end)