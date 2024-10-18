local Config = require 'config'

local function IsPlayerArmed()
    local ped = PlayerPedId()
    return IsPedArmed(ped, 7)
end

lib.callback.register('pickpocket:getStreetName', function(coords)
    local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    return GetStreetNameFromHashKey(streetHash)
end)

local function AlertPolice(targetPed)
    if math.random(100) > Config.PoliceDispatch.chanceToAlert then
        return -- Don't alert if random chance fails
    end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local targetCoords = GetEntityCoords(targetPed)

    if Config.PoliceDispatch.system == 'QBX' then
        -- Using QBX Police system
        TriggerEvent('police:client:policeAlert', 'Pickpocketing in progress', playerCoords, true)
    elseif Config.PoliceDispatch.system == 'PS' then
        exports['ps-dispatch']:SuspiciousActivity()
    elseif Config.PoliceDispatch.system == 'Custom' then
        CustomPoliceDispatch(playerCoords, targetCoords)
    else
        print("Invalid or unconfigured police dispatch system")
    end
end


-- Table of minigame functions
local minigameFunctions = {
    MemoryGame = function(params)
        return exports['sp-minigame']:MemoryGame(params.keysNeeded, params.rounds, params.time)
    end,
    NumberUp = function(params)
        return exports['sp-minigame']:NumberUp(params.keys, params.rounds, params.tries, params.time, params.shuffleTime)
    end,
    SkillCheck = function(params)
        return exports['sp-minigame']:SkillCheck(params.speed, params.time, params.keys, params.rounds, params.bars, params.safebars)
    end,
    Thermite = function(params)
        return exports['sp-minigame']:Thermite(params.boxes, params.correctboxes, params.time, params.lifes, params.rounds, params.showTime)
    end,
    SkillBar = function(params)
        return exports['sp-minigame']:SkillBar(params.duration, params.width, params.rounds)
    end,
    KeyPad = function(params)
        return exports['sp-minigame']:KeyPad(params.code, params.time)
    end,
    ColorPicker = function(params)
        return exports['sp-minigame']:ColorPicker(params.icons, params.typeTime, params.viewTime)
    end,
    MemoryCards = function(params)
        return exports['sp-minigame']:MemoryCards(params.difficulty, params.rounds)
    end,
    Mines = function(params)
        local multiplier = exports['sp-minigame']:Mines(params.boxes, params.lifes, params.mines, params.special)
        return multiplier and multiplier > 0
    end
}

-- Function to start pickpocket minigame
local function StartPickpocketMinigame()
    local minigameType = Config.Minigame.type
    local params = Config.Minigame.params[minigameType]
    
    local minigameFunction = minigameFunctions[minigameType]
    if minigameFunction then
        return minigameFunction(params)
    else
        print("Invalid minigame type selected:", minigameType)
        return false
    end
end

-- Function to show loading bar
local function ShowLoadingBar()
    return lib.progressBar({
        duration = Config.ProgressBar.duration,
        label = Config.ProgressBar.label,
        useWhileDead = Config.ProgressBar.useWhileDead,
        canCancel = Config.ProgressBar.canCancel,
        disable = Config.ProgressBar.disable,
        anim = {
            dict = Config.ProgressBar.anim.dict,
            clip = Config.ProgressBar.anim.clip
        },
    })
end

-- Function to check if an entity is valid
local function IsEntityValid(entity)
    return DoesEntityExist(entity) and not IsPedAPlayer(entity)
end

-- Register ox_target interaction
exports.ox_target:addGlobalPed({
    {
        name = 'pickpocket_ped',
        icon = 'fas fa-hand-paper',
        label = 'Pickpocket',
        canInteract = function(entity, distance, coords, name)
            return IsPlayerArmed() and IsEntityValid(entity)
        end,
        onSelect = function(data)
            if not data or not data.entity or not IsEntityValid(data.entity) then
                lib.notify({description = 'Invalid target!', type = 'error'})
                return
            end

            local targetPed = data.entity
            local canPickpocket, message = lib.callback.await('pickpocket:attemptPickpocket', false, NetworkGetNetworkIdFromEntity(targetPed))
            
            if canPickpocket then
                -- Alert police here, after a successful pickpocket attempt

                
                if StartPickpocketMinigame() then
                    if IsEntityValid(targetPed) and ShowLoadingBar() then
                        local success, result = lib.callback.await('pickpocket:success', false)
                        if success then
                            lib.notify({description = result, type = 'success'})
                            AlertPolice(targetPed)
                        else
                            lib.notify({description = result or 'Pickpocket failed!', type = 'error'})
                        end
                    else
                        lib.notify({description = 'Pickpocket cancelled or target no longer valid!', type = 'error'})
                    end
                else
                    lib.notify({description = 'Pickpocket failed!', type = 'error'})
                end
            else
                lib.notify({description = message, type = 'error'})
            end
        end
    }
})

print("Pickpocket client script loaded successfully!")