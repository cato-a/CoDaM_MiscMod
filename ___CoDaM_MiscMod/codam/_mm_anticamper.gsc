init()
{
    precacheShader("gfx/hud/objective.tga");
    
    level.anticamp = false;
    if(GetCvar("scr_mm_anticamp") != "" && getCvarInt("scr_mm_anticamp") > 0)
        level.anticamp = true;
    
    level.spawncamprange = 100;
    if(GetCvar("scr_mm_spawncamprange") != "" && getCvarInt("scr_mm_spawncamprange") > 0)
        level.spawncamprange = getCvarInt("scr_mm_spawncamprange");
    
    level.spawncamper = 20; // time
    if(GetCvar("scr_mm_spawncamper") != "" && getCvarInt("scr_mm_spawncamper") > 0)
        level.spawncamper = getCvarInt("scr_mm_spawncamper");
    
    level.anticamprange = 50;
    if(GetCvar("scr_mm_anticamprange") != "" && getCvarInt("scr_mm_anticamprange") > 0)
        level.anticamprange = getCvarInt("scr_mm_anticamprange");

    level.anticamper = 30; // time 
    if(GetCvar("scr_mm_anticamper") != "" && getCvarInt("scr_mm_anticamper") > 0)
        level.anticamper = getCvarInt("scr_mm_anticamper");
    
    level.campaction = "compass";
    if(GetCvar("scr_mm_campaction") != "" && GetCvar("scr_mm_campaction") != "compass")
        level.campaction = GetCvar("scr_mm_campaction");
}

anticamper(spawnpoint)
{
    if(!level.anticamp)
        return;

    wait 1;
    
    self _spawncamper(spawnpoint);
    self _anticamper();
}

_spawncamper(spawnpoint)
{
    self endon("disconnect");
    for(i = 0; i <= level.spawncamper; i++) {
        if(distance(self.origin, spawnpoint.origin) > level.spawncamprange || self.sessionstate != "playing")
            break;

        if(level.spawncamper == i) {
            self iPrintLnBold("^1Punished due to inactivity.");
            
            iPrintLn(codam\_mm_mmm::namefix(self.name) + " ^7Punished due to inactivity.");
            self thread [[ level.gtd_call ]]("goSpectate");
            break;
        }

        wait 1;
    }
}

_anticamper()
{
    level endon("mm_showdown");
    self endon("disconnect");
    
    /*if(!IsDefined(level.bombplanted))
        level.bombplanted = false;*/

    bombzone_A = getent("bombzone_A", "targetname"); // optimize all these spots level. ?
    bombzone_B = getent("bombzone_B", "targetname"); // optimize all these spots level. ?

    for(z = level.anticamper; z >= 0;/* /!\ */) {
        if(self.sessionstate != "playing"/* || level.bombplanted*/)
            break;
        
        position = self.origin;
        
        wait 1;

        if((IsDefined(bombzone_A) && IsDefined(bombzone_A.planting))
            || (IsDefined(bombzone_B) && IsDefined(bombzone_B.planting)))
            continue;
        
        if(distance(self.origin, position) > level.anticamprange) {
            if(z > (level.anticamper / 1.5))
                z += 3;
            else if(z > (level.anticamper / 2))
                z += 2;
            else
                z++;
        } else {
            z--;
            if(z == 10)
                self iPrintLn("^3Warning! ^7Better move it, soldier.");
        }
        
        if(z > level.anticamper) {
            z = level.anticamper;
            continue;
        }

        if(z == 0) {
            switch(level.campaction) {
                case "suicide":
                    iPrintLn(codam\_mm_mmm::namefix(self.name) + " ^7Punished due to inactivity.");
                    self thread [[ level.gtd_call ]]("suicide");
                break;
                case "compass":
                    iPrintLn(codam\_mm_mmm::namefix(self.name) + " ^7Marked on compass due to inactivity.");
                    campingid = codam\_mm_mmm::compassdb();
                    if(campingid != -1) {
                        objective_add(campingid, "current", self.origin, "gfx/hud/objective.tga");
                        if(IsDefined(self.pers["team"]) && IsDefined(level.roundbased)) { // fixes DM compass
                            if(self.pers["team"] == "axis")
                                team = "allies";
                            else if(self.pers["team"] == "allies")
                                team = "axis";
                            
                            if(IsDefined(team))
                                objective_team(campingid, team);
                        }

                        campingspot = self.origin;
                        while(distance(self.origin, campingspot) < (level.anticamprange + 500) && self.sessionstate == "playing"/* && !level.bombplanted*/) { // 500 units so it shows a little
                            objective_position(campingid, self.origin);
                            wait 0.05;
                        }
                        
                        objective_delete(campingid);
                        codam\_mm_mmm::compassdb(campingid);

                        z = level.anticamper / 2;
                        continue;
                    } else
                        iPrintLn("^1ERROR: ^7Unable to assign a camp ID to player " + codam\_mm_mmm::namefix(self.name) + "^7! Too many campers.");
                break;
                default:
                    iPrintLn(codam\_mm_mmm::namefix(self.name) + " ^7Punished due to inactivity.");
                    self thread [[ level.gtd_call ]]("goSpectate");
                break;
            }
            
            break;
        }
    }
}