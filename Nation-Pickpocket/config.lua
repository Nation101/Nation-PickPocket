Config = {}

Config.PoliceDispatch = {
    system = 'PS', -- Options: 'QBX', 'PS (PS-Dispatch)', 'Custom'
    chanceToAlert = 100 -- Percentage chance of alerting police (0-100)
}

-- Loot tables
Config.LootTables = {
    common = {
        { type = 'item', name = 'burger', amount = 1 },
        { type = 'item', name = 'water', amount = 1 },
        { type = 'cash', min = 10, max = 50 }
    },
    rare = {
        { type = 'item', name = 'lockpick', amount = 1 },
        { type = 'item', name = 'phone', amount = 1 },
        { type = 'cash', min = 50, max = 200 }
    },
    ultraRare = {
        { type = 'item', name = 'goldbar', amount = 1 },
        { type = 'item', name = 'diamond', amount = 1 },
        { type = 'cash', min = 200, max = 500 }
    }
}

-- Loot probabilities (customize these as needed)
Config.LootChances = {
    nothing = 20,  -- 20% chance of getting nothing
    common = 60,   -- 60% chance of common loot
    rare = 15,     -- 15% chance of rare loot
    ultraRare = 5  -- 5% chance of ultra-rare loot
}

Config.Minigame = {
    type = 'SkillBar', -- Change this to select different minigames
    params = {
        MemoryGame = {keysNeeded = 3, rounds = 2, time = 10000},
        NumberUp = {keys = 28, rounds = 2, tries = 2, time = 40000, shuffleTime = 20000},
        SkillCheck = {speed = 50, time = 5000, keys = {'w','a','s','d'}, rounds = 2, bars = 20, safebars = 3},
        Thermite = {boxes = 7, correctboxes = 5, time = 10000, lifes = 2, rounds = 2, showTime = 3000},
        SkillBar = {duration = {2000, 3000}, width = 10, rounds = 2},
        KeyPad = {code = 999, time = 3000},
        ColorPicker = {icons = 3, typeTime = 7000, viewTime = 3000},
        MemoryCards = {difficulty = 'medium', rounds = 1},
        Mines = {boxes = 5, lifes = 3, mines = 9, special = 1}
    }
}

-- Progress bar configuration
Config.ProgressBar = {
    duration = 5000,
    label = 'Pickpocketing...',
    useWhileDead = false,
    canCancel = true,
    disable = {
        car = true,
        move = true,
        combat = true,
    },
    anim = {
        dict = 'mp_common',
        clip = 'givetake1_a'
    },
}

Config.PickpocketCooldown = 30000 -- 30 seconds

return Config