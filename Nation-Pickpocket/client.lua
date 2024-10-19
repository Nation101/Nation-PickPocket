local Config = require 'config'

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

local function StartPickpocketMinigame()
    local minigameType = Config.Minigame.type
    local params = Config.Minigame.params[minigameType]
    
    local minigameFunction = minigameFunctions[minigameType]
    if minigameFunction then
        return minigameFunction(params)
    else
        return false
    end
end

local function IsPlayerArmed()
    local ped = PlayerPedId()
    return IsPedArmed(ped, 7)
end

local function IsEntityValid(entity)
    return entity ~= nil and DoesEntityExist(entity) and not IsPedAPlayer(entity)
end

local function AlertPolice(targetPed)
    if math.random(100) > Config.PoliceDispatch.chanceToAlert then
        return
    end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local targetCoords = GetEntityCoords(targetPed)

    if Config.PoliceDispatch.system == 'PS' then
        exports['ps-dispatch']:SuspiciousActivity()
    elseif Config.PoliceDispatch.system == 'Custom' then
        CustomPoliceDispatch(playerCoords, targetCoords)
    end
end
local function PlaySearchAnimation()
    local playerPed = PlayerPedId()
    local dict = "amb@prop_human_bum_bin@base"
    local anim = "base"

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end

    TaskPlayAnim(playerPed, dict, anim, 8.0, -8.0, -1, 1, 0, false, false, false)
end

local function StopSearchAnimation()
    local playerPed = PlayerPedId()
    ClearPedTasks(playerPed)
end

local function IsPedFacingAway(ped, playerPed)
    local pedHeading = GetEntityHeading(ped)
    local playerHeading = GetEntityHeading(playerPed)
    local headingDiff = math.abs(pedHeading - playerHeading)
    return headingDiff <= 90 or headingDiff >= 270
end

local function FreezeNPC(npc)
    if not IsEntityValid(npc) then return end
    NetworkRequestControlOfEntity(npc)
    SetEntityInvincible(npc, true)
    SetPedCanRagdoll(npc, false)
    ClearPedTasksImmediately(npc)
    SetBlockingOfNonTemporaryEvents(npc, true)
    TaskStandStill(npc, -1)
end

local function UnfreezeNPC(npc)
    if not IsEntityValid(npc) then return end
    NetworkRequestControlOfEntity(npc)
    SetEntityInvincible(npc, false)
    SetPedCanRagdoll(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, false)
    ClearPedTasksImmediately(npc)
end

local function NPCAttackPlayer(npc)
    if not IsEntityValid(npc) then return end
    UnfreezeNPC(npc)
    ClearPedTasksImmediately(npc)
    RemoveAllPedWeapons(npc, true)
    SetPedRelationshipGroupHash(npc, GetHashKey('HATES_PLAYER'))
    SetPedCombatAttributes(npc, 46, true)  -- BF_CanFightArmedPedsWhenNotArmed
    SetPedCombatAttributes(npc, 5, true)   -- BF_AlwaysFight
    SetPedCombatAttributes(npc, 0, false)  -- BF_CanUseCover
    SetPedCombatAttributes(npc, 50, true)   -- Bum Rush the player

    local weaponHash = GetHashKey(Config.npcWeapon)
    GiveWeaponToPed(npc, weaponHash, 1000, false, true)
    SetCurrentPedWeapon(npc, weaponHash, true)
    SetPedCombatMovement(npc, 3)  -- Aggressive
    SetPedCombatRange(npc, 2)     -- Medium range
    TaskCombatPed(npc, PlayerPedId(), 0, 16)
    SetPedFleeAttributes(npc, 0, false)
    SetPedCombatAttributes(npc, 17, false)  -- BF_DisableFleeFromCombat
end

--[[local function NPCFlee(npc)
    if not IsEntityValid(npc) then return end
    UnfreezeNPC(npc)
    TaskSmartFleePed(npc, PlayerPedId(), 100.0, -1, false, false)
end]]

local function ShouldShowPickpocketOption(entity)
    local playerPed = PlayerPedId()
    return IsPlayerArmed() and IsEntityValid(entity) and IsPedFacingAway(entity, playerPed)
end

lib.callback.register('pickpocket:getStreetName', function(coords)
    local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    return GetStreetNameFromHashKey(streetHash)
end)


exports.ox_target:addGlobalPed({
    {
        name = 'pickpocket_ped',
        icon = 'fas fa-hand-paper',
        label = 'Pickpocket',
        distance = 1.0,
        canInteract = ShouldShowPickpocketOption,
        onSelect = function(data)
            if not data or not data.entity or not IsEntityValid(data.entity) then
                lib.notify({description = 'Invalid target!', type = 'error'})
                return
            end

            local targetPed = data.entity
            local canPickpocket, message = lib.callback.await('pickpocket:attemptPickpocket', false, NetworkGetNetworkIdFromEntity(targetPed))
            
            if canPickpocket then
                FreezeNPC(targetPed)
                PlaySearchAnimation()  -- Start the search animation before the minigame
                if StartPickpocketMinigame() then
                    if IsEntityValid(targetPed) then
                        if lib.progressBar({
                            duration = 5000,
                            label = 'Searching...',
                            useWhileDead = false,
                            canCancel = true,
                            disable = {
                                car = true,
                                move = true,
                                combat = true,
                            },
                        }) then
                            StopSearchAnimation()
                            local success, result = lib.callback.await('pickpocket:success', false)
                            if success then
                                lib.notify({description = result, type = 'success'})
                                AlertPolice(targetPed)
                                --NPCFlee(targetPed)
                            else
                                lib.notify({description = result or 'Pickpocket failed!', type = 'error'})
                                NPCAttackPlayer(targetPed)
                            end
                        else
                            StopSearchAnimation()
                            lib.notify({description = 'Pickpocket cancelled!', type = 'error'})
                            NPCAttackPlayer(targetPed)
                        end
                    else
                        StopSearchAnimation()
                        lib.notify({description = 'Target no longer valid!', type = 'error'})
                    end
                else
                    StopSearchAnimation()
                    lib.notify({description = 'Pickpocket failed!', type = 'error'})
                    NPCAttackPlayer(targetPed)
                end
            else
                lib.notify({description = message, type = 'error'})
            end
        end
    }
})

print("Pickpocket client script loaded successfully!")