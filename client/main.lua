ESX = nil
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

local ownedWells = {}

local function CreateOilWellBlips()
    for _, location in ipairs(Config.OilWellLocations) do
        local blip = AddBlipForCoord(location.coords.x, location.coords.y, location.coords.z)
        SetBlipSprite(blip, Config.Blip.sprite)
        SetBlipColour(blip, Config.Blip.color)
        SetBlipScale(blip, Config.Blip.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(Config.Blip.label)
        EndTextCommandSetBlipName(blip)
    end
end

local function OwnsWell(wellIndex)
    return ownedWells[wellIndex] == true
end

local function OpenManagementMenu(wellIndex)
    lib.registerContext({
        id = 'oil_well_management_'..wellIndex,
        title = 'Oliepomp Beheer',
        options = {
            {
                title = 'Oliepomp Informatie',
                description = ('Verdient $%s elke %s minuten'):format(Config.IncomeAmount, Config.IncomeInterval),
                icon = 'info-circle',
                disabled = true
            },
            {
                title = 'Verkoop Oliepomp',
                description = ('Verkoop deze oliepomp voor $%s'):format(Config.OilWellPrice * 0.7),
                icon = 'money-bill',
                onSelect = function()
                    TriggerServerEvent('KJ-Oliepomp:sellWell', wellIndex)
                end
            }
        }
    })

    lib.showContext('oil_well_management_'..wellIndex)
end

local function OpenPurchaseMenu(wellIndex)
    lib.registerContext({
        id = 'oil_well_purchase_'..wellIndex,
        title = 'Oliepomp Aankoop',
        options = {
            {
                title = 'Koop Oliepomp',
                description = ('Koop deze oliepomp voor $%s'):format(Config.OilWellPrice),
                icon = 'oil-well',
                onSelect = function()
                    TriggerServerEvent('KJ-Oliepomp:purchaseWell', wellIndex)
                end
            }
        }
    })

    lib.showContext('oil_well_purchase_'..wellIndex)
end

CreateThread(function()
    CreateOilWellBlips()

    while true do
        Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local letSleep = true

        for index, location in ipairs(Config.OilWellLocations) do
            local distance = #(playerCoords - location.coords)

            if distance < 10.0 then
                letSleep = false
                DrawMarker(2, location.coords.x, location.coords.y, location.coords.z + 1.0,
                    0.0, 0.0, 0.0, 0.0, 180.0, 0.0,
                    0.3, 0.3, 0.3,
                    50, 200, 50, 200,
                    true, true, 2, nil, nil, false)

                if distance < 1.5 then
                    lib.showTextUI('[E] - Open Oliepomp Menu')

                    if IsControlJustReleased(0, 38) then
                        lib.hideTextUI()
                        if OwnsWell(index) then
                            OpenManagementMenu(index)
                        else
                            OpenPurchaseMenu(index)
                        end
                    end
                else
                    lib.hideTextUI()
                end
            end
        end

        if letSleep then
            Wait(500)
        end
    end
end)

RegisterNetEvent('KJ-Oliepomp:updateOwnedWells')
AddEventHandler('KJ-Oliepomp:updateOwnedWells', function(wells)
    ownedWells = wells
end)

RegisterNetEvent('KJ-Oliepomp:notify')
AddEventHandler('KJ-Oliepomp:notify', function(data)
    lib.notify(data)
end)