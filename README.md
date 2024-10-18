# Nation-Pickpocket

Adds pickpocketing to your QBX server. Players can rob NPCs, with configurable minigames and loot.

## Features
- NPC pickpocketing via ox_target
- Configurable minigames (uses sp-minigame)
- Custom loot tables
- Police alerts (supports QBX, PS-Dispatch, or custom)

## Requirements
- QBX Core
- ox_lib
- ox_target
- sp-minigame (paid resource)

## Setup

1. Drag and drop  sp-minigame and Nation-Pickpocket in your resources folder
2. Add to server.cfg:
   ```
   ensure sp-minigame
   ensure Nation-Pickpocket
   ```
3. Tweak config.lua to your liking

## Configuration

Edit config.lua to change:
- Loot tables
- Minigame settings
- Police dispatch options
- Cooldowns

## Usage

Target an NPC, select "Pickpocket", complete the minigame. Simple as that!

## Notes
Questions? Open an issue or hit me up on Discord. #xdNation

Enjoy your new pickpocket system!
