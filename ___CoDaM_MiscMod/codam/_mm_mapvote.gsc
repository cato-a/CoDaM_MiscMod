// max hud elements = 31
// max archived hud elements = 31
// max localized string length = 256

init()
{
    level.mapvote_instruction = &"Press ^1FIRE ^7to vote";
    level.mapvote_titleVotes = &"Votes";

    precacheShader("white");

    level.mmgametype = getCvar("g_gametype");
    level.mmmapname = getCvar("mapname");

    level.mapvote = false;
    if(getCvarInt("scr_mm_mapvote"))
        level.mapvote = true;

    level.mapvotetime = 15;
    if(getCvarInt("scr_mm_mapvotetime") >= 10)
        level.mapvotetime = getCvarInt("scr_mm_mapvotetime");
    
    if(level.mapvotetime > 60)
        level.mapvotetime = 60;
    
    level.mapvotereplay = false;
    if(getCvarInt("scr_mm_mapvotereplay"))
        level.mapvotereplay = true;

    level.mapvoterandom = false;
    if(getCvarInt("scr_mm_mapvoterandom"))
        level.mapvoterandom = true;
    
    level.mapvotegametype = true;
    if(!getCvarInt("scr_mm_mapvotegametype"))
        level.mapvotegametype = false;
    
    level.mapvotesound = false;
    if(getCvarInt("scr_mm_mapvotesound"))
        level.mapvotesound = true;
    
    level.mapvote_minchoices = 2;
    level.mapvote_maxchoices = 10;
    level.mapvote_currentchoices = 0;
    level.mapvote_randomMapRotation = [];
    level.mapvote_list = [];
    level.mapvote_hud_mapnames = [];
    level.mapvote_hud_counts = [];
}

mapvote()
{
    if(!level.mapvote)
        return;
    
    wait 0.5;
    prepareMaps();

    if(level.mapvote_currentchoices < level.mapvote_minchoices) {
        level notify("voting_complete");
        return;
    }
    if(level.mapvote_list.size == 0)
        return;

    setupHud();
    thread runMapVote();
    level waittill("voting_complete");

    destroyHud();
}

prepareMaps()
{
    if(level.mapvoterandom) {
        level.mapvote_currentchoices++;
        level.mapvote_list[level.mapvote_list.size] = "mystery map";
    }

    if(level.mapvotereplay)
        level.mapvote_currentchoices++;

    if(getCvar("sv_mapRotation") == "")
        return;
        
    mapRotation = codam\_mm_mmm::strip(getCvar("sv_mapRotation"));

    for(i = 1; /* /!\ */; i++) {
        if(getCvar("sv_mapRotation" + i) != "")
            mapRotation = mapRotation + " " + codam\_mm_mmm::strip(getCvar("sv_mapRotation" + i));
        else
            break;
    }

    mapRotation = strTok(mapRotation, " ");
    if(!isDefined(mapRotation))
        return;

    _tmp = [];
    for(i = 0; i < mapRotation.size; i++) {
        arrElem = codam\_mm_mmm::strip(mapRotation[i]);
        if(arrElem != "")
            _tmp[_tmp.size] = arrElem;
    }

    mapRotation = _tmp;
    if(!isDefined(mapRotation))
        return;
    
    if(codam\_mm_mmm::in_array(mapRotation, level.mmmapname))
        mapRotation = codam\_mm_mmm::array_remove(mapRotation, level.mmmapname, true);
    
    _tmp = [];
    lastgt = level.mmgametype;
    for(i = 0; i < mapRotation.size;/* /!\ */) {
        switch(mapRotation[i]) {
            case "gametype":
                if((i + 1) < mapRotation.size)
                    lastgt = mapRotation[i + 1];
                i += 2;
            break;
            case "map":
                if((i + 1) < mapRotation.size) {
                    _tmp[_tmp.size]["gametype"] = lastgt;
                    _tmp[_tmp.size - 1]["map"]  = mapRotation[i + 1];
                }
                i += 2;
            break;
            default:
                iPrintLnBold("^1WARNING: ^7Error(s) detected in map rotation.");
                PrintLn("WARNING: Error(s) detected in map rotation.");
                i += 1;
            break;
        }
    }
    
    level.mapvote_randomMapRotation = codam\_mm_mmm::array_shuffle(_tmp);
    for(i = 0; i < level.mapvote_randomMapRotation.size; i++)
    {
        if(level.mapvote_currentchoices == level.mapvote_maxchoices)
            break;
        
        switch(level.mapvote_randomMapRotation[i]["gametype"]) {
            case "sd":
                gametypeColor = "^2";
            break;
            case "dm":
                gametypeColor = "^1";
            break;
            case "tdm":
                gametypeColor = "^4";
            break;
            case "bel":
                gametypeColor = "^3";
            break;
            default:
                gametypeColor = "^7";
            break;
        }
        gametypeDisplay = "(" + gametypeColor + level.mapvote_randomMapRotation[i]["gametype"] + "^7)";
        
        level.mapvote_list[level.mapvote_list.size] = level.mapvote_randomMapRotation[i]["map"] + " " + gametypeDisplay;
        level.mapvote_currentchoices++;
    }
    if(level.mapvotereplay)
        level.mapvote_list[level.mapvote_list.size] = "replay this map";
}

