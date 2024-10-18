local ox_lib = exports.ox_lib
local Config = require 'config'
local pickpocketedNPCs = {}
local playerCooldowns = {}



local function SelectLoot()
    local roll = math.random(100)
    local cumulativeChance = 0
    
    for tier, chance in pairs(Config.LootChances) do
        cumulativeChance = cumulativeChance + chance
        if roll <= cumulativeChance then
            if tier == 'nothing' then
                return nil
            else
                return Config.LootTables[tier][math.random(#Config.LootTables[tier])]
            end
        end
    end
end

local function IsEntityValid(entity)
    return DoesEntityExist(entity) and not IsPedAPlayer(entity)
end

lib.callback.register('pickpocket:attemptPickpocket', function(source, targetNetId)
    local src = source
    local targetPed = NetworkGetEntityFromNetworkId(targetNetId)

    if not IsEntityValid(targetPed) then 
        return false, 'Invalid target'
    end

    if pickpocketedNPCs[targetNetId] then
        return false, 'This person has already been pickpocketed!'
    end

    local currentTime = GetGameTimer()
    if playerCooldowns[src] and currentTime - playerCooldowns[src] < Config.PickpocketCooldown then
        local remainingTime = math.ceil((Config.PickpocketCooldown - (currentTime - playerCooldowns[src])) / 1000)
        return false, string.format('You must wait %d seconds before pickpocketing again!', remainingTime)
    end

    pickpocketedNPCs[targetNetId] = true
    playerCooldowns[src] = currentTime
    
    return true
end)

lib.callback.register('pickpocket:success', function(source)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    
    if not player then 
        return false, 'Player not found'
    end

    local loot = SelectLoot()
    if not loot then
        return true, 'You found nothing.'
    end

    if loot.type == 'cash' then
        local amount = math.random(loot.min, loot.max)
        player.Functions.AddMoney('cash', amount)
        return true, string.format('You pickpocketed $%d!', amount)
    elseif loot.type == 'item' then
        local success = player.Functions.AddItem(loot.name, loot.amount)
        if success then
            return true, string.format('You pickpocketed %dx %s!', loot.amount, loot.name)
        else
            return false, 'Your pockets are full!'
        end
    end
end)