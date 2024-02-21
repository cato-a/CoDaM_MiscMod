/********************************************
    Miscellaneous things for CoDaM by Cato
    See README file for details
********************************************/

main(phase, register)
{
    codam\utils::debug(0, "======== MiscMod/main:: |", phase, "|", register, "|");

    if(!codam\utils::getVar("scr", "miscmod", "bool", 1|2, false))
        return;

    switch(phase) {
        case "init":
            _init(register);
        break;
        case "load":
            _load();
        break;
        case "start":
            _start();
        break;
    }

    return;
}

_init(register)
{
    codam\utils::debug(0, "======== MiscMod/_init:: |", register, "|");

    if(isDefined(level.modbycato1))
        return;

    level.modbycato1 = true;

    // reset welcome messages / mapvote
    [[ register ]]("gt_endMap", ::endMap, "takeover");

    // instant kill / hitmarker / damagemarker / shellshock
    [[ register ]]("finishPlayerDamage", ::_finishPlayerDamage, "takeover");

    // anticamper / spawnpoint fix
    [[ register ]]("spawnPlayer", ::spawnPlayer, "takeover");

    // square name fix / ban player
    [[ register ]]("PlayerConnect",	::PlayerConnect, "takeover");
    [[ register ]]("PlayerDisconnect", ::PlayerDisconnect, "takeover");
    [[ register ]]("printJoinedTeam", ::printJoinedTeam, "takeover");

    // restrict weapons (ujjuwal request)
    [[ register ]]("assignWeapon", ::assignWeapon, "takeover");

    // workaround for CoDaM's weapon map forcing noMap under some conditions
    [[ register ]]("assignWeaponSlot", ::assignWeaponSlot, "takeover");

    // meleefight - roundclock timer
    [[ register ]]("roundClock", ::roundClock, "takeover");
    [[ register ]]("gt_startRound", ::startRound, "takeover");

    // server messages
    if(codam\utils::getVar("scr_mm", "msgb_enable", "bool", 0, false))
        [[ register ]]("StartGameType", ::msgBroadcast, "thread");

    level.badnametime = codam\utils::getVar("scr_mm", "badwords_checknames", "int", 0, 0);
    if(level.badnametime > 0)
        [[ register ]]("StartGameType", ::badnames, "thread");

    // !pistols / !grenade / allow_grenades / allow_pistols
    [[ register ]]("givePistol", ::givePistol, "takeover");
    [[ register ]]("giveGrenade", ::giveGrenade, "takeover");

    // quickcommands antispam
    [[ register ]]("quickmenu", ::quick, "takeover");

    // welcome messages
    [[ register ]]("spawnPlayer", ::welcome_display, "thread");
    [[ register ]]("PlayerDisconnect", ::welcome_remove, "thread");

    // anti fast fire
    [[ register ]]("spawnPlayer", ::antiFF, "thread");

    // weapon32
    [[ register ]]("spawnPlayer", ::weapon32, "thread");

    // MiscMod keys
    [[ register ]]("PlayerConnect",	::mmKeys, "thread");

    // 999 kicker
    [[ register ]]("PlayerConnect",	::nnn, "thread");

    // Fix spawnIntermission from CoDaM
    [[ register ]]("gt_spawnIntermission", ::spawnIntermission, "takeover");

    level.ingamecommands = codam\utils::getVar("scr_mm", "commands", "bool", 0, false);
    if(level.ingamecommands) {
        [[ register ]]("PlayerDisconnect", codam\_mm_commands::_delete, "thread");
        [[ register ]]("PlayerConnect", codam\_mm_commands::_checkMuted, "thread");
        [[ register ]]("PlayerConnect", codam\_mm_commands::_checkLoggedIn, "thread");
        [[ register ]]("PlayerConnect", codam\_mm_commands::_checkFOV, "thread");
    }

    level.maxmessages = codam\utils::getVar("scr_mm", "chat_maxmessages", "int", 0, 0);
    if(level.maxmessages > 0)
        level.penaltytime = codam\utils::getVar("scr_mm", "chat_penaltytime", "int", 0, 2);

    return;
}

_load()
{
    codam\utils::debug(0, "======== MiscMod/_load");

    if(isDefined(level.modbycato2))
        return;

    level.modbycato2 = true;

    // MiscMod huds
    // Used to concatenate localized strings, but show error or freeze server
    // e.g &"string one" + level.stringTwo
    // pair has unmatching types 'localized string' and 'localized string'
    // Reported by ImNoob
    if(!isDefined(level.topText))
        level.topText = &"^1MiscMod ^3v3.1.4";

    level.originalBottomText = &"^1+ ^5MiscMod ^3v3.1.4";

    if(!isDefined(game["gamestarted"])) {
        precacheString(level.topText);
        precacheString(level.originalBottomText);

        if(isDefined(level.bottomText))
            precacheString(level.bottomText);
    }

    // hitmarker
    precacheShader("gfx/hud/hud@fire_ready.tga");

    // shellshock
    precacheShellshock("groggy");
    precacheShellShock("pain");
    precacheShellshock("default");

    // global variables
    level.mmgametype = getCvar("g_gametype");
    level.mmmapname = getCvar("mapname");
    level.mmhostname = getCvar("sv_hostname");
    level.bans = []; // moved here to fix using MiscMod without users/groups set

    // mapvote
    codam\_mm_mapvote::init();

    // anticamper
    codam\_mm_anticamper::init();

    // commands
    if(level.ingamecommands) {
        codam\_mm_commands::precache();
        codam\_mm_commands::init();
    }

    // _tmpHudsForFunEvent
    precacheString(&"Please wait...");

    // spawnProtection
    precacheString(&"SPAWN PROTECTION");
    precacheHeadIcon("gfx/hud/hud@health_cross.tga");
    level.spawnprotected = codam\utils::getVar("scr_mm", "spawnprotection", "int", 1|2, 0);

    // damagemarker
    level.damagemarker_minus = codam\utils::getVar("scr_mm", "damagemarker_minus", "bool", 1|2, false);
    if(level.damagemarker_minus)
        precacheString(&"-");
    else
        precacheString(&"+");

    // meleefight / melee hud / melee headicon
    precacheString(&"FIGHT");
    precacheStatusIcon("gfx/hud/headicon@re_objcarrier.tga");

    // BEL menu
    if(codam\utils::getVar("scr_mm", "bel_menu", "bool", 0, false)) {
        game["menu_weapon_all"] = "weapon_" + game["allies"] + game["axis"];
        precacheMenu(game["menu_weapon_all"]);

        game["menu_weapon_allies"] = "weapon_" + game["allies"] + game["axis"];
        game["menu_weapon_axis"] = "weapon_" + game["allies"] + game["axis"];
    } else {
        game["menu_weapon_allies"] = "weapon_" + game["allies"];
        game["menu_weapon_axis"] = "weapon_" + game["axis"];
    }

    precacheMenu(game["menu_weapon_allies"]);
    precacheMenu(game["menu_weapon_axis"]);

    // Enable weapon settings per map or gametype
    if(codam\utils::getVar("scr_mm", "weaponsmapgt", "bool", 0, false))
        weaponsPerMapGt();

    return;
}

_start()
{
    codam\utils::debug(0, "======== MiscMod/_start");

    if(isDefined(level.modbycato3))
        return;

    level.modbycato3 = true;

    _showMiscModHuds();

    if(!codam\utils::getVar("scr_mm", "mapobjects", "bool", 1|2, false))
        codam\_mm_mmm::weaponremoval();

    if(codam\utils::getVar("scr_mm", "stuckmap", "bool", 1|2, true))
        thread _timerStuck();

    // meleefight
    level.meleefight = codam\utils::getVar("scr_mm", "meleefight", "bool", 1|2, false);

    return;
}

