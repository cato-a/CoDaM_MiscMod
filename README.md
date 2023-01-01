# CoDaM MiscMod 3.0.x

## 0) DOWNLOAD

[CoDaM_MiscMod_v3.0.8_for_codextended](https://de.dvotx.org/dump/cod1/CoDaM_MiscMod_v3.0.8_for_codextended.zip)
 
## 1) HOW TO INSTALL

  Edit `codam\modlist.gsc`:
  ```gsc
  level.topText = &"<your text>";
  [[ register ]]( "Cato's MiscMod", codam\miscmod::main );
  ```

  File `miscmod_bans.dat` must be created in the main folder and writeable by the server (or it will crash).
  The ban capabilities is low level and intended only for small servers or single standalone servers.

  **NOTE:** Must be loaded before CoDaM_HamGoodies due to conflicting takeover (or any other mod for that matter).
  This mod is not made compatible with other mods and only compatible with CoDExtended as is by php.
  
  A full guide on how to configure and setup MiscMod can be found [here](https://cod.pm/guide/d0da8d/installing-and-configuring-codam-miscmod).

## 2) CONFIGURATION

  Some settings may support appending postfix to CVAR; such as `"scr_mm_spawnprotection_<MAP or GAMETYPE> <value>"` resulting in `"scr_mm_spawnprotection_dm <value>" or "scr_mm_spawnprotection_mp_brecourt <value>"`.
  
  See `CoDaM_MiscMod.cfg` file for CVAR documentation

## 3) COMMANDS

  NOTE: `<num>` can be replaced with text (e.g a playername) and a player number will be matched based on the string.

```plaintext
Command:                              Description:                                                Permission ID:

!login <user> <pass>                  Login to access commands.                                   0 - always default
!help                                 Display this help.                                          1 - default
!version                              Display MiscMod version.                                    2 - default
!name <new name>                      Change name.                                                3 - default
!fov <value>                          Set field of view.                                          4 - default
!rename <num> <new name>              Change name of a player.                                    5
!logout                               Logout.                                                     6
!say <message>                        Say a message with group as prefix.                         7
!saym <message>                       Print a message in the middle of the screen.                8
!sayo <message>                       Print a message in the obituary.                            9
!kick <reason>                        Kick a player.                                              10
!reload                               Reload MiscMod commands and settings.                       11
!restart (*)                          Restart map (soft).                                         12
!endmap                               End the map.                                                13
!map <mapname> (gametype)             Change map and gametype.                                    14
!status                               List players.                                               15
!mute <num>                           Mute player.                                                16
!unmute <num>                         Unmute player.                                              17
!warn <num> <message>                 Warn player.                                                18
!kill <num>                           Kill player.                                                19
!weapon <num> <weapon>                Give weapon to player.                                      20
!heal <num>                           Heal player.                                                21
!invisible <on|off>                   Become invisible.                                           22
!ban <num>                            Ban player.                                                 23
!unban <ip>                           Unban player.                                               24
!pm <player> <message>                Private message a player.                                   25
!re <message>                         Respond to private message.                                 26
!who                                  Display logged in users.                                    27

!drop <num> <height>                  Drop a player.                                              28
!spank <num> <time>                   Spank a player.                                             29
!slap <num> <damage>                  Slap a player.                                              30
!blind <num> <time>                   Blind a player.                                             31
!runover <num>                        Run over a player.                                          32
!squash <num>                         Squash a player.                                            33
!rape <num>                           Rape a player.                                              34
!toilet <num>                         Turn player into a toilet.                                  35

!explode <num>                        Explode a player.                                           36
!force <axis|allies|spectator> <num|all> (...)  Force players to team.                            37
!mortar <num>                         Mortar a player.                                            38
!matrix                               Matrix.                                                     39
!burn <num>                           Burn a player.                                              40
!cow <num>                            BBQ a player.                                               41
!disarm <num>                         Disarm a player.                                            42

!os                                   Snipers only.                                               43
!aw (*)                               All weapons (1 sniper).                                     44
!omp                                  Only machine guns.                                          45
!rifles <on|off|only>                 Rifle settings.                                             46
!health <off|0|1|2|3>                 Health settings.                                            47
!grenade <off|0|1|2|3|reset>          Grenade settings.                                           48
!pistols <on|off|reset>               Pistol settings.                                            49
!1sk <on|off>                         Enable or disable instant kill.                             50
!roundlength <time>                   Set roundlength. (sd|re)                                    51
!psk <on|off>                         Enable or disabl instant kill on pistols.                   52
!belmenu <on|off>                     Enable BEL menu instead of normal menu.                     53
!report <on|off>                      Report a player.                                            54
!plist                                List players without IP.                                    55
!rs                                   Reset your scores in the scoreboard.                        56
!optimize                             Change a players connection settings.                       57
!pcvar <num> <cmd> <value>            Change client cvars.                                        58
!respawn <num> <sd|dm|tdm>            Move player to a new spawnpoint.                            59
!wmap <wapon=map>                     Change CoDaM's weapon_map setting.                          60
!meleekill <on|off>                   Enable or disable scr_mm_meleekill.                         61
!teleport <num> (<num>|<x> <y> <z>)   Teleport a player to a player or (x, y, z) coordinates.     62
!teambalance <on|off|force>           Adjust team balance settings or force a team balance.       63
!swapteams                            Swap teams.                                                 64
!freeze <on|off> <num|all>            Freeze certain players (on the map).                        65
!move <num> <u|d|l|r|f|b> <units>     Move player in specified direction by specified units.      66
!scvar <cvar> <value>                 Set a server CVAR.                                          67
```

## 4) ABOUT

  This is a CoDaM PowerServer replacement aimed at improving stability and adding some different kind of features to CoDaM.

## 5) CREDITS

  - MiscMod made by Cato
  - Mapvote based on DaMoLe's mapvote for CoD2
  - Spawnfix based on LaZy's spawnfix for jump server
  - Some 'fun' admin commands based on Cheese's admin commands
  - Some 'fun' admin commands based on PowerServer's commands
  - BEL menus based on, in some parts on code by Indy's endless menu
  - CVAR `scr_mm_scoreboard_text` uses code from Defected (dftd)

## 6) CHANGELOG

  3.0.9
  * Fixed a problem with global `level.bans` when no users/groups set in MiscMod. (Thanks Cheese, for discovering this)
  * Minor adjustments to some messages in `_mm_commands.gsc`
  * Improved `!teleport` command
  * Added new command `!move`
  * Added new command `!scvar`
  * Login username is now case-insensitive
  * Improved `!help` command
  * Improved `command()` function log to include name, ip, args in server console
  * Improved `command()` function console messages in game

  3.0.8
  * Added new command `!teambalance <on|off|force>`
  * Added new command `!swapteams`
  * Fixes a bug in meleefight where people can drop their weapons right before the fight starts and pick it up again
  * Added new command `!freeze <on|off> <num|all>`
  * Corrected CVAR `scr_mm_msg1` and `2`, in `MiscMod.cfg`, to `scr_mm_msgb1` and `scr_mm_msgb2`
  * Added CVAR `scr_mm_emptymap`. When server is empty, switch to this map
  * Added CVAR `scr_mm_rename` and `scr_mm_renameto` which will rename a connecting player to a fixed name based on keywords
  * Added CVAR `scr_mm_removemaps_playercount`
  * Fix bug where a `!command <num>` would cause crash in some cases, discoverd by Frisky, reported and tested by AJ

  3.0.7
  * Adjusted `!pistols` command to include "chamber" or "clip" in case you want it to reload or not on spawn (`set scr_mm_allow_pistols_ammotype ""`)
  * Added new CVAR `scr_mm_meleekill_ignore` (values: `bolt`, `secondary`, `primary`, `grenade`). Requested by AJ
  * Improved `!mute` command with "list", to see muted players. (e.g `!mute list`)
  * Fixes bug with `!mute` command where some player ID was name causing some of the mutes not to be saved across maps
  * Fixes a typo in `!wmap` description and also fixes banned player display "Disconnected" instead of "Banned" when banned
  * Added new command `!teleport <player> (<player>|<x> <y> <z>)`
  * Fixes players getting stuck when spawning/moving to a player position, revamp of old code used to fix blocked spawnpoints etc

  3.0.6
  * Fixes rare race condition introduced in 3.0.5 for `!unban` command
  * Added new command `!wmap` to adjust CoDaM's weaponmap feature
  * Improvements to `!pistols` command, new arguments: `"on"`, `"empty"`, `"disable" `or a number of bullets in the chamber (e.g `!pistols 3`, for 3 bullets)
  * Minor adjustment to some commands code
  * Improvements to `validate_number()` function
  * Adjustments to BEL menu code
  * Workaround for CoDaM's weapon map code that force noMap under some conditions (`set scr_mm_wmap_force "1"` to enable) (the code is very hacky, don't use if you don't have to). Requested by TheGreatGatsby the ungrateful
  * Added new command `!meleekill <on|off>` to change instant kill on melee

  3.0.5
  * Need latest version of `codextended.so`: https://github.com/xtnded/codextended/blob/stable/bin/codextended.so
  * Cleanup some unused and commented code
  * Improvements to ban detection, banfile loading and `!ban`/`!unban` commands
  * Added dftd's `serverName()` function (e.g `scr_mm_scoreboard_text "^2My Server"` or change to `"namefix"` to remove squares and illegal chars)

  3.0.4
  * Added chat anti-spam. Requested by TheGreatGatsby
  * Fixes a bug with `!unban` command

  3.0.3
  * Updated `!who` and playerlist (when multiple matches found) to be more readable like `!status`
  * Fixes spawncamper headicon not displaying properly
  * Added `scr_mm_meleekill` for instant kill on melee

  3.0.2
  * Added `!respawn` command. This command will not respawn the player in full, just move the player to a new fresh spawnpoint (e.g to free stuck players)
  * Updated output of `!status` command to be more readable
  * Updated `!weapon` command to support partial names, grenades and pistols (e.g `!weapon 5 nagant_sniper`). Requested by hehu
  * Improved spawn protection with new code from funmod
  * Fixes server crash on player disconnect using some of Cheese's commands

  3.0.1
  * Added additional cvars to `scr_mm_cmd_maps`, you can now append 1, 2, 3, etc at end for more maps (e.g `"scr_mm_cmd_maps1"`)
  * Optimized `namefix()` function

  2.7.9
  * Commands have new numbers, permissions must be updated
  * Fixes issue with 999 kicker and clients download maps (999 kicker auto disables)
  * Fixes bug in `strTok` function that causes a crash on double, tripple delimiters, etc
  * Recoded `msgBroadcast` function to follow a queue of messages regardless or round/map changes
  * Added `!pcvar` command
  * Removed `!fps` command (can be used with `!pcvar` instead, e.g `!pcvar <num> fps 125`)
  * Fixes `!help` command booting client after 85+ commands

  2.7.8
  * Fixes bug regarding banfile (does not happen in normal mode, only developer)
  * Fixes bug with localized string, hud, freezing on menu
  * Added an extra check to `!re` command
  * Added `!report` that writes to `miscmod_reports.dat` (copy from momo74 code, which is basically my code)
  * Fixes bug with BEL menu
  * Added `scr_mm_badwords<1,2,...>` CVAR and badwords - requested by ImNoob
  * Added `scr_mm_badwords_checknames` to check if also names contain badwords
  * Added `!rs`, `!fps`, `!optimize` commands by momo74
  * Added minor tweaks to INFO messages by momo74
  * Added `!plist` command, it does the same as momo74's `!num` command, which does the same as `!status` command without IP address
  * Added logging to `!unban` and commands (to console/logfile)

  2.7.7
  * Added logging to `!login` command, now server admin can see who is using the `!login` command
  * Added server messages that can be broadcast to console, center or obituary

  2.7.6
  * Fixes issue when `scr_mm_nnn` is set to 0 and instant drop client. When set to 0, it will now disable the 999 check.
  * Fixes issue with bel menu not working when having rcon tool in game client
  * Fixes issue with instantkill and pistolkill instantly kill people using melee
  * Fixes issues with !help displaying more than 60 commands
  * Added `!ban <num|name|ip> <reason> [<specify this argument to enable IP ban>]` to old `!ban` command

  2.7.5
  * Added 1 shot kill pistol option
  * Added `!psk` command
  * Added optional show IP in `!status` command
  * Integrated Endless Menu into MiscMod per requests
  * Changed the bottom MiscMod version text
  * Added `!belmenu` command

  2.7.4
  * Spawn protection
  * RCM compatibility

  2.7.3
  * Commands have new numbers, permissions must be updated
  * Added `!who` command to display who is logged in
  * Added `!pm` command
  * Added `!re` command
  * Added 999 kicker based on timer

  2.7.2
  * Added option for rifles only to `!rifles` command
  * Fixes problem with instantkill and damagemarker enabled at the same time (negative value)
  * Minor code cleanup

  2.7.1
  * Fixes bug with current working directory, default is now set to `fs_basepath` + `"/main/"`
  * New CVAR to specify a different working directory or share the same directory
