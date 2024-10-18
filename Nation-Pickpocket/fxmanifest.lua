fx_version 'cerulean'
game 'gta5'

author '#xdNation'
description 'Pickpocket script for FiveM QBOX'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'qbx_core',
    'ox_lib',
    'ox_target',
    'sp-minigame'
}

lua54 'yes'