// ########## timer stuck
_timerStuck() // tip by Jona
{
    if(!isDefined(game["maprestarts"]))
        game["maprestarts"] = 0;

    for(;;) {
        wait 60;

        players = getEntArray("player", "classname");
        if(players.size == 0) {
            emptymap = codam\utils::getVar("scr_mm", "emptymap", "string", 0, "");
            if(emptymap != "") {
                if(emptymap != level.mmmapname) {
                    setCvar("sv_mapRotationCurrent", "gametype " + level.mmgametype + " map " + emptymap);
                    wait 1;
                    level.mapended = true;
                    game["state"] = "intermission";
                    level notify("intermission");
                    [[ level.gtd_call ]]("exitLevel", false);
                } else
                    [[ level.gtd_call ]]("map_restart", false);
            } else {
                if(game["maprestarts"] > 7) {
                    level notify("end_map"); // idea is to just rotate the map
                    return;
                }

                game["maprestarts"]++;
                [[ level.gtd_call ]]("map_restart", true); // true playerinfo retained
            }
        } else {
            if(game["maprestarts"] != 0)
                game["maprestarts"] = 0;
        }
    }
}

// ########## MiscMod huds
_showMiscModHuds()
{
    topText = newHudElem();
    topText.x = 5;
    topText.y = 1;
    topText.sort = 10000;
    topText.fontScale = 1.3;
    topText.archived = true;
    topText setText(level.topText);

    originalBottomText = newHudElem();
    originalBottomText.x = 57;
    originalBottomText.y = 471;
    originalBottomText.sort = 10000;
    originalBottomText.fontScale = 0.6;
    originalBottomText.archived = true;
    originalBottomText setText(level.originalBottomText);

    if(isDefined(level.bottomText)) { // precache above for level.bottomText for this block
        bottomText = newHudElem();
        bottomText.x = 116; // 1-9
        bottomText.y = 471;
        bottomText.sort = 10000;
        bottomText.fontScale = 0.6;
        bottomText.archived = true;
        bottomText setText(level.bottomText);
    }

    level.miscmodversion = "^5MiscMod ^3v3.1.4";
}
// ##########

// ########## 999 kicker
nnn(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9)
{
    kickout = codam\utils::getVar("scr_mm", "nnn", "int", 1|2, 60);
    if(kickout == 0 || getCvarInt("sv_allowDownload") > 0)
        return;

    secs = 0;
    for(;;) {
        if(secs == kickout) {
            self dropclient("999");
            break;
        }

        if(self getping() == 999)
            secs++;
        else
            if(secs > 0)
                secs = 0;

        wait 1;
    }
}
// ##########

// ########## welcome messages
welcome_display(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9)
{
    level endon("end_map");

    pID = self getEntityNumber();
    getGreets = codam\_mm_mmm::strTok(getCvar("tmp_mm_welcomemessages"), ";"); // get cvar to array (14;19;23;11;20...)

    if(!codam\_mm_mmm::in_array(getGreets, pID)) {
        addID = pID; // create a variable with all welcome message id's

        for(i = 0; i < getGreets.size; i++)
            addID += ";" + getGreets[i]; // generate the string of id's that is already greeted

        setCvar("tmp_mm_welcomemessages", addID); // add all the generated id's to a cvar for later use

        for(i = 1; /* /!\ */; i++) {
            if(getCvar("scr_mm_welcome" + i) != "") {
                if(i == 1)
                    self iPrintLnBold(getCvar("scr_mm_welcome" + i) + " " + codam\_mm_mmm::namefix(self.name));
                else
                    self iPrintLnBold(getCvar("scr_mm_welcome" + i));

                wait 6;
            } else {
                if(i > 1) // do 1 more check, just to see if the server admin want to disable the first message containing player name
                    break; // end the loop
            }
        }
    }
}

welcome_remove(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9)
{
    pID = self getEntityNumber();
    getGreets = codam\_mm_mmm::strTok(getCvar("tmp_mm_welcomemessages"), ";");

    if(codam\_mm_mmm::in_array(getGreets, pID)) {
        delWelcome = codam\_mm_mmm::array_remove(getGreets, pID);

        rID = "";

        for(i = 0; i < delWelcome.size; i++) {
            rID += delWelcome[i];
            rID += ";";
        }

        setCvar("tmp_mm_welcomemessages", rID);
    }
}
// ##########

// ########## instant kill / hitmarker / damagemarker / shellshock
_finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, a9, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9)
{
    if(isDefined(eAttacker) && isPlayer(eAttacker)) {
        if(sMeansOfDeath != "MOD_MELEE") {
            if(isDefined(eAttacker.fastfire) && codam\_mm_mmm::isBoltWeapon(sWeapon))
                return; // immunize players subject to fastfire

            if(isDefined(level.showdownactive))
                return; // showdown immunize
        }

        if(codam\utils::getVar("scr_mm", "headshots", "bool", 1|2, false) && sHitLoc != "head")
            return;

        if(isDefined(self.spawnprotected) && self.spawnprotected)
            return;
    }

    if(!isDefined(vDir)) // Don't do knockback if the damage direction was not specified
        iDFlags |= level.iDFLAGS_NO_KNOCKBACK;

    if(iDamage < 1) // Make sure at least one point of damage is done
        iDamage = 1;

    if(codam\utils::getVar("scr_mm", "shellshock", "bool", 1|2, false) && (self.health - iDamage > 0)) {
        shellshock = [];
        shellshock["duration"] = 0.3;
        if((float)(iDamage / 100) > shellshock["duration"])
            shellshock["duration"] = (float)(iDamage / 100);

        if(shellshock["duration"] > 0.9)
            shellshock["duration"] = 0.9;

        switch(sMeansOfDeath) {
            case "MOD_MELEE": // melee
                shellshock["name"] = "groggy";
            break;
            case "MOD_GRENADE_SPLASH": // grenade
                shellshock["name"] = "default";
            break;
            case "MOD_FALLING": // falling
                shellshock["name"] = "pain";
                shellshock["duration"] = 0.3;
            break;
            case "MOD_PROJECTILE_SPLASH": // panzerfaust
                shellshock["name"] = "default";
            break;
            default: // bullet
                shellshock["name"] = "pain";
                if(shellshock["duration"] < 0.6)
                    shellshock["duration"] = 0.6;
            break;
        }

        self shellshock(shellshock["name"], shellshock["duration"]);
    } else {
        if(isDefined(eAttacker) && isPlayer(eAttacker) && isAlive(eAttacker)) {
            if(sMeansOfDeath != "MOD_FALL" && sMeansOfDeath != "MOD_MELEE") {
                instantkill = codam\utils::getVar("scr_mm", "instantkill", "bool", 1|2, false);
                if(instantkill && codam\_mm_mmm::isBoltWeapon(sWeapon)) {
                    iDamage = iDamage + 100;
                    instantdamage = true;
                }

                pistolkill = codam\utils::getVar("scr_mm", "pistolkill", "bool", 1|2, false);
                if(pistolkill && codam\_mm_mmm::isSecondaryWeapon(sWeapon)) {
                    iDamage = iDamage + 100;
                    instantdamage = true;
                }
            }

            if(sMeansOfDeath == "MOD_MELEE") {
                if(codam\utils::getVar("scr_mm", "meleekill", "bool", 1|2, false)) { // meleekill
                    meleekill_ignore = codam\utils::getVar("scr_mm", "meleekill_ignore", "string", 1|2, "");
                    if(meleekill_ignore != "") {
                        meleekill_ignore = codam\_mm_mmm::strTok(meleekill_ignore, ";");
                        if(codam\_mm_mmm::in_array(meleekill_ignore, "bolt") && codam\_mm_mmm::isBoltWeapon(sWeapon)
                            || codam\_mm_mmm::in_array(meleekill_ignore, "secondary") && codam\_mm_mmm::isSecondaryWeapon(sWeapon)
                            || codam\_mm_mmm::in_array(meleekill_ignore, "grenade") && codam\_mm_mmm::isGrenade(sWeapon)
                            || codam\_mm_mmm::in_array(meleekill_ignore, "primary") && codam\_mm_mmm::isPrimaryWeapon(sWeapon))
                            tmpvar_ignore = true;
                    }

                    if(!isDefined(tmpvar_ignore)) {
                        iDamage = iDamage + 100;
                        instantdamage = true;
                    }
                }
            }

            if(codam\utils::getVar("scr_mm", "damagemarker", "bool", 1|2, false)) {
                iMarker = iDamage;
                if(isDefined(instantdamage))
                    iMarker = iMarker - 100;

                if(eAttacker != self)
                    eAttacker thread _showDamagemarker(iMarker);
            }

            hitmarker = codam\utils::getVar("scr_mm", "hitmarker", "int", 1|2, 0);
            if(hitmarker > 0 && eAttacker != self) {
                if(hitmarker == 2)
                    eAttacker thread _showHitmarker();
                else if(hitmarker == 3)
                    eAttacker thread _showHitmarker(iDamage, self.health);
                else if(hitmarker > 3)
                    if(codam\_mm_mmm::isBoltWeapon(sWeapon))
                        eAttacker thread _showHitmarker(iDamage, self.health);
                else
                    if(codam\_mm_mmm::isBoltWeapon(sWeapon))
                        eAttacker thread _showHitmarker();
            }
        }
    }

    return (self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc));
}