setupHud()
{
    // Destroy some unneeded hud elements since quantity is limited (max 62)
    players = getEntArray("player", "classname");
    for(i = 0; i < players.size; i++)
        if(isDefined(players[i]._stopwatch))
            players[i]._stopwatch destroy();

    if(isDefined(level.ham_hudscores)) {
        if(isDefined( level.gtd_call))
            teams = [[ level.gtd_call ]]("teamsPlaying");

        if(!isDefined(teams) || (teams.size < 1)) {
            teams = [];
            teams[teams.size] = "allies";
            teams[teams.size] = "axis";
        }

        for(i = 0; i < teams.size + 2; i++) {
            if(isDefined(level.ham_score["actual"]) && isDefined(level.ham_score["actual"][i]))
                level.ham_score["actual"][i] destroy();
            if(isDefined(level.ham_score["numteam"]) && isDefined(level.ham_score["numteam"][i]))
                level.ham_score["numteam"][i] destroy();
            if(isDefined(level.ham_score["alive"]) && isDefined(level.ham_score["alive"][i]))
                level.ham_score["alive"][i] destroy();
            if(isDefined(level.ham_score["icon"]) && isDefined(level.ham_score["icon"][i]))
                level.ham_score["icon"][i] destroy();
        }
    }

    players = getEntArray("player", "classname");
    for(i = 0; i < players.size; i++) {
        player = players[i];
        player.sessionstate = "spectator";
        player.spectatorclient = -1;
        resettimeout();
        player setClientCvar("g_scriptMainMenu", "main");
        player closeMenu();
    }

    // Countdown
    if(isDefined(level.clock))
        level.clock destroy();
    level.voteTimer = newHudElem();
    level.voteTimer.x = 320;
    level.voteTimer.y = 464;
    level.voteTimer.alignX = "center";
    level.voteTimer.alignY = "middle";
    level.voteTimer.font = "bigfixed";
    level.voteTimer.color = (1, 0.65, 0);
    additionalDelays = (0.2 + 0.1 + 0.05 + 1);
    level.voteTimer setTimer(level.mapvotetime + additionalDelays);

    // Offsets
    // id Tech 3 base resolution = 640*480
    level.screen_middle_x = 640/2; //320
    screen_middle_y = 480/2; //240
    level.background_width = 220;
    level.distance_between_mapnames = 21;
    level.mapNames_y = screen_middle_y - 75;

    // Header background
    level.vote_header = newHudElem();
    level.vote_header.alpha = .9;
    level.vote_header.alignX = "center";
    level.vote_header.x = level.screen_middle_x;
    level.vote_header.y = level.mapNames_y - 33;
    level.vote_header.color = (0.37, 0.37, 0.16);
    level.vote_header setShader("white", level.background_width, 19);
    level.vote_header.sort = 1;

    // Instructions title
    level.vote_instruction = newHudElem();
    level.vote_instruction.x = level.vote_header.x - 99;
    level.vote_instruction.y = level.vote_header.y + 3;
    level.vote_instruction.fontscale = 1.1;
    level.vote_instruction.label = level.mapvote_instruction;
    level.vote_instruction.sort = 2;

    // Vote count title
    level.vote_votes = newHudElem();
    level.vote_votes.x = level.vote_instruction.x + 163;
    level.vote_votes.y = level.vote_instruction.y;
    level.vote_votes.fontscale = level.vote_instruction.fontscale;
    level.vote_votes.label = level.mapvote_titleVotes;
    level.vote_votes.sort = level.vote_instruction.sort;
    
    // Main background
    level.vote_hud_bgnd = newHudElem();
    level.vote_hud_bgnd.alpha = .9;
    level.vote_hud_bgnd.alignX = "center";
    level.vote_hud_bgnd.x = level.vote_header.x;
    level.vote_hud_bgnd.y = level.vote_header.y + 19;
    background_height = level.mapvote_currentchoices * 22;
    level.vote_hud_bgnd setShader("black", level.background_width, background_height);
    level.vote_hud_bgnd.sort = 1;

    mapNames_x = level.vote_hud_bgnd.x - 93;
    votes_x = mapNames_x + 172;

    // Map names
    mapNames_x = level.vote_hud_bgnd.x - 24;
    for(i = 0; i < level.mapvote_currentchoices; i++) {
        level.mapvote_hud_mapnames[i] = newHudElem();
        level.mapvote_hud_mapnames[i].alignX = "center";
        level.mapvote_hud_mapnames[i].alignY = "middle";
        level.mapvote_hud_mapnames[i].x = mapNames_x;
        if(i == 0)
            level.mapvote_hud_mapnames[i].y = level.mapNames_y;
        else
            level.mapvote_hud_mapnames[i].y = level.mapvote_hud_mapnames[i-1].y + level.distance_between_mapnames;

        mapname = level.mapvote_list[i];
        mapname_localized = makeLocalizedString(mapname);
        level.mapvote_hud_mapnames[i] setText(mapname_localized);

        level.mapvote_hud_mapnames[i].sort = 4;

        if(mapname == "mystery map")
            level.mapvote_hud_mapnames[i].color = (1, 0, 1);
        else if(mapname == "replay this map")
            level.mapvote_hud_mapnames[i].color = (0, 1, 1); 
    }
    
    // Votes counts
    for(i = 0; i < level.mapvote_currentchoices; i++) {
        level.mapvote_hud_counts[i] = newHudElem();
        level.mapvote_hud_counts[i].alignX = "center";
        level.mapvote_hud_counts[i].alignY = "middle";
        level.mapvote_hud_counts[i].x = votes_x;
        if(i == 0)
            level.mapvote_hud_counts[i].y = level.mapNames_y;
        else
            level.mapvote_hud_counts[i].y = level.mapvote_hud_counts[i-1].y + level.distance_between_mapnames;
        level.mapvote_hud_counts[i] setValue(0);
        level.mapvote_hud_counts[i].sort = 4;
    }
}

