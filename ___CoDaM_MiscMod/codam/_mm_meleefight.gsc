meleeFight()
{
    if(/*!isDefined(level.roundbased)*/level.mmgametype != "sd") // sd or re gametype TODO: fix so no melee showdown on carrier
        return;

    if(isDefined(level.roundstarted) && !level.roundstarted) // dirty fix for join players
        return;

    if(isDefined(level.bombplanted) && level.bombplanted)
        return;

    if(!isDefined(level.showdown))
        level.showdown = false;

    al = 0;
    ax = 0;
    mp = [];

    players = getEntArray("player", "classname");
    for(i = 0; i < players.size; i++) {
        if(players[i].sessionstate != "playing")
            continue;

        if(players[i].pers["team"] == "axis")
            ax++;
        else
            al++;

        if(ax > 1 || al > 1)
            break;

        mp[mp.size] = players[i];
    }

    if(al == 1 && ax == 1) {
        if(!isDefined(self.showdown))
            self.showdown = true;

        if(self.showdown && !level.showdown) {
            level.showdown = true;
            self.showdown = false;
            iPrintLn(codam\_mm_mmm::namefix(self.name) + " ^7Asks for melee showdown.");
            for(i = 0; i < mp.size; i++)
                if(mp[i] != self)
                    mp[i] iPrintLn("^3Press 4 times [{+activate}] key to accept.");
        }

        if(self.showdown && level.showdown) {
            level notify("mm_showdown"); // end anticamper
            iPrintLn(codam\_mm_mmm::namefix(self.name) + " ^7Accepted!");

            bombzone_A = getent("bombzone_A", "targetname");
            bombzone_B = getent("bombzone_B", "targetname");

            if(isDefined(bombzone_A) || isDefined(bombzone_B)) {
                bombzone_A delete();
                bombzone_B delete();
                objective_delete(0);
                objective_delete(1);
            }

            level.showdown = false;
            self.showdown = false;

            codam\_mm_mmm::compassdb(-1); // clear objects compass

            meleefight = codam\utils::getVar("scr_mm", "meleefight_spawns", "int", 1|2, 0);
            if(meleefight > 0 && ((meleefight == 1 && (bool)randomInt(2)) || meleefight == 2)) {
                spawns = 0;
                for(i = 0; i < mp.size; i++) { // check if there is valid spawns for teleport
                    mp[i].meleespawn = _meleeFightSpawn(mp[i].pers["team"]);
                    if(isDefined(mp[i].meleespawn))
                        spawns++;
                }

                level.meleespawn = undefined;

                if(spawns == mp.size) { // valid spawns initiate the teleport
                    for(i = 0; i < mp.size; i++) {
                        mp[i].health = 999999; // immunize the players a bit
                        mp[i] setPlayerAngles(mp[i].meleespawn.angles);
                        mp[i] setOrigin(mp[i].meleespawn.origin);
                        mp[i] thread codam\_mm_mmm::freezePlayer(3); // based on timers, they must always be right or unexpected things can happen
                    }

                    fightHud = newHudElem();
                    fightHud.x = 320;
                    fightHud.y = 210;
                    fightHud.sort = 10000;
                    fightHud.fontScale = 2.2;
                    fightHud.alignX = "center";
                    fightHud.alignY = "middle";

                    fightHud.alpha = 1;
                    fightHud setValue(3);
                    fightHud fadeOverTime(0.75);
                    fightHud.alpha = 0;

                    wait 1;

                    fightHud.alpha = 1;
                    fightHud setValue(2);
                    fightHud fadeOverTime(0.75);
                    fightHud.alpha = 0;

                    wait 1;

                    fightHud.alpha = 1;
                    fightHud setValue(1);
                    fightHud fadeOverTime(0.75);
                    fightHud.alpha = 0;

                    wait 1;

                    fightHud destroy();
                }
            }

            thread _meleeFightHud();
            level.showdownactive = true;

            for(i = 0; i < mp.size; i++) {
                mp[i].health = 100; // normalize and equalize health

                _pistolweap = mp[i] getWeaponSlotWeapon("pistol");
                if(!isDefined(_pistolweap)) {
                    _pistolweap = "colt_mp";
                    if(mp[i].pers["team"] == "axis")
                        _pistolweap = "luger_mp";
                }

                mp[i] setWeaponSlotWeapon("pistol", _pistolweap);
                mp[i] setWeaponSlotClipAmmo("pistol", 0);
                mp[i] setWeaponSlotAmmo("pistol", 0);

                mp[i] setSpawnWeapon(_pistolweap);
                mp[i] switchToWeapon(_pistolweap);

                mp[i] takeWeapon(mp[i] getWeaponSlotWeapon("primary"));
                mp[i] takeWeapon(mp[i] getWeaponSlotWeapon("primaryb"));
                mp[i] takeWeapon(mp[i] getWeaponSlotWeapon("grenade"));

                mp[i] thread _meleeCompass(codam\_mm_mmm::compassdb());
                mp[i] thread _meleeWinner();
            }

            codam\_mm_mmm::weaponremoval();
            level.roundlength = 0.75;
        }
    } else
        self iPrintLn("^3Warning! ^7Melee showdown can only be started when there is 1 player on each team.");
}

_meleeFightHud()
{
    fightHud = newHudElem();
    fightHud.x = 320;
    fightHud.y = 210;
    fightHud.sort = 10000;
    fightHud.fontScale = 2.2;
    fightHud.alignX = "center";
    fightHud.alignY = "middle";

    fightHud.alpha = 1;
    fightHud setText(&"FIGHT");
    fightHud fadeOverTime(0.75);
    fightHud.alpha = 0;

    wait 1;

    fightHud destroy();
}

_meleeFightSpawn(team)
{
    if(!isDefined(team))
        return undefined;

    spawns = [];
    switch(level.mmmapname) {
        case "mp_brecourt":
            spawns["allies"][0]["origin"] = (-3948.15, 2925.04, 806.125); // Cato - Water Tank
            spawns["allies"][0]["angles"] = (0, 45.3625, 0); // Cato
            spawns["allies"][1]["origin"] = (-3370.37, -78.51, 32.6595); // Muzz - Cornfield
            spawns["allies"][1]["angles"] = (0, 78.0743, 0); // Muzz
            spawns["allies"][2]["origin"] = (-390.491, -2497.31, 96.125); // Cato - Little Ruins
            spawns["allies"][2]["angles"] = (0, -39.4025, 0); // Cato
            spawns["allies"][3]["origin"] = (787.466, -27.1303, -2.84444); // Cato - MG Tunnel
            spawns["allies"][3]["angles"] = (0, -91.8127, 0); // Cato
            spawns["allies"][4]["origin"] = (1024.38, -1026.68, -35.875); // Cato - AB Tunnel
            spawns["allies"][4]["angles"] = (0, -0.950317, 0); // Cato
            spawns["allies"][5]["origin"] = (2174.94, 910.971, -20.4149); // Cato - B Corner Hills
            spawns["allies"][5]["angles"] = (0, 178.802, 0); // Cato
            spawns["allies"][6]["origin"] = (-1189.4, 939.089, 37.5916); // Cato - Island
            spawns["allies"][6]["angles"] = (0, 47.2906, 0); // Cato

            spawns["axis"][0]["origin"] = (-3781.6, 3085.7, 806.125); // Cato - Water Tank
             spawns["axis"][0]["angles"] = (0, -142.213, 0); // Cato
            spawns["axis"][1]["origin"] = (-3352.41, 353.333, 32.1252); // Muzz - Cornfield
            spawns["axis"][1]["angles"] = (0, -97.7563, 0); // Muzz
            spawns["axis"][2]["origin"] = (-127.788, -2708.18, 108.125); // Cato - Little Ruins
            spawns["axis"][2]["angles"] = (0, 143.168, 0); // Cato
            spawns["axis"][3]["origin"] = (776.426, -532.644, -15.8749); // Cato - MG Tunnel
            spawns["axis"][3]["angles"] = (0, 90.0989, 0); // Cato
            spawns["axis"][4]["origin"] = (1198.69, -1040.21, -35.875); // Cato - AB Tunnel
            spawns["axis"][4]["angles"] = (0, 176.177, 0); // Cato
            spawns["axis"][5]["origin"] = (945.44, 910.808, -6.1106); // Cato - B Corner Hills
            spawns["axis"][5]["angles"] = (0, -2.2, 0); // Cato
            spawns["axis"][6]["origin"] = (-807.856, 1439.15, 52.2646); // Cato - Island
            spawns["axis"][6]["angles"] = (0, -130.638, 0); // Cato
        break;
        case "mp_carentan":
            spawns["allies"][0]["origin"] = (259.16, 1380.84, 312.13); // Jona
            spawns["allies"][0]["angles"] = (0.00, -43.86, 0.00); // Jona
            spawns["allies"][1]["origin"] = (2040.88, 1776.88, -15.875); // Muzz - A house NEW
            spawns["allies"][1]["angles"] = (0, -127.386, 0); // Muzz
            spawns["allies"][2]["origin"] = (1622.19, 2313.65, 398.944); // Cato - A Roof
            spawns["allies"][2]["angles"] = (0, -177.303, 0); // Cato
            spawns["allies"][3]["origin"] = (1565.14, 600.898, 206.125); // Cato - Big Arch
            spawns["allies"][3]["angles"] = (0, 178.555, 0); // Cato
            spawns["allies"][4]["origin"] = (-159.125, 1898.26, 168.125); // Muzz - Catwalk
            spawns["allies"][4]["angles"] = (0, -169.503, 0); // Muzz
            spawns["allies"][5]["origin"] = (374.24, -1051.31, 58.5712); // Cato - Allied Truck
            spawns["allies"][5]["angles"] = (0, 84.8969, 0); // Cato
            spawns["allies"][6]["origin"] = (884.44, 3545.33, 133.245); // Muzz - Axis NADE JUMP
            spawns["allies"][6]["angles"] = (0, -167.014, 0); // Muzz

            spawns["axis"][0]["origin"] = (519.49, 1127.96, 312.13); // Jona
            spawns["axis"][0]["angles"] = (0.00, 135.91, 0.00); // Jona
            spawns["axis"][1]["origin"] = (1759.13, 1407.13, -15.875); // Muzz - A house NEW
            spawns["axis"][1]["angles"] = (0, 51.0645, 0); // Muzz
            spawns["axis"][2]["origin"] = (1167.7, 2396.04, 411.155); // Muzz - A Roof
            spawns["axis"][2]["angles"] = (0, -11.6235, 0); // Muzz
            spawns["axis"][3]["origin"] = (1324.47, 600.6, 206.125); // Cato - Big Arch
            spawns["axis"][3]["angles"] = (0, -0.472412, 0); // Cato
            spawns["axis"][4]["origin"] = (-556.165, 1708.11, 148.586); // Muzz - Catwalk
            spawns["axis"][4]["angles"] = (0, 20.3577, 0); // Muzz
            spawns["axis"][5]["origin"] = (381.208, -936.296, 62.5875); // Cato - Allied Truck
            spawns["axis"][5]["angles"] = (0, -97.262, 0); // Cato
            spawns["axis"][6]["origin"] = (558.971, 3386.62, 143.221); // Muzz - Axis NADE JUMP
            spawns["axis"][6]["angles"] = (0, 22.0221, 0); // Muzz
        break;
        case "mp_dawnville":
            spawns["allies"][0]["origin"] = (2268.43, -19232.67, 232.13); // Jona
            spawns["allies"][0]["angles"] = (0.00, -0.23, 0.00); // Jona
            spawns["allies"][1]["origin"] = (-2827.85, -19138.9, 66.1832); // GeNeRaL - Allied corner
            spawns["allies"][1]["angles"] = (0, -112.78, 0); // GeNeRaL
            spawns["allies"][2]["origin"] = (-1213.78, -17156.6, 67.5796); // Cato - Loft Hole
            spawns["allies"][2]["angles"] = (0, -158.22, 0); // Cato
            spawns["allies"][3]["origin"] = (-1193.25, -16297.7, 176.968); // Cato - Graveyard House
            spawns["allies"][3]["angles"] = (0, 91.225, 0); // Cato
            spawns["allies"][4]["origin"] = (337.88, -18455.6, 32.125); // Cato - Alley Allies
            spawns["allies"][4]["angles"] = (0, 177.819, 0); // Cato
            spawns["allies"][5]["origin"] = (1495.95, -15319.3, 118.911); // Muzz - Axis Gallery Roof
            spawns["allies"][5]["angles"] = (0, -92.2852, 0); // Muzz
            spawns["allies"][6]["origin"] = (1257.04, -18117.9, 48.125); // Muzz - Unchartered Territory Between Sniper house and B hole
            spawns["allies"][6]["angles"] = (0, 46.7798, 0); // Muzz
            spawns["allies"][7]["origin"] = (-3175.84, -19222.5, 232.125); // Muzz - Allies Hole Roof
            spawns["allies"][7]["angles"] = (0, -8.21777, 0); // Muzz
            spawns["allies"][8]["origin"] = (149.21, -15327.4, 5.06252); // Muzz - Beside Church
            spawns["allies"][8]["angles"] = (0, 153.034, 0); // Muzz
            spawns["allies"][9]["origin"] = (953.834, -17693, 36.4972); // Muzz - Tank Street
            spawns["allies"][9]["angles"] = (0, 133.901, 0); // Muzz

            spawns["axis"][0]["origin"] = (2728.60, -19232.67, 232.13); // Jona
            spawns["axis"][0]["angles"] = (0.00, 179.81, 0.00); // Jona
            spawns["axis"][1]["origin"] = (-2795.97, -19313.8, 41.3494); // Muzz - Allied Corner
            spawns["axis"][1]["angles"] = (0, 69.2139, 0); // Muzz
            spawns["axis"][2]["origin"] = (-1478.79, -17280.9, 64.6926); // Cato - Loft Hole
            spawns["axis"][2]["angles"] = (0, 29.4159, 0); // Cato
            spawns["axis"][3]["origin"] = (-1109.18, -15986.2, 175.79); // Cato - Graveyard House
            spawns["axis"][3]["angles"] = (0, -87.572, 0); // Cato
            spawns["axis"][4]["origin"] = (-98.4503, -18455.6, 32.125); // Cato - Alley Allies
            spawns["axis"][4]["angles"] = (0, -1.47766, 0); // Cato
            spawns["axis"][5]["origin"] = (1495.09, -15518.3, 119.31); // Muzz - Axis Gallery Roof
            spawns["axis"][5]["angles"] = (0, 76.7615, 0); // Muzz
            spawns["axis"][6]["origin"] = (1435.62, -17812.2, 40.125); // Muzz - Unchartered Territory Between Sniper house and B hole
            spawns["axis"][6]["angles"] = (0, -126.887, 0); // Muzz
            spawns["axis"][7]["origin"] = (-2767.13, -19236.6, 232.125); // Muzz - Allies Hole Roof
            spawns["axis"][7]["angles"] = (0, 177.682, 0); // Muzz
            spawns["axis"][8]["origin"] = (-79.1091, -15191.1, 4.11143); // Muzz - Beside Church
            spawns["axis"][8]["angles"] = (0, -29.4543, 0); // Muzz
            spawns["axis"][9]["origin"] = (558.723, -17320.6, 20.2894); // Muzz - Tank Street
            spawns["axis"][9]["angles"] = (0, -45.9723, 0); // Muzz
        break;
        case "mp_depot":
            spawns["allies"][0]["origin"] = (-922.36, 1407.88, 480.13); // Jona
            spawns["allies"][0]["angles"] = (0.00, -179.07, 0.00); // Jona
            spawns["allies"][1]["origin"] = (333.934, 1015.86, 474.356); // Muzz - Axis Spawn Rail Roof
            spawns["allies"][1]["angles"] = (0, 89.9176, 0); // Muzz
            spawns["allies"][2]["origin"] = (920.681, 2068.65, -23.875); // Muzz - Behind Map Box
            spawns["allies"][2]["angles"] = (0, 178.374, 0); // Muzz
            spawns["allies"][3]["origin"] = (-270.397, 3671.64, -23.875); // Muzz - Behind Axis Spawn Tracks
            spawns["allies"][3]["angles"] = (0, -90.9723, 0); // Muzz
            spawns["allies"][4]["origin"] = (-1628.3, 2493.32, 794.914); // Muzz - Axis Spawn Roof
            spawns["allies"][4]["angles"] = (0, -44.0387, 0); // Muzz
            spawns["allies"][5]["origin"] = (-2158.19, 2100.41, 568.125); // Muzz - Axis Spawn Building Top
            spawns["allies"][5]["angles"] = (0, 177.138, 0); // Muzz
            spawns["allies"][6]["origin"] = (88.1993, 2563.88, -23.875); // Muzz - Axis Side Little Secluded Area
            spawns["allies"][6]["angles"] = (0, -93.8123, 0); // Muzz
            spawns["allies"][7]["origin"] = (-3136.27, 1290.56, 360.342); // Cato - Southwest Roof Farthest
            spawns["allies"][7]["angles"] = (0, 89.6869, 0); // Cato
            spawns["allies"][8]["origin"] = (-2457.23, 371.771, 436.005); // Cato - Southwest Roof
            spawns["allies"][8]["angles"] = (0, 134.236, 0); // Cato
            spawns["allies"][9]["origin"] = (-1456.09, 953.111, 48.125); // Cato - Middle Shed
            spawns["allies"][9]["angles"] = (0, 11.3049, 0); // Cato
            spawns["allies"][10]["origin"] = (-1601.17, 513.354, 372.305); // Cato - Middle House
            spawns["allies"][10]["angles"] = (0, -0.384521, 0); // Cato

            spawns["axis"][0]["origin"] = (-1786.31, 1407.73, 480.13); // Jona
            spawns["axis"][0]["angles"] = (0.00, -0.57, 0.00); // Jona
            spawns["axis"][1]["origin"] = (335.681, 1362.65, 474.671); // Muzz - Axis Spawn Rail Roof
            spawns["axis"][1]["angles"] = (0, -92.428, 0); // Muzz
            spawns["axis"][2]["origin"] = (401.645, 2080.67, -23.875); // Muzz - Behind Map box
            spawns["axis"][2]["angles"] = (0, -1.75232, 0); // Muzz
            spawns["axis"][3]["origin"] = (-277.58, 2979.76, -23.875); // Muzz - Behind Axis Spawn Tracks
            spawns["axis"][3]["angles"] = (0, 88.1818, 0); // Muzz
            spawns["axis"][4]["origin"] = (-1098.84, 2320.13, 803.947); // Muzz - Axis Spawn Roof
            spawns["axis"][4]["angles"] = (0, 129.463, 0); // Muzz
            spawns["axis"][5]["origin"] = (-2464.5, 2071.97, 568.125); // Muzz - Axis Spawn Building Top
            spawns["axis"][5]["angles"] = (0, -0.0164795, 0); // Muzz
            spawns["axis"][6]["origin"] = (272.311, 2248.53, -23.875); // Muzz - Axis Side Little Secluded Area
            spawns["axis"][6]["angles"] = (0, 175.226, 0); // Muzz
            spawns["axis"][7]["origin"] = (-3130.26, 1866.64, 359.528); // Cato - Southwest Roof Farthest
            spawns["axis"][7]["angles"] = (0, -90.2692, 0); // Cato
            spawns["axis"][8]["origin"] = (-2713.85, 623.39, 435.709); // Cato - Southwest Roof
            spawns["axis"][8]["angles"] = (0, -45.6757, 0); // Cato
            spawns["axis"][9]["origin"] = (-1228.15, 944.161, 48.125); // Cato - Middle Shed
            spawns["axis"][9]["angles"] = (0, 177.193, 0); // Cato
            spawns["axis"][10]["origin"] = (-1055.82, 507.133, 372.125); // Cato - Middle House
            spawns["axis"][10]["angles"] = (0, 179.165, 0); // Cato
        break;
        case "mp_harbor":
            spawns["allies"][0]["origin"] = (-12853.72, -7661.03, 683.18); // Jona
            spawns["allies"][0]["angles"] = (0.00, -71.39, 0.00); // Jona
            spawns["allies"][1]["origin"] = (-8188.5, -9735.05, 505.961); // Muzz - Far south outhouse roof
            spawns["allies"][1]["angles"] = (0, 0.994263, 0); // Muzz
            spawns["allies"][2]["origin"] = (-12821.6, -3609.19, -119.875); // Muzz - Water
            spawns["allies"][2]["angles"] = (0, -1.6864, 0); // Water
            spawns["allies"][3]["origin"] = (-10729, -6468.06, 64.125); // Muzz - B North wall surface (outside map)
            spawns["allies"][3]["angles"] = (0, 89.8022, 0); // Muzz
            spawns["allies"][4]["origin"] = (-13760.2, -5875.9, 416.125); // Muzz - Far Far West
            spawns["allies"][4]["angles"] = (0, -95.1801, 0); // Muzz
            spawns["allies"][5]["origin"] = (-7022.52, -6388.66, -1.875); // Muzz - North of Allied Truck
            spawns["allies"][5]["angles"] = (0, -90.9393, 0); // Muzz
            spawns["allies"][6]["origin"] = (-7769.02, -6890.57, -1.875); // Muzz - Allies Boxes North
            spawns["allies"][6]["angles"] = (0, 87.2369, 0); // Muzz
            spawns["allies"][7]["origin"] = (-4483.06, -719.125, -119.875); // Muzz - Far Far Far Very Far North
            spawns["allies"][7]["angles"] = (0, -179.05, 0); // Muzz
            //spawns["allies"][8]["origin"] = (-8349.33, -7659.51, 2240.12); // Muzz - I BELIEVE I CAN FLY!
            //spawns["allies"][8]["angles"] = (0, 179.286, 0); // Muzz

            spawns["axis"][0]["origin"] = (-12618.86, -8425.97, 597.77); // Jona
            spawns["axis"][0]["angles"] = (0.00, 106.73, 0.00); // Jona
            spawns["axis"][1]["origin"] = (-7383.7, -9799.92, 527.584); // Muzz - Far south outhouse roof
            spawns["axis"][1]["angles"] = (0, 173.188, 0); // Muzz
            spawns["axis"][2]["origin"] = (-12426.5, -3611.15, -119.875); // Hehu - Warter
            spawns["axis"][2]["angles"] = (0, 174.117, 0); // Hehu
            spawns["axis"][3]["origin"] = (-10721.1, -5947.18, 64.125); // Muzz - B North wall surface (outside map)
            spawns["axis"][3]["angles"] = (0, -93.8617, 0); // Muzz
            spawns["axis"][4]["origin"] = (-13849.6, -6692.4, 416.125); // Muzz - Far Far West
            spawns["axis"][4]["angles"] = (0, 84.8804, 0); // Muzz
            spawns["axis"][5]["origin"] = (-7044.53, -6856.09, -1.875); // Muzz - North of Allied Truck
            spawns["axis"][5]["angles"] = (0, 88.4619, 0); // Muzz
            spawns["axis"][6]["origin"] = (-7734.15, -6413.77, -1.875); // Muzz - Allies Boxes North
            spawns["axis"][6]["angles"] = (0, -95.0922, 0); // Muzz
            spawns["axis"][7]["origin"] = (-5320.31, -719.125, -119.875); // Muzz - Far Far Far Very Far North
            spawns["axis"][7]["angles"] = (0, -7.15759, 0); // Muzz
            //spawns["axis"][8]["origin"] = (-9594.72, -7580.97, 2240.12); // Muzz - I BELIEVE I CAN FLY!
            //spawns["axis"][8]["angles"] = (0, -0.291138, 0); // Muzz
        break;
        case "mp_hurtgen":
            spawns["allies"][0]["origin"] = (1282.32, -1341.45, -255.87); // Jona
            spawns["allies"][0]["angles"] = (0.00, 179.71, 0.00); // Jona
            spawns["allies"][1]["origin"] = (2761.32, -3539.27, -133.025); // Muzz - NE Near Axis left plant
            spawns["allies"][1]["angles"] = (0, 80.367, 0); // Muzz
            spawns["allies"][2]["origin"] = (2129.45, -2173.9, -86.875); // Muzz - Above Axis bunker
            spawns["allies"][2]["angles"] = (0, 124.98, 0); // Muzz
            spawns["allies"][3]["origin"] = (3139.38, 2478.95, -383.875); // Muzz - West lower hillway
            spawns["allies"][3]["angles"] = (0, 179.747, 0); // Muzz
            //spawns["allies"][4]["origin"] = (-156.002, -633.088, 1500.00); // Muzz - I BELIEVE I CAN FLY!
            //spawns["allies"][4]["angles"] = (0, -3.12012, 0); // Muzz

            spawns["axis"][0]["origin"] = (580.06, -1339.28, -255.87); // Jona
            spawns["axis"][0]["angles"] = (0.00, -0.96, 0.00); // Jona
            spawns["axis"][1]["origin"] = (2893.44, -3039.95, -140.34); // Muzz - NE Near Axis left plant
            spawns["axis"][1]["angles"] = (0, -116.411, 0); // Muzz
            spawns["axis"][2]["origin"] = (1936.14, -1815.22, -86.875); // Muzz - Above Axis bunker
            spawns["axis"][2]["angles"] = (0, -48.4387, 0); // Muzz
            spawns["axis"][3]["origin"] = (2410.19, 2470.9, -383.993); // Muzz - West lower hillway
            spawns["axis"][3]["angles"] = (0, 6.10291, 0); // Muzz
            //spawns["axis"][4]["origin"] = (788.834, -650.171, 1500.00); // Muzz - I BELIEVE I CAN FLY!
            //spawns["axis"][4]["angles"] = (0, -177.061, 0); // Muzz
        break;
        case "mp_pavlov":
            spawns["allies"][0]["origin"] = (-9872.00, 6072.47, -143.87); // Jona
            spawns["allies"][0]["angles"] = (0.00, 177.25, 0.00); // Jona
            spawns["allies"][1]["origin"] = (-3609.4, 15279.8, 550); // Muzz - Far NE outside map
            spawns["allies"][1]["angles"] = (0, -48.2684, 0); // Muzz
            spawns["allies"][2]["origin"] = (-3575.1, 9010.42, -42.5579); // Muzz - Far SE outside map
            spawns["allies"][2]["angles"] = (0, 123.651, 0); // Muzz
            spawns["allies"][3]["origin"] = (-13345.3, 9253.8, 488.125); // Muzz - Above building roof SW of Allies spawn
            spawns["allies"][3]["angles"] = (0, -43.1598, 0); // Muzz
            spawns["allies"][4]["origin"] = (-8183.12, 3677.83, -27.2119); // Muzz - Far South from Allies spawn closed ruins
            spawns["allies"][4]["angles"] = (0, -178.38, 0); // Muzz
            spawns["allies"][5]["origin"] = (-9462.19, 11921.7, 375.125); // Muzz - North house top
            spawns["allies"][5]["angles"] = (0, -2.29614, 0); // Muzz
            spawns["allies"][6]["origin"] = (-10127.1, 7536.68, -50.8809); // Muzz - South of Allied spawn ruins
            spawns["allies"][6]["angles"] = (0, -128.996, 0); // Muzz

            spawns["axis"][0]["origin"] = (-10868.33, 6127.71, -159.07); // Jona
            spawns["axis"][0]["angles"] = (0.00, -1.71, 0.00); // Jona
            spawns["axis"][1]["origin"] = (-3301.03, 14935.6, 550); // Muzz - Far NE outside map
            spawns["axis"][1]["angles"] = (0, 128.551, 0); // Muzz
            spawns["axis"][2]["origin"] = (-3903.4, 9409.87, -48.8502); // Muzz - Far SE outside map
            spawns["axis"][2]["angles"] = (0, -48.5101, 0); // Muzz
            spawns["axis"][3]["origin"] = (-13071.5, 8976.86, 488.125); // Muzz - Above building roof SW of Allies spawn
            spawns["axis"][3]["angles"] = (0, 135.115, 0); // Muzz
            spawns["axis"][4]["origin"] = (-8545.03, 3666.06, -41.7846); // Muzz - Far South from Allies spawn closed ruins
            spawns["axis"][4]["angles"] = (0, -3.25745, 0); // Muzz
            spawns["axis"][5]["origin"] = (-9052.2, 11898.1, 375.125); // Muzz - North house top
            spawns["axis"][5]["angles"] = (0, 175.364, 0); // Muzz
            spawns["axis"][6]["origin"] = (-10282.5, 7338.2, -54.8569); // Muzz - South of Allied spawn ruins
            spawns["axis"][6]["angles"] = (0, 51.5808, 0); // Muzz
        break;
        case "mp_powcamp":
            //spawns["allies"][0]["origin"] = (2878.46, 4783.23, 41.87); // Jona
            //spawns["allies"][0]["angles"] = (0.00, -42.20, 0.00); // Jona
            spawns["allies"][0]["origin"] = (122.288, 5055.93, 215.684); // Muzz - Allies back-house roof
            spawns["allies"][0]["angles"] = (0, -19.7644, 0); // Muzz
            spawns["allies"][1]["origin"] = (-117.307, 4557, 464.125); // Muzz - Tower Rooftop Allies
            spawns["allies"][1]["angles"] = (0, -139.658, 0); // Muzz
            spawns["allies"][2]["origin"] = (313.328, 4159.67, 220.125); // Muzz - Allies Right side roof
            spawns["allies"][2]["angles"] = (0, -0.43396, 0); // Muzz
            spawns["allies"][3]["origin"] = (-1752.82, 520.736, 162.125); // Muzz - Mid South house tin roof
            spawns["allies"][3]["angles"] = (0, 89.8517, 0); // Muzz
            spawns["allies"][4]["origin"] = (-222.069, 1552.27, -15.875); // Muzz - Mid Arena near A
            spawns["allies"][4]["angles"] = (0, -134.725, 0); // Muzz
            spawns["allies"][5]["origin"] = (221.608, -105.604, 212.125); // Muzz - Housetop near A
            spawns["allies"][5]["angles"] = (0, 179.583, 0); // Muzz
            spawns["allies"][6]["origin"] = (-1327.55, -173.81, 173.076); // Muzz - B Rooftop
            spawns["allies"][6]["angles"] = (0, 90.3131, 0); // Muzz

            //spawns["axis"][0]["origin"] = (3237.71, 4451.62, 79.35); // Jona
            //spawns["axis"][0]["angles"] = (0.00, 144.32, 0.00); // Jona
            spawns["axis"][0]["origin"] = (711.27, 4811.11, 192.684); // Muzz - Allies back-house roof
            spawns["axis"][0]["angles"] = (0, 149.744, 0); // Muzz
            spawns["axis"][1]["origin"] = (-204.079, 4466.37, 464.125); // Muzz - Tower Rooftop Allies
            spawns["axis"][1]["angles"] = (0, 40.5121, 0); // Muzz
            spawns["axis"][2]["origin"] = (986.742, 4156.99, 220.125); // Muzz - Allies Right side roof
            spawns["axis"][2]["angles"] = (0, 179.572, 0); // Muzz
            spawns["axis"][3]["origin"] = (-1752.67, 886.604, 162.125); // Muzz - Mid South house tin roof
            spawns["axis"][3]["angles"] = (0, -89.621, 0); // Muzz
            spawns["axis"][4]["origin"] = (-464.874, 1303.13, -15.875); // Muzz - Mid Arena near A
            spawns["axis"][4]["angles"] = (0, 44.4177, 0); // Muzz
            spawns["axis"][5]["origin"] = (-653.062, -0.587769, 212.125); // Muzz - Housetop near A
            spawns["axis"][5]["angles"] = (0, -0.587769, 0); // Muzz
            spawns["axis"][6]["origin"] = (-1324.8, 120.384, 173.534); // Muzz - B Rooftop
            spawns["axis"][6]["angles"] = (0, -92.5378, 0); // Muzz
        break;
        case "mp_railyard":
            spawns["allies"][0]["origin"] = (-964.99, 273.55, 344.31); // Jona
            spawns["allies"][0]["angles"] = (0.00, -179.62, 0.00); // Jona
            spawns["allies"][1]["origin"] = (855.712, 1076.72, 304.125); // Muzz - A plant building 3rd floor
            spawns["allies"][1]["angles"] = (0, -133.467, 0); // Muzz
            spawns["allies"][2]["origin"] = (-3194.42, 1166.01, 140.125); // Cato - Far south outside map box
            spawns["allies"][2]["angles"] = (0, 87.3303, 0); // Muzz
            spawns["allies"][3]["origin"] = (-912.434, 1969.97, 300.884); // Muzz - Allies Spawn house roof
            spawns["allies"][3]["angles"] = (0, 177.166, 0); // Muzz
            spawns["allies"][4]["origin"] = (-50.5865, 3266.02, 332.472); // Muzz - Allies side small rooftop 1
            spawns["allies"][4]["angles"] = (0, 173.386, 0); // Muzz
            spawns["allies"][5]["origin"] = (-1424.16, 3233.41, 330.331); // Muzz - Allies side small rooftop 2
            spawns["allies"][5]["angles"] = (0, 165.564, 0); // Muzz
            spawns["allies"][6]["origin"] = (-1357.1, -1368.55, 248.125); // Muzz - Axis side higher area
            spawns["allies"][6]["angles"] = (0, 178.671, 0); // Muzz
            spawns["allies"][7]["origin"] = (-1606.22, 1575.68, 45.00); // Cato - Hangar
            spawns["allies"][7]["angles"] = (0, -5.17456, 0); // Cato
            spawns["allies"][8]["origin"] = (-1552.95, -479.111, 200.00); // Muzz - Train top
            spawns["allies"][8]["angles"] = (0, -0.741577, 0); // Muzz

            spawns["axis"][0]["origin"] = (-1744.37, 272.96, 344.02); // Jona
            spawns["axis"][0]["angles"] = (0.00, -1.51, 0.00); // Jona
            spawns["axis"][1]["origin"] = (480.331, 665.962, 304.125); // Muzz - A plant building 3rd floor
            spawns["axis"][1]["angles"] = (0, 44.5331, 0); // Muzz
            spawns["axis"][2]["origin"] = (-3066.3, 1698.67, 140.125); // Cato - Far south outside map box
            spawns["axis"][2]["angles"] = (0, -93.5266, 0); // Cato
            spawns["axis"][3]["origin"] = (-1751.04, 1982.98, 299.177); // Muzz - Allies Spawn house roof
            spawns["axis"][3]["angles"] = (0, -3.29041, 0); // Muzz
            spawns["axis"][4]["origin"] = (-400.454, 3285.74, 328.792); // Muzz - Allies side small rooftop 1
            spawns["axis"][4]["angles"] = (0, -5.36133, 0); // Muzz
            spawns["axis"][5]["origin"] = (-1784.87, 3252.69, 327.318); // Muzz - Allies side small rooftop 2
            spawns["axis"][5]["angles"] = (0, 3.93311, 0); // Muzz
            spawns["axis"][6]["origin"] = (-1713.72, -1360.13, 248.125); // Muzz - Axis side higher area
            spawns["axis"][6]["angles"] = (0, -1.15906, 0); // Muzz
            spawns["axis"][7]["origin"] = (-1261.82, 1534.64, 45.00); // Cato - Hangar
            spawns["axis"][7]["angles"] = (0, 178.407, 0); // Cato
            spawns["axis"][8]["origin"] = (-756.336, -487.166, 200.00); // Muzz - Train top
            spawns["axis"][8]["angles"] = (0, 177.396, 0); // Muzz
        break;
        case "mp_rocket":
            spawns["allies"][0]["origin"] = (10701.64, 4518.20, 517.13); // Jona
            spawns["allies"][0]["angles"] = (0.00, -135.47, 0.00); // Jona
            spawns["allies"][1]["origin"] = (9206.35, 6137.77, 454.125); // Muzz - Southwest Bunker Top
            spawns["allies"][1]["angles"] = (0, -95.246, 0); // Muzz
            spawns["allies"][2]["origin"] = (7953.87, 1903.49, 346.661); // Muzz - Allies spawn south side
            spawns["allies"][2]["angles"] = (0, 88.407, 0); // Muzz
            spawns["allies"][3]["origin"] = (9475.37, -325.769, 252.275); // Muzz - Allies spawn NE
            spawns["allies"][3]["angles"] = (0, 151.128, 0); // Muzz
            spawns["allies"][4]["origin"] = (10467.6, 2230.19, 316.738); // Muzz - Allied rocks
            spawns["allies"][4]["angles"] = (0, -174.084, 0); // Muzz
            spawns["allies"][5]["origin"] = (10806.1, 5372.91, 303.743); // Muzz - Rocket
            spawns["allies"][5]["angles"] = (0, -1.61499, 0); // Muzz
            spawns["allies"][6]["origin"] = (10493.1, 4522.97, 408.125); // Muzz - Mid bunker inside
            spawns["allies"][6]["angles"] = (0, -53.2727, 0); // Muzz

            spawns["axis"][0]["origin"] = (10522.96, 4341.33, 517.13); // Jona
            spawns["axis"][0]["angles"] = (0.00, 45.23, 0.00); // Jona
            spawns["axis"][1]["origin"] = (9189.28, 5862.16, 454.125); // Muzz - Southwest Bunker Top
            spawns["axis"][1]["angles"] = (0, 86.6931, 0); // Muzz
            spawns["axis"][2]["origin"] = (7952.33, 2273.48, 352.034); // Muzz - Allies spawn south side
            spawns["axis"][2]["angles"] = (0, -86.0065, 0); // Muzz
            spawns["axis"][3]["origin"] = (9150.38, -163.894, 257.096); // Muzz - Allies spawn NE
            spawns["axis"][3]["angles"] = (0, -32.7008, 0); // Muzz
            spawns["axis"][4]["origin"] = (10217.5, 2186.96, 328.581); // Muzz - Allied rocks
            spawns["axis"][4]["angles"] = (0, 11.6785, 0); // Muzz
            spawns["axis"][5]["origin"] = (11139.1, 5361.74, 302.125); // Muzz - Rocket
            spawns["axis"][5]["angles"] = (0, 177.599, 0); // Muzz
            spawns["axis"][6]["origin"] = (10692.7, 4322.53, 408.125); // Muzz - Mid bunker inside
            spawns["axis"][6]["angles"] = (0, 132.77, 0); // Muzz
        break;
        default:
            return undefined;
    }

    if(team == false)
        return spawns["allies"].size;

    if(!isDefined(level.meleespawn))
        level.meleespawn = randomInt(spawns[team].size); // (spawns.size / 2)

    spawn = spawnStruct();
    spawn.origin = spawns[team][level.meleespawn]["origin"];
    spawn.angles = spawns[team][level.meleespawn]["angles"];

    return spawn;
}

_meleeCompass(id)
{
    if(id < 3)
        return;

    objective_add(id, "current", self.origin, "gfx/hud/objective.tga");
    if(isDefined(self.pers["team"])) {
        if(self.pers["team"] == "axis")
            team = "allies";
        else if(self.pers["team"] == "allies")
            team = "axis";

        if(isDefined(team))
            objective_team(id, team);
    }

    while(self.sessionstate == "playing") {
        objective_position(id, self.origin);
        wait 0.05;
    }

    objective_delete(id);
    codam\_mm_mmm::compassdb(id);
}

_meleeWinner()
{
    if(level.mmgametype != "sd")
        return;

    if(!codam\utils::getVar("scr_mm", "meleefight_winner", "bool", 1|2, false))
        return;

    while(isAlive(self) && !isDefined(level.meleewinner))
        wait 0.5; // allow 1s time for a draw

    if(!isAlive(self) && !isDefined(level.meleewinner))
        level.meleewinner = true;
    else {
        if(isAlive(self) && isDefined(level.meleewinner)) {
            self.pers["meleewinner"] = true;
            iPrintLn(codam\_mm_mmm::namefix(self.name) + " ^7is the winner!");
        }
    }
}

_meleeAnnounce()
{
    if(!codam\utils::getVar("scr_mm", "meleefight_announce", "bool", 1|2, false) || level.mmgametype != "sd")
        return;

    wait (level.graceperiod + 1);

    for(;;) {
        if(isDefined(level.bombplanted) && level.bombplanted)
            break;

        players = getEntArray("player", "classname");
        if(players.size < 2) // don't announce if there is only 2 players?
            break;

        al = 0;
        ax = 0;

        for(i = 0; i < players.size; i++) {
            if(players[i].sessionstate != "playing")
                continue;

            if(players[i].pers["team"] == "axis")
                ax++;
            else
                al++;

            if(ax > 1 && al > 1)
                break;
        }

        if(ax == 1 && al == 1) {
            iPrintLn("^3Press 4 times [{+activate}] key to initate a melee showdown.");
            break;
        }

        if(ax == 0 || al == 0)
            break;

        wait 1;
    }
}

__testSpawns()
{
    if(!codam\utils::getVar("scr_mm", "meleefight_test", "bool", 0, false))
        return;

    spawnsize = _meleeFightSpawn(false);
    if(isDefined(spawnsize) && codam\utils::isNumeric(spawnsize)) {
        iPrintLn("Running test spawns.");

        players = getEntArray("player", "classname");
        for(a = 0; a < spawnsize; a++) {
            level.meleespawn = a;
            for(i = 0; i < players.size; i++) {
                if(players[i].sessionstate != "playing")
                    continue;

                spawn = _meleeFightSpawn(players[i].pers["team"]);
                players[i] setPlayerAngles(spawn.angles);
                players[i] setOrigin(spawn.origin);
            }

            iPrintLn("Spawn " + (a + 1) + " of " + spawnsize);

            wait 5;
        }
    }
}