_showHitmarker(iDamage, iHealth)
{
    self endon("spawned");
    self endon("disconnect");

    if(isDefined(self.hitBlip))
        self.hitBlip destroy();

    self.hitBlip = newClientHudElem(self);
    self.hitBlip.alignX = "center";
    self.hitBlip.alignY = "middle";
    self.hitBlip.x = 320;
    self.hitBlip.y = 240;
    self.hitBlip.alpha = 1; // 0.5

    self.hitBlip.color = (1, 0.7, 0);
    if(isDefined(iDamage) && isDefined(iHealth)) {
        if(iHealth - iDamage < 0)
            self.hitBlip.color = (0, 0, 0);
        else if(iDamage >= 50)
            self.hitBlip.color = (1, 0, 0);
    }

    if(!codam\utils::getVar("scr_mm", "hitmarker_noscale", "bool", 1|2, false)) {
        self.hitBlip setShader("gfx/hud/hud@fire_ready.tga", 2, 2);
        self.hitBlip scaleOverTime(0.30, 48, 48);
    } else
        self.hitBlip setShader("gfx/hud/hud@fire_ready.tga", 48, 48);

    wait 0.30;

    if(isDefined(self.hitBlip))
        self.hitBlip destroy();
}

_showDamagemarker(iDamage)
{
    self endon("spawned");
    self endon("disconnect");

    if(!isDefined(self.damageBlip))
        self.damageBlip = [];

    if(!isDefined(self.damageBlipSize))
        self.damageBlipSize = 0;

    if(self.damageBlipSize > 2)
        self.damageBlipSize = 0;

    if(isDefined(self.damageBlip[self.damageBlipSize]))
        self.damageBlip[self.damageBlipSize] destroy();

    time = getTime(); // dirty hack to fix blip problem XD
    self.damageBlip[self.damageBlipSize] = newClientHudElem(self);
    self.damageBlip[self.damageBlipSize].blipId = time; // dirty hack to fix blip problem XD
    self.damageBlip[self.damageBlipSize].alignX = "center";
    self.damageBlip[self.damageBlipSize].alignY = "middle";
    self.damageBlip[self.damageBlipSize].x = 335;
    self.damageBlip[self.damageBlipSize].y = 225;
    self.damageBlip[self.damageBlipSize].alpha = 1;
    self.damageBlip[self.damageBlipSize].color = (1, 0.7, 0);
    if(level.damagemarker_minus)
        self.damageBlip[self.damageBlipSize].label = &"-";
    else
        self.damageBlip[self.damageBlipSize].label = &"+";
    self.damageBlip[self.damageBlipSize] setValue(iDamage);
    self.damageBlip[self.damageBlipSize] moveOverTime(0.35);

    rand = randomInt(10);

    self.damageBlip[self.damageBlipSize].x = self.damageBlip[self.damageBlipSize].x + (20 - rand);
    self.damageBlip[self.damageBlipSize].y = self.damageBlip[self.damageBlipSize].y - (20 + rand);

    damageBlipSize = self.damageBlipSize; // fix stuck marker
    self.damageBlipSize++;

    wait 0.35;

    if(isDefined(self.damageBlip[damageBlipSize]) && self.damageBlip[damageBlipSize].blipId == time)
        self.damageBlip[damageBlipSize] destroy();

}
// ##########

// ########## reset welcome messages / mapvote
endMap(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9)
{
    level waittill("end_map");
    level.mapended = true;

    game["state"] = "intermission";
    level notify("intermission");

    if(codam\utils::getVar("scr_mm", "repeatwelcome", "bool", 1|2, false))
        setCvar("tmp_mm_welcomemessages", "");

    players = getEntArray("player", "classname");
    if(players.size > 0) {
        if(level.mmgametype == "sd" || level.mmgametype == "re") {
            if(game["alliedscore"] == game["axisscore"])
                text = &"MPSCRIPT_THE_GAME_IS_A_TIE";
            else if(game["alliedscore"] > game["axisscore"])
                text = &"MPSCRIPT_ALLIES_WIN";
            else
                text = &"MPSCRIPT_AXIS_WIN";

            for(i = 0; i < players.size; i++) {
                player = players[i];

                player closeMenu();
                player setClientCvar("g_scriptMainMenu", "main");
                player setClientCvar("cg_objectiveText", text);
                player [[ level.gtd_call ]]("gt_spawnIntermission");
            }
        } else
            codam\GameTypes\_tdm::_endMap(level.mmgametype); // replace level.ham_g_gametype with level.mmgametype

        wait 7;

        if(!codam\utils::getVar("scr", "muzz", "bool", 1|2, false))
            codam\_mm_mapvote::mapvote();
        else {
            codam\_mm_mmm::_tmpHudsForFunEvent();
            while(codam\utils::getVar("scr", "muzz", "bool", 1|2, false))
                wait 0.05;
            codam\_mm_mmm::_tmpHudsForFunEvent();
        }
    }

    [[ level.gtd_call ]]("saveAllPlayers");
    [[ level.gtd_call ]]("exitLevel", false);

    return;
}
// ##########