destroyHud()
{
    level.voteTimer destroy();
    level.vote_instruction destroy();
    level.vote_votes destroy();
    level.vote_header destroy();
    level.vote_hud_bgnd destroy();

    for(i = 0; i < level.mapvote_currentchoices; i++)
        level.mapvote_hud_mapnames[i] destroy();
    for(i = 0; i < level.mapvote_currentchoices; i++)
        level.mapvote_hud_counts[i] destroy();
    
    players = getEntArray("player", "classname");
    for(i = 0; i < players.size; i++)
        if(isDefined(players[i].vote_indicator))
            players[i].vote_indicator destroy();
}

runMapVote()
{
    mapCandidateIndex = 0;

    if(level.mapvoterandom) {
        randMap = randomInt(level.mapvote_randomMapRotation.size);
        level.mapcandidate[mapCandidateIndex]["map"] = level.mapvote_randomMapRotation[randMap]["map"];
        level.mapcandidate[mapCandidateIndex]["mapname"] = "mystery map";
        level.mapcandidate[mapCandidateIndex]["gametype"] = level.mapvote_randomMapRotation[randMap]["gametype"];
        level.mapcandidate[mapCandidateIndex]["votes"] = 0;

        mapCandidateIndex++;
    }
    
    for(i = 0; i < level.mapvote_randomMapRotation.size; i++) {
        if(!isDefined(level.mapvote_randomMapRotation[i])) {
            printLn("WARNING: Error detected in map rotation (runMapVote()). i = " + i);
            break;
        }

        level.mapcandidate[mapCandidateIndex]["map"] = level.mapvote_randomMapRotation[i]["map"];
        level.mapcandidate[mapCandidateIndex]["mapname"] = level.mapvote_randomMapRotation[i]["map"];
        level.mapcandidate[mapCandidateIndex]["gametype"] = level.mapvote_randomMapRotation[i]["gametype"];
        level.mapcandidate[mapCandidateIndex]["votes"] = 0;

        mapCandidateIndex++;
    }
    
    if(level.mapvotereplay) {
        lastChoiceIndex = level.mapvote_currentchoices - 1;
        level.mapcandidate[lastChoiceIndex]["map"] = level.mmmapname;
        level.mapcandidate[lastChoiceIndex]["mapname"] = "replay this map";
        level.mapcandidate[lastChoiceIndex]["gametype"] = level.mmgametype;
        level.mapcandidate[lastChoiceIndex]["votes"] = 0;
    }
    
    players = getEntArray("player", "classname");
    for(i = 0; i < players.size; i++)
        players[i] thread playerVote();
    
    thread voteLogic();
    wait 0.1;
}