// ########## anticamper / spawnpoint fix / spawnprotection
spawnPlayer(method, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9)
{
    self notify("spawned");
    self notify("end_respawn");

    resettimeout();

    self [[ level.gtd_call ]]("allowSpectateTeam", "allies", true);
    self [[ level.gtd_call ]]("allowSpectateTeam", "axis", true);
    self [[ level.gtd_call ]]("allowSpectateTeam", "freelook", level.freelook);
    self [[ level.gtd_call ]]("allowSpectateTeam", "none", true);

    self.sessionstate = "playing";
    self.spectatorclient = -1;
    self.archivetime = 0;
    self.friendlydamage = undefined;

    spClass = level.spawnType[self.pers["team"]];
    if(!isDefined(spClass))
        spClass = level.spawnType["any"];

    self _spawner(spClass, method);

    if(isDefined(self.pers["meleewinner"])) { // meleefight
        self.pers["meleewinner"] = undefined;
        self.statusicon = "gfx/hud/headicon@re_objcarrier.tga";
    } else
        self.statusicon = self [[ level.gtd_call ]]("spawn_statusicon");

    self.maxhealth = 100;
    self.health = self.maxhealth;

    self.spawnTime = getTime();
    self.killcam = undefined;
    self.objs_held = 0;
    self.cmdfreeze = undefined;

    if(!isDefined(self.pers["score"]))
        self.pers[ "score" ] = 0;

    self.score = self.pers["score"];

    if(!isDefined(self.pers["kills"]))
        self.pers["kills"] = 0;

    if(!isDefined(self.pers["deaths"]))
        self.pers["deaths"] = 0;

    self.deaths = self.pers["deaths"];

    self [[ level.gtd_call ]]("playerModel");

    if(level.spawnprotected > 0)
        self thread spawnProtection();
    else
        self [[ level.gtd_call ]]("drawFriends");
}

_spawner(spClass, method)
{
    if(!isDefined(spClass) || (spClass == ""))
        return;

    if(!isDefined(method))
        method = level.spawnMethod[spClass];
    if(!isDefined(method))
        method = "spawn_default";

    spawnpoints = getEntArray(spClass, "classname");

    spawnpoint = [[ level.gtd_call ]](method, spawnpoints);
    if(isDefined(spawnpoint)) {
        if(positionWouldTelefrag(spawnpoint.origin)) {
            self iPrintLn("^1ERROR: ^7Unable to assign spawnpoint, finding new.");
            spawnpoint = self codam\_mm_mmm::_newspawn(spawnpoint);
        }

        self spawn(spawnpoint.origin, spawnpoint.angles);
        self thread codam\_mm_anticamper::anticamper(spawnpoint); // anticamper
    } else
        maps\mp\gametypes\_callbacksetup::AbortLevel();
}

// ########## Spawn Protection
spawnProtection()
{ // Borrowed from PowerServer
    self endon("disconnect");

    self.spawnprotection = newClientHudElem(self);
    self.spawnprotection.alignX = "center";
    self.spawnprotection.alignY = "middle";
    self.spawnprotection.x = 320;
    self.spawnprotection.y = 90;
    self.spawnprotection.archived = false;
    self.spawnprotection.sort = 9998;
    self.spawnprotection.label = &"^3SPAWN PROTECTION";

    spawnpoint = self.origin;
    self.headicon = "gfx/hud/hud@health_cross.tga";

    self.spawnprotected = true;
    for(msecs = 0.0; msecs <= (float)level.spawnprotected; msecs += 0.05) {
        if(self attackButtonPressed() || self aimButtonPressed()
            || self meleeButtonPressed()
            || distance(self.origin, spawnpoint) > 50
            || self.sessionstate != "playing")
            break;

        wait 0.05;
    }
    self.spawnprotected = false;

    if(isDefined(self.spawnprotection))
        self.spawnprotection destroy();

    self [[ level.gtd_call ]]("drawFriends");
}

// ##########

// ########## square name fix
PlayerConnect(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b2, b4, b5, b6, b7, b8, b9)
{
    if(level.ingamecommands) {
        bannedip = self getip();
        banindex = codam\_mm_commands::isbanned(bannedip);
        if(banindex != -1) {
            bannedtime = level.bans[banindex]["time"];
            if(bannedtime > 0) {
                bannedsrvtime = level.bans[banindex]["srvtime"];
                remaining = bannedtime - (getSystemTime() - bannedsrvtime);
                if(remaining > 0) {
                    self.isbanned = true;
                    bannedreason = "tempban remaining ";
                    if(remaining >= 86400) {
                        time = remaining / 60 / 60 / 24;
                        bannedreason += time + " day";
                    } else if(remaining >= 3600) {
                        time = remaining / 60 / 60;
                        bannedreason += time + " hour";
                    } else if(remaining >= 60) {
                        time = remaining / 60;
                        bannedreason += time + " minute";
                    } else {
                        time = remaining;
                        bannedreason += time + " second";
                    }

                    if(time != 1)
                        bannedreason += "s";
                }
            } else {
                self.isbanned = true;
                bannedreason = level.bans[banindex]["reason"]; // to avoid race condition
            }
        }

        if(isDefined(self.isbanned)) { // used in PlayerDisconnect
            sendCommandToClient(self getEntityNumber(), "w \"Player Banned: ^1" + bannedreason + "\"");
            self waittill("begin");
            wait 0.05; // server/script crashes without it
            kickmsg = "Player Banned: ^1" + bannedreason;
            self dropclient(kickmsg);
            return;
        }
    }

    self.statusicon	= "gfx/hud/hud@status_connecting.tga";

    self.connecting = true;
    level.connectingPlayers++;

    if(level.maxmessages > 0) {
        self.pers["mm_chatmessages"] = 0;
        self.pers["mm_chattimer"] = 0;
    }

    if(!isDefined(self.pers["dumbbot"]))
        self waittill("begin");

    rename = codam\utils::getVar("scr_mm", "rename", "string", 0, "");
    if(rename != "") {
        rname = codam\_mm_mmm::strip(self.name);
        rname = codam\_mm_mmm::monotone(rname);
        rkeywords = codam\_mm_mmm::strTok(rename, " ");
        for(i = 0; i < rkeywords.size; i++) {
            if(rname == "" || codam\_mm_mmm::pmatch(tolower(rname), rkeywords[i])) {
                renameto = codam\utils::getVar("scr_mm", "renameto", "string", 0, "^1Disallowed Name^3#^1%");
                if(renameto[renameto.size - 1] == "%")
                    renameto = renameto + randomInt(1000);
                self setClientCvar("name", codam\_mm_mmm::namefix(renameto)); // super lazy, fix sometime to improve code
                break;
            }
        }
    }

    self.connecting = undefined;
    level.connectingPlayers--;

    self.statusicon = self [[ level.gtd_call ]]("connect_statusicon");
    self.hudelem = [];
    self.objs_held = 0;

    menu = undefined;

    if(self [[ level.gtd_call ]]("isLockedPlayer")) {
        level endon("intermission");

        self lockPlayer("being kicked");
        /*NOTREACHED*/
    }

    if (!isDefined(self.pers["connected"])) {
        if(!codam\utils::getVar("scr", "noserverinfo", "bool", 0, false))
            menu = game["menu_serverinfo"];

        self.pers["connected"] = true;
        iPrintLn(codam\_mm_mmm::namefix(self.name) + " ^7Connected");
    }

    scoreboard_text = codam\utils::getVar("scr_mm", "scoreboard_text", "string", 1|2, "");
    if(scoreboard_text == "namefix") // TODO: make this default?
        scoreboard_text = codam\_mm_mmm::namefix(level.mmhostname);

    if(scoreboard_text != "") {
        curconfstr = getConfigString(0); // Code by Defected
        oldhostname = "sv_hostname\\" + level.mmhostname + "\\"; // Code by Defected
        newhostname = "sv_hostname\\" + scoreboard_text + "\\"; // Code by Defected
        newconfstr = replace(curconfstr, oldhostname, newhostname); // (input, replace_from, replace_with) - Code by Defected
        sendCommandToClient(self getEntityNumber(), "d 0 " + newconfstr); // Code by Defected
    }

    [[ level.gtd_call ]]("logPrint", "connect", self);

    if(game["state"] == "intermission") {
        self [[	level.gtd_call ]]("gt_spawnIntermission");
        return;
    }

    level endon("intermission");

    team = self.pers["team"];
    if (level.ham_g_gametype == "bel") {
        self.god = false;
        self.respawnwait = false;
        self codam\GameTypes\_bel::removeBlackScreen();
    } else if(!isDefined(team)) {
        _playerInfo = self [[ level.gtd_call ]]("isSavedPlayer");
        if(isDefined(_playerInfo) && isDefined(_playerInfo["name"]) && (_playerInfo["name"] == self [[ level.gtd_call ]]("monotoneName"))) {
            codam\utils::debug(0, "FOUND PREVIOUS PLAYER: ", self.name);

            if(isDefined(_playerInfo["bot"]))
                self.pers["dumbbot"] = true;

            if(isDefined(_playerInfo["locked"])) {
                self lockPlayer("previously kicked");
                /*NOTREACHED*/
            } else if([[ level.gtd_call ]]("isTeam", _playerInfo["team"])) {
                team = _playerInfo["team"];
                self.pers["team"] = team;

                self.pers["weapon"] = self [[ level.gtd_call ]]("assignWeapon", _playerInfo["weapon"], true);
            } else {
                team = undefined;
                self.pers["team"] = undefined;
                self.pers["weapon"] = undefined;
            }
        }
    } else
        level [[ level.gtd_call ]]("resetPlayer", self);

    if(isDefined(team) && (team != "spectator")) {
        if(level.ham_g_gametype == "bel"/* || codam\utils::getVar("scr_mm", "bel_menu", "bool", 0, false)*/)
            self setClientCvar("g_scriptMainMenu", game["menu_weapon_all"]);
        else
            self setClientCvar("g_scriptMainMenu", game["menu_weapon_" + team]);

        self setClientCvar(level.ui_weapontab, "1");

        if(isDefined(self.pers["weapon"]))
            self [[ level.gtd_call ]]("gt_spawnPlayer");
        else { // BEL menu
            if(level.ham_g_gametype == "bel")
                menu = game["menu_weapon_" + self.pers["team"] + "_only"];
            /*else if(codam\utils::getVar("scr_mm", "bel_menu", "bool", 0, false))
                menu = game["menu_weapon_all"];*/
            else
                menu = game["menu_weapon_" + team];

            self [[ level.gtd_call ]]("gt_spawnSpectator");
        }
    } else {
        if(!isDefined(menu))
            menu = game["menu_team"];

        self [[ level.gtd_call ]]("goSpectate");
    }

    if(isDefined(self.pers["dumbbot"]))
        self thread [[ level.gtd_call ]]("randomBotMove");

    self thread [[ level.gtd_call ]]("gt_menuHandler", menu);

    self waittill("end_player", reason);

    codam\utils::debug(0, "exiting from player connect with reason = |", reason, "|");
    self lockPlayer(reason);
    /*NOTREACHED*/
}

//
lockPlayer(reason)
{
    wait(0.05);	// Delay before forcing spectator
    self [[	level.gtd_call ]]("goSpectate"); // For now, just force spec.

    self [[ level.gtd_call ]]("blockMenu");  // Disable menu operation
    self setClientCvar("g_scriptMainMenu",	"main"); // Only see main menu
    self closeMenu();

    self thread [[ level.gtd_call ]]("manageSpectate", "kick");

    iPrintLn(codam\_mm_mmm::namefix(self.name) + "^3 was locked for ^2" + reason);

    self [[ level.gtd_call ]]("lockPlayer");
    wait(9999);
}

PlayerDisconnect(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b2, b4, b5, b6, b7, b8, b9)
{
    self notify("disconnect");

    if(isDefined(self.isbanned)) {
        iPrintLn(codam\_mm_mmm::namefix(self.name) + " ^7Banned");
        return;
    }

    iPrintLn(codam\_mm_mmm::namefix(self.name) + " ^7Disconnected");

    if(isDefined(self.connecting)) {
        self.connecting = undefined;
        level.connectingPlayers--;
    }

    [[ level.gtd_call ]]("logPrint", "disconnect", self);

    if(isDefined(self.objs_held) && (self.objs_held > 0))
        self thread [[ level.gtd_call ]]("gt_dropObjective");

    self notify("death");

    if(!self [[ level.gtd_call ]]("isLockedPlayer") || !getCvarInt("scr_keep_locked"))
        level [[ level.gtd_call ]]("resetPlayer", self);

    level thread [[ level.gtd_call ]]("gt_updateTeamStatus", true);

    if(level.ham_g_gametype == "bel") {
        self.pers["team"] = "spectator";
        self codam\GameTypes\_bel::check_delete_objective();
        codam\GameTypes\_bel::CheckAllies_andMoveAxis_to_Allies();
    }

    return;
}

printJoinedTeam(team, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9)
{
    if(!isDefined(team) || (team == ""))
        return;

    switch(level.ham_g_gametype) {
        case "dm":
            return;
    }

    if(team == "allies")
        iPrintLn(codam\_mm_mmm::namefix(self.name) + " ^7Joined Allies");
    else
        if(team == "axis")
            iPrintLn(codam\_mm_mmm::namefix(self.name) + " ^7Joined Axis");

    return;
}
// ##########

// ########## anti fast fire
antiFF(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9)
{
    wait 1; // tmp to fix the spawn problem

    self endon("spawned"); // tmp to fix the spawn problem
    self endon("disconnect"); // tmp to fix the spawn problem

    /*
        kar98k_sniper 1350
        kar98k 1350
        mosin_nagant_sniper 1500
        mosin_nagant 1350
        springfield 1250 | 1300
        enfield 1450
    */

    fastfire = codam\utils::getVar("scr", "mm_fastfire", "int", 1|2, 0);
    if(fastfire == 0)
        return;

    if(!isDefined(level.fastfireaction)) {
        level.fastfireaction = "suicide";
        if(getCvar("scr_mm_fastfireaction") != "" && getCvar("scr_mm_fastfireaction") != "suicide")
            level.fastfireaction = getCvar("scr_mm_fastfireaction");
    }

    wait 1;

    weaponTimes = []; // self getCurrentWeapon();
    weaponTimes["kar98k_sniper_mp"] = 1350;
    weaponTimes["kar98k_mp"] = 1350;
    weaponTimes["mosin_nagant_sniper_mp"] = 1500;
    weaponTimes["mosin_nagant_mp"] = 1350;
    weaponTimes["springfield_mp"] = 1300; // possibly 1250 or 1300(old)
    weaponTimes["enfield_mp"] = 1450;
    weaponTimes["default"] = 1300;

    if(!isDefined(self.pers["fastfire"]))
        self.pers["fastfire"] = 0;

    while(self.sessionstate == "playing") {
        wait 0.05;

        currentWeapon = self getCurrentWeapon();
        if(!codam\_mm_mmm::isBoltWeapon(currentWeapon))
            continue;

        if(currentWeapon == self getWeaponSlotWeapon("primary"))
            weaponSlot = "primary";
        else if(currentWeapon == self getWeaponSlotWeapon("primaryb"))
            weaponSlot = "primaryb";
        else
            continue;

        weaponAmmo = self getWeaponSlotClipAmmo(weaponSlot);
        if(!isDefined(weaponAmmo)) continue;

        while(self getWeaponSlotClipAmmo(weaponSlot) == weaponAmmo && currentWeapon == self getCurrentWeapon())
            wait 0.05;

        if(self getWeaponSlotClipAmmo(weaponSlot) > weaponAmmo)
            continue;

        weaponAmmo = self getWeaponSlotClipAmmo(weaponSlot);
        if(!isDefined(weaponAmmo)) continue;

        if(currentWeapon == self getCurrentWeapon()) {
            weaponTime = weaponTimes["default"];
            if(isDefined(weaponTimes[currentWeapon]))
                weaponTime = weaponTimes[currentWeapon];

            startTime = getTime() + (weaponTime - 50);

            self.fastfire = true;
            while(startTime > getTime() && self.sessionstate == "playing") {
                if(currentWeapon != self getCurrentWeapon()) {
                    currentWeapon = self getCurrentWeapon();
                    if(!codam\_mm_mmm::isBoltWeapon(currentWeapon))
                        break;

                    if(currentWeapon == self getWeaponSlotWeapon("primary"))
                        weaponSlot = "primary";
                    else if(currentWeapon == self getWeaponSlotWeapon("primaryb"))
                        weaponSlot = "primaryb";
                    else
                        break;

                    weaponAmmo = self getWeaponSlotClipAmmo(weaponSlot);
                    if(!isDefined(weaponAmmo)) break;
                }

                if(self getWeaponSlotClipAmmo(weaponSlot) < weaponAmmo) { // TODO: code became messy here, recode sometime
                    weaponTime = weaponTimes["default"];
                    if(isDefined(weaponTimes[currentWeapon]))
                        weaponTime = weaponTimes[currentWeapon];

                    startTime = getTime() + (weaponTime - 50);

                    if(fastfire != -1) {
                        self.pers["fastfire"]++;
                        if(self.pers["fastfire"] < fastfire)
                            self iPrintLn("^3Warning! ^7Fast fire detected.");

                        if(self.pers["fastfire"] >= fastfire) {
                            iPrintLn(codam\_mm_mmm::namefix(self.name) + " ^7Was punished for fast fire.");
                            self.pers["fastfire"] = 0;

                            switch(level.fastfireaction) {
                                case "suicide":
                                    self thread [[ level.gtd_call ]]("suicide");
                                break;
                                case "disarm":
                                    grenade = self getWeaponSlotWeapon("grenade");
                                    pistol = self getWeaponSlotWeapon("pistol");
                                    primary = self getWeaponSlotWeapon("primary");
                                    primaryb = self getWeaponSlotWeapon("primaryb");

                                    if(!isDefined(grenade))
                                        grenade = "none";
                                    if(!isDefined(pistol))
                                        pistol = "none";
                                    if(!isDefined(primary))
                                        primary = "none";
                                    if(!isDefined(primaryb))
                                        primary = "none";

                                    self dropItem(grenade);
                                    self dropItem(pistol);
                                    self dropItem(primary);
                                    self dropItem(primaryb);
                                break;
                                default:
                                    self thread [[ level.gtd_call ]]("goSpectate");
                                break;
                            }

                            break;
                        }
                    } else
                        self iPrintLn("^3Warning! ^7Fast fire detected.");

                    weaponAmmo = self getWeaponSlotClipAmmo(weaponSlot);
                    if(!isDefined(weaponAmmo)) break;
                }

                wait 0.05;
            }

            self.fastfire = undefined;
        }
    }
}
// ##########

// ########## weapon32
weapon32(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9)
{
    if(codam\utils::getVar("scr_mm", "weapon32", "bool", 1|2, false))
        return;

    wait 1;

    self setClientCvar("weapon", 0);
}
// ##########

// ########## MiscMod keys
mmKeys(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9)
{ // u = useKey, m = meleeKey and a = attackKey
    self waittill("begin");

    if(!codam\utils::getVar("scr_mm", "mmkeys", "bool", 1|2, false))
        return;

    keys = "";
    timer = 0;

    bombzone_A = getent("bombzone_A", "targetname");
    bombzone_B = getent("bombzone_B", "targetname");

    for(;;) {
        if(isDefined(self.pers["dumbbot"]))
            return;

        wait 0.05;

        if(self.sessionstate != "playing"
            || (isDefined(bombzone_A) && isDefined(bombzone_A.planting))
            || (isDefined(bombzone_B) && isDefined(bombzone_B.planting)))
            continue;

        if(self useButtonPressed()) {
            while(self useButtonPressed())
                wait 0.05;

            keys += "u";
         }

        if(keys.size > 0 && self attackButtonPressed()) {
            while(self attackButtonPressed())
                wait 0.05;

            keys += "a";
         }

        if(self meleeButtonPressed()) {
            while(self meleeButtonPressed())
                wait 0.05;

            keys += "m";
         }

        if(keys.size > 0) {
            timer += 0.05;
            reset = false;
            switch(keys) { // add your custom functions here for keycombos :)
                // umma = HamGoodies drop weapon
                // mmmm = HamGoodies holster weapon
                // uuum = HamGoodies drop health
                // ummm = HamGoodies last weapon
                // umaa = HamGoodies swap weapons
                case "uuuu":
                    if(level.meleefight)
                        self codam\_mm_meleefight::meleeFight();
                    reset = true;
                break;
                case "uuua":
                    if(codam\utils::getVar("scr_mm", "funcommands", "bool", 1|2, false))
                        iPrintLn(codam\_mm_mmm::namefix(self.name) + " ^7is cool.");
                    reset = true;
                break;
                case "uumm":
                    self iPrintLnBold(level.miscmodversion);
                    thread codam\_mm_meleefight::__testSpawns();
                    reset = true;
                break;
                case "uuma":
                    self iPrintLn("^5Origin: ^1" + self.origin[0] + ", ^2" + self.origin[1] + ", ^3" + self.origin[2]);
                    self iPrintLn("^6Angles: ^1" + self.angles[0] + ", ^2" + self.angles[1] + ", ^3" + self.angles[2]);
                    reset = true;
                break;
                case "mamuu":
                    if(codam\utils::getVar("scr_mm", "funcommands", "bool", 1|2, false))
                        iPrintLnBold(codam\_mm_mmm::namefix(self.name) + " ^0is drinking Black Coffee.");
                    reset = true;
                break;
            }

            if(timer > 1 || reset) {
                timer = 0;
                keys = "";
            }
        }
    }
}
// ##########

assignWeaponSlot(slot, weapon, limit, noMap, a4, a5, a6, a7, a8, a9, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9)
{
    codam\utils::debug( 90, "assignWeaponSlot:: |", slot, "|", weapon, "|", limit, "|" );

    if(!isDefined(slot) || (slot == "") || !isDefined(weapon) || (weapon == ""))
        return undefined;

    forceMap = (bool)(isDefined(noMap) && codam\utils::getVar("scr_mm", "wmap_force", "bool", 1|2, false));
    if(forceMap)
        noMap = undefined; // really dirty workaround but I can't be bothered to fix CoDaM

    clip = codam\weapon::_weaponAmmo(weapon, "clip");
    ammo = codam\weapon::_weaponAmmo(weapon, "ammo");

    if(isDefined(limit) && (ammo > limit))
        ammo = limit;

    if(!isDefined(noMap) && isDefined(level.weaponMap[weapon]))
        weapon = level.weaponMap[weapon];

    self setWeaponSlotWeapon(slot, weapon);
    self setWeaponSlotClipAmmo(slot, clip);
    self setWeaponSlotAmmo(slot, ammo);

    if(forceMap && slot == "primary")
        self.pers["spawnweapon"] = weapon; // CoDaM making things complicated... this is so... dirty

    return weapon;
}

// ########## restrict weapons
assignWeapon(weapon, useDefault, forceTeam, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9)
{
    if(codam\utils::getVar("scr_mm", "bel_menu", "bool", 0, false)) { // extra if statement to break long line
        if((!isDefined(forceTeam) || forceTeam == "") && codam\_mm_mmm::isPrimaryWeapon(weapon)) {
            forceTeam = "allies";
            switch(weapon) {
                case "kar98k_mp": case "mp40_mp": case "mp44_mp": case "kar98k_sniper_mp":
                    forceTeam = "axis";
                break;
            }
        }
    }

    if(!isPlayer(self))
        return undefined;

    if(isDefined(forceTeam) && (forceTeam != ""))
        _team = forceTeam;
    else {
        _team = self.pers["team"];
        if(!isDefined(_team))
            return undefined;
    }

    team = game[_team];

    codam\utils::debug(90, "assignWeapon:: |", team, "|", weapon, "|", useDefault, "|", forceTeam, "|");

    if(!isDefined(team) || (team == "") || !isDefined(level.teamWeaponByType[team]))
        return undefined;

    // First determine the weapon's class ...
    if(isDefined(weapon))
        weapClass = level.weaponClass[weapon];
    else
        weapClass = undefined;

    if(!isDefined(weapClass)) {
        if(!isDefined(useDefault))
            return undefined;

        weapClass = "default";
    }

    // If the weapon does not belong to the team, use team default
    _weap = level.teamWeaponByType[team][weapClass];
    if(!isDefined(_weap))
        _weap = level.teamWeaponByType[team]["default"];

    if(!isDefined(_weap)) // code to fix crashes if bots join
        return; // code to fix crashes if bots join

    weapon = _weap["weapon"];
    weapMax = _weap["max"];

    // If the weapon is limited, determine how many are being used.
    // Simple algorithm, find all players in the team and count
    // the weapons in use.
    teamCount = 1;	// Count me in!
    weapCount = 0;
    players = getEntArray("player", "classname");
    for(i = 0; i < players.size; i++) {
        player = players[i];
        if(player == self)
            continue; // My weapon has already been counted!

        pteam = player.sessionteam;
        if(!isDefined(pteam) || (pteam == "none"))
            pteam = player.pers["team"];

        if(isDefined(pteam) && (pteam == _team)) {
            teamCount++;

            if(isDefined(player.pers["weapon"]) && (player.pers["weapon"] == weapon))
                weapCount++;
        }
    }

    codam\utils::debug(90, "assignWeapon = |", team, "|", teamCount, "|", weapon, "|", weapMax, "|", weapCount, "|");

    weapName = "";
    for(i = 0; i < (weapon.size - 3); i++)
        weapName += weapon[i];

    maxWeapCount = codam\utils::getVar("scr_mm", "restrict_" + weapName, "int", 1|2, 0);
    if(maxWeapCount > 0 && weapCount >= maxWeapCount) {
        self thread [[ level.gtd_call ]]("client_hud_announce", level._weap_unavail, 320, 40, true);
        return undefined;
    }

    // A negative weapMax indicates ratio!!!
    if(weapMax < 0) {
        // Limiting factor entered as a ratio ... adjust max
        // based on existing number of players in team.
        weapMax = 0 - (weapMax * ((float)teamCount));
        if(weapMax < 1)
            weapMax = 1; // Always allow at least one

        weapMax = (int)weapMax;
    }

    if(weapCount >= weapMax) {
        self thread [[ level.gtd_call ]]("client_hud_announce", level._weap_unavail, 320, 40, true);
        return undefined;
    }

    return weapon;
}
// ##########

// ########## meleefight - roundclock timer
roundClock(timer, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9)
{
    if(!isDefined(timer)) {
        timer = (int)(level.roundlength * 60);
        def = true;
    }

    [[ level.gtd_call ]]("mapClock", timer);

    if(isDefined(game["matchstarted"]) && game["matchstarted"]) {
        level.clock.color = (0, 1, 0);

        if(timer > level.graceperiod) {
            timer -= level.graceperiod;
            wait level.graceperiod;

            level.roundstarted = true;
            level.clock.color = (1, 1, 1);

            level notify("round_start");
        }
    } else
        level.clock.color = (1, 0, 0);

    // stupid CoDaM clock -- trick to make meleetimer work
    roundlength = level.roundlength;

    if(isDefined(def)) {
        while(timer > 0) {
            timer--;

            if(level.roundlength != roundlength) {
                roundlength = level.roundlength;
                timer = (int)(level.roundlength * 60);

                [[ level.gtd_call ]]("mapClock", timer);
            }

            wait 1;
        }
    } else
        wait timer;

    return;
}

startRound(_winner, _text, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9) {
    thread maps\mp\gametypes\_teams::sayMoveIn();
    if(level.meleefight)
        thread codam\_mm_meleefight::_meleeAnnounce();

    [[ level.gtd_call ]]("roundClock");

    if(level.roundended)
        return;

    switch(level.ham_g_gametype) {
        case "re":
            if(!level.exist[game["re_attackers"]] || !level.exist[game["re_defenders"]])
                _winner = "draw";
            else if(isDefined(level.showdownactive))
                _winner = "draw";
            else
                _winner = game["re_defenders"];

            _text = &"RE_TIMEEXPIRED";
        break;
        case "sd":
            if(level.bombplanted && !codam\utils::getVar("scr_sd", "ignorebomb", "bool", 2, false))
                return;

            if(!level.exist[game["attackers"]] || !level.exist[game["defenders"]])
                _winner = "draw";
            else if(isDefined(level.showdownactive))
                _winner = "draw";
            else
                _winner = game["defenders"];

            _text = &"SD_TIMEHASEXPIRED";
        break;
        default:
            // New gametype?
        break;
    }

    if(isDefined(_text))
        level notify("end_round", _text, _winner, undefined, true);

    return;
}
// ##########

// ########## !pistols / !grenade
// scr_mm_allow_pistols ""
// scr_mm_allow_grenades ""
givePistol(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9)
{
    if(!isPlayer(self))
        return;

    // Assign correct pistol based on team
    pistol = self [[ level.gtd_call ]]("assignWeapon", "colt_mp");
    if (!isDefined(pistol))
        return;

    if((bool)(getCvar("scr_mm_allow_pistols") != "")) {
        setting = getCvarInt("scr_mm_allow_pistols");
        if(setting == -1) {
            return;
        } else if(setting >= 0) {
            if(codam\utils::getVar("scr_mm", "allow_pistols_ammotype", "string", 1|2, "chamber") == "chamber") {
                self [[ level.gtd_call ]]("assignWeaponSlot", "pistol", pistol, 0);
                self setWeaponSlotClipAmmo("pistol", setting); // yeah tell me about it
            } else {
                self [[ level.gtd_call ]]("assignWeaponSlot", "pistol", pistol, setting);
                self setWeaponSlotClipAmmo("pistol", 0); // yeah tell me about it
            }
        }
    } else
        self [[ level.gtd_call ]]("assignWeaponSlot", "pistol", pistol);

    return;
}

giveGrenade(weapon, a1, a2, a3, a4, a5, a6, a7, a8, a9,	b0, b1, b2, b3, b4, b5, b6, b7, b8, b9)
{
    if(!isPlayer(self))
        return;

    mm_grenades = -1;
    if(getCvar("scr_mm_allow_grenades") != "" && getCvarInt("scr_mm_allow_grenades") >= 0)
        mm_grenades = getCvarInt("scr_mm_allow_grenades");

    if(mm_grenades > 3)
        return;

    // Assign correct grenade based on team
    grenade	= self [[ level.gtd_call ]]("assignWeapon", "fraggrenade_mp");
    if(!isDefined(grenade))
        return;

    nadelimit = [[ level.gtd_call ]]("grenadeLimit", weapon);

    if(mm_grenades >= 0 && mm_grenades < 4)
        nadelimit = mm_grenades;

    self [[ level.gtd_call ]]("assignWeaponSlot", "grenade", grenade, nadelimit);

    return;
}

// ##########

// ########## quickcommands antispam
quick(type, response, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9)
{
    if(!level.allowquick || !isPlayer(self) || !isDefined(type) || (type == "") || !isDefined(response) || (response == ""))
        return;


    if(isDefined(self.pers["mm_mute"])) {
        self iPrintLn("You are currently muted.");
        return;
    }
    
    quicklimit = codam\utils::getVar("scr_mm", "quickcommandlimit", "int", 1|2, 5);
    if(quicklimit > 0) {
        if(!isDefined(self.quicklimit))
            self.quicklimit = 0;

        self.quicklimit++;
        if(self.quicklimit > quicklimit) {
            self iPrintLn("^3WARNING: ^7You exceeded your quick command limit.");
            return;
        } else
            if(self.quicklimit > (quicklimit - 3) && self.quicklimit != quicklimit)
                self iPrintLn("^3WARNING: ^7You have " + (quicklimit - self.quicklimit) + " quick command(s) remaining.");
    }

    switch(type) {
        case "command":
            self maps\mp\gametypes\_teams::quickcommands(response);
        break;
        case "statement":
            self maps\mp\gametypes\_teams::quickstatements(response);
        break;
        case "response":
            self maps\mp\gametypes\_teams::quickresponses(response);
        break;
    }

    return;
}

// ##########

// ########## send server messages "<time>;<type>;<message>" - lazy code
msgBroadcast(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9)
{
    wait 20;

    msgb_id = getCvarInt("tmp_mm_msgb");

    if(msgb_id == 0)
        msgb_id = 1;

    while(true) {
        message = getCvar("scr_mm_msgb" + msgb_id);

        if(message != "")
            message = codam\_mm_mmm::strTok(message, ";");
        else
            break;

        if(message.size != 3)
            break;

        switch(message[1]) {
            case "m":
                iPrintLnBold(message[2]);
            break;

            case "o":
                iPrintLn(message[2]);
            break;

            default:
                sendCommandToClient(-1, "i \"" + message[2] + "\"");
            break;
        }

        msgb_id += 1;

        if(getCvar("scr_mm_msgb" + msgb_id) == "")
            msgb_id = 1;

        setCvar("tmp_mm_msgb", (int)msgb_id);

        timer = (int)message[0];
        if(timer > 0 && timer <= 60)
            wait timer;
        else
            break;
    }

    setCvar("tmp_mm_msgb", 0);
}

// ##########

// ########## check for bad names according to the badwords cvar for chat
badnames(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9)
{
    level waittill("badwords_check");

    if(!isDefined(level.badwords))
        return;

    wait 1;

    while(true) { // will recode this another time better
        checkname = false;
        players = getEntArray("player", "classname");
        for(i = 0; i < players.size; i++) {
            playername = codam\_mm_mmm::monotone(tolower(players[i].name));
            checkname = false;

            if(!isDefined(players[i].pers["oldname"]) || playername != players[i].pers["oldname"]) {
                checkname = true;
                players[i].pers["oldname"] = playername;
                if(isDefined(players[i].pers["badname"]))
                    players[i].pers["badname"] = undefined;
            }

            if(!isDefined(players[i].pers["badnameticks"]))
                players[i].pers["badnameticks"] = 0;

            if(isDefined(players[i].pers["badname"]) || players[i].pers["badnameticks"] >= 2) {
                if(isDefined(players[i].pers["badname"]))
                    kickmsg = "Bad name: " + players[i].pers["badname"];
                else
                    kickmsg = "Bad name.";
                players[i] dropclient(kickmsg);
            }

            if(checkname) {
                for(b = 0; b < level.badwords.size; b++) {
                    // it's expected all badwords are lower case for better performance
                    if(codam\_mm_mmm::pmatch(playername, level.badwords[b])) {
                        if(!isDefined(players[i].pers["badname"])) {
                            badmessage = "^3WARNING: ^7Change your name to something more appropriate.";
                            badmessage += " The offensive word in question is: " + level.badwords[b] + ".";
                            players[i] codam\_mm_commands::message_player(badmessage); // lazycode, move to _mm_mmm
                            players[i].pers["badname"] = level.badwords[b];
                            players[i].pers["badnameticks"] += 1;
                        }

                        break;
                    }
                }
            }
        }

        wait level.badnametime;
    }
}

// ##########

// ########## Fix spawnIntermission from CoDaM
spawnIntermission(spClass, method, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9)
{
    switch(level.mmgametype) {
        case "sd":
            spClass = "mp_searchanddestroy_intermission";
        break;
        case "re":
            spClass = "mp_retrieval_intermission";
        break;
        case "dm":
            spClass = "mp_deathmatch_intermission";
        break;
        case "tdm":
            spClass = "mp_teamdeathmatch_intermission";
        break;
        default:
            if(!isDefined(spClass))
                spClass = "mp_deathmatch_intermission";
        break;
    }

    self [[ level.gtd_call ]]("spawnIntermission", spClass, method);
}

// ##########

// ########## Enable weapon settings per map or gametype
weaponsPerMapGt()
{
    weapons = [];
    weapons[weapons.size] = "m1carbine";
    weapons[weapons.size] = "m1garand";
    weapons[weapons.size] = "thompson";
    weapons[weapons.size] = "bar";
    weapons[weapons.size] = "springfield";
    weapons[weapons.size] = "enfield";
    weapons[weapons.size] = "sten";
    weapons[weapons.size] = "bren";
    weapons[weapons.size] = "nagant";
    weapons[weapons.size] = "ppsh";
    weapons[weapons.size] = "nagantsniper";
    weapons[weapons.size] = "kar98k";
    weapons[weapons.size] = "mp40";
    weapons[weapons.size] = "mp44";
    weapons[weapons.size] = "kar98ksniper";
    weapons[weapons.size] = "panzerfaust";
    weapons[weapons.size] = "fg42";
    weapons[weapons.size] = "mg42";

    cvar_prefix = "scr_allow_";
    for(i = 0; i < weapons.size; i++) {
        tmpcvar = "tmp_" + cvar_prefix + weapons[i];
        if(getCvar(tmpcvar) == "")
            setCvar(tmpcvar, getCvar(cvar_prefix + weapons[i]));

        // scr_allow_<weapon>_<gametype>
        _cvar1 = getCvar(cvar_prefix + weapons[i] + "_" + level.mmgametype);
        if(_cvar1 == "1")
            setCvar(cvar_prefix + weapons[i], "1");
        else if(_cvar1 == "0")
            setCvar(cvar_prefix + weapons[i], "0");

        // scr_allow_<weapon>_<mapname>
        _cvar2 = getCvar(cvar_prefix + weapons[i] + "_" + level.mmmapname );
        if(_cvar2 == "1")
            setCvar(cvar_prefix + weapons[i], "1");
        else if(_cvar2 == "0")
            setCvar(cvar_prefix + weapons[i], "0");

        if(_cvar1 == "" && _cvar2 == "")
            setCvar(cvar_prefix + weapons[i], getCvar(tmpcvar));
    }

    codam\weapon::_initWeaponAssign(); // reload the CoDaM weapon assign
}

// ##########