voteLogic()
{
    for(; level.mapvotetime >= 0; level.mapvotetime--) {
        for(x = 0; x < 10; x++) {
            // Count votes
            for(i = 0; i < level.mapvote_currentchoices; i++)
                level.mapcandidate[i]["votes"] = 0;

            players = getEntArray("player", "classname");
            for(i = 0; i < players.size; i++)
                if(isDefined(players[i].votechoice))
                    level.mapcandidate[players[i].votechoice]["votes"]++;
            
            // Display updated count
            for(i = 0; i < level.mapvote_currentchoices; i++)
                level.mapvote_hud_counts[i] setValue(level.mapcandidate[i]["votes"]);

            wait 0.1;
        }
    }

    wait 0.2;

    nextmapnum  = 0;
    topvotes = 0;

    for(i = 0; i < level.mapvote_currentchoices; i++) {
        if(level.mapcandidate[i]["votes"] > topvotes) {
            nextmapnum = i;
            topvotes = level.mapcandidate[i]["votes"];
        }
    }
    setMapWinner(nextmapnum);
}

setMapWinner(val)
{
    map = level.mapcandidate[val]["map"];
    mapname	= level.mapcandidate[val]["mapname"];
    gametype = level.mapcandidate[val]["gametype"];

    setCvar("sv_mapRotationCurrent", " gametype " + gametype + " map " + map);

    wait 0.1;
    level notify("voting_done");
    wait 0.05;

    level.voteTimer fadeOverTime(1);
    level.vote_instruction fadeOverTime(1);
    level.vote_votes fadeOverTime(1);
    level.vote_header fadeOverTime(1);
    level.vote_hud_bgnd fadeOverTime(1);
    for(i = 0; i < level.mapvote_currentchoices; i++)
        level.mapvote_hud_mapnames[i] fadeOverTime(1);
    for(i = 0; i < level.mapvote_currentchoices; i++)
        level.mapvote_hud_counts[i] fadeOverTime(1);

    level.voteTimer.alpha = 0;
    level.vote_instruction.alpha = 0;
    level.vote_votes.alpha = 0;
    level.vote_header.alpha = 0;
    level.vote_hud_bgnd.alpha = 0;
    for(i = 0; i < level.mapvote_currentchoices; i++)
        level.mapvote_hud_mapnames[i].alpha = 0;
    for(i = 0; i < level.mapvote_currentchoices; i++)
        level.mapvote_hud_counts[i].alpha = 0;

    players = getEntArray("player", "classname");
    for(i = 0; i < players.size; i++) {
        if(isDefined(players[i].vote_indicator)) {
            players[i].vote_indicator fadeOverTime(1);
            players[i].vote_indicator.alpha = 0;
        }
    }

    wait 1.25;
    iPrintLnBold(" ");
    iPrintLnBold(" ");
    iPrintLnBold(" ");
    iPrintLnBold("The winner is");
    iPrintLnBold("^2" + mapname);
    if(level.mapvotegametype && (mapname != "replay this map" && mapname != "mystery map"))
        iPrintLnBold("^2" + getGametypeName(gametype));
    else
        iPrintLnBold(" ");

    wait 4;
    level notify("voting_complete");
}

playerVote()
{
    level endon("voting_done");
    self endon("disconnect");

    self.vote_indicator = newClientHudElem(self);
    self.vote_indicator.archived = false;
    self.vote_indicator.alignX = "center";
    self.vote_indicator.alignY = "middle";
    self.vote_indicator.x = level.screen_middle_x;
    self.vote_indicator.alpha = 0;
    self.vote_indicator.color = (0.20, 1, 0.76);
    self.vote_indicator setShader("white", level.background_width - 8, 17);
    self.vote_indicator.sort = 3;

    hasVoted = false;

    for(;;) {
        wait 0.01;

        if(self attackButtonPressed()) {
            if(!hasVoted) {
                self.vote_indicator.alpha = 0.3;
                self.votechoice = 0;
                hasVoted = true;
            }
            else
                self.votechoice++;

            if(self.votechoice >= level.mapvote_currentchoices)
                self.votechoice = 0;
            
            if(level.mapvotegametype
                && (level.mapcandidate[self.votechoice]["mapname"] != "replay this map" && level.mapcandidate[self.votechoice]["mapname"] != "mystery map"))
                self iPrintLn("You have voted for ^2" + codam\_mm_mmm::strTru(level.mapcandidate[self.votechoice]["mapname"], 13) + " ^7(" + level.mapcandidate[self.votechoice]["gametype"] + ")");
            else
                self iPrintLn("You have voted for ^2" + codam\_mm_mmm::strTru(level.mapcandidate[self.votechoice]["mapname"], 13));

            self.vote_indicator.y = (level.mapNames_y + 2) + (self.votechoice * level.distance_between_mapnames);

            if(level.mapvotesound)
                self playLocalSound("hq_score"); // training_good_grenade_throw // Doesn't work
        }

        while(self attackButtonPressed())
            wait 0.01;
    }
}

getGametypeName(gt)
{
    switch(gt) {
        case "dm": gtname = "Deathmatch"; break;
        case "tdm": gtname = "Team Deathmatch"; break;
        case "sd": gtname = "Search and Destroy"; break;
        case "re": gtname = "Retrieval"; break;
        case "bel": gtname = "Behind Enemy Lines"; break;
        default: gtname = gt; break;
    }

    return gtname;
}