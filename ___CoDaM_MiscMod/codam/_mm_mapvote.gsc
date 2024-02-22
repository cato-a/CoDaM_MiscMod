//max hud elements = 31
//max archived hud elements = 31
//max localized string length = 256

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
    level.mapvote_list = "";
    level.mapvote_hud_counts = [];
}

mapvote()
{
    if(!level.mapvote)
        return;
    
    wait 0.5;
    prepareMaps();

    if(level.mapvote_currentchoices < level.mapvote_minchoices)
    {
        level notify("voting_complete");
        return;
    }
    if(level.mapvote_list == "")
        return;

    setupHud();
    thread runMapVote();
    level waittill("voting_complete");

    destroyHud();
}

prepareMaps()
{
    if(level.mapvotereplay)
        level.mapvote_currentchoices++;

    if(level.mapvoterandom)
    {
        level.mapvote_currentchoices++;
        level.mapvote_list = "mystery map" + "\n\n";
    }
        
    if(getCvar("sv_mapRotation") == "")
        return;
        
    mapRotation = codam\_mm_mmm::strip(getCvar("sv_mapRotation"));

    for(i = 1; /* /!\ */; i++)
    {
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
    for(i = 0; i < mapRotation.size;/* /!\ */)
    {
        if(level.mapvote_currentchoices == level.mapvote_maxchoices)
            break;
        
        switch(mapRotation[i])
        {
            case "gametype":
                if((i + 1) < mapRotation.size)
                    lastgt = mapRotation[i + 1];
                i += 2;
            break;
            case "map":
                if((i + 1) < mapRotation.size)
                {
                    _tmp[_tmp.size]["gametype"] = lastgt;
                    _tmp[_tmp.size - 1]["map"]  = mapRotation[i + 1];
                    
                    level.mapvote_currentchoices++;
                }
                i += 2;
            break;
            default:
                iPrintLnBold("^1WARNING: ^7Error(s) detected in map rotation.");
                printLn("WARNING: Error(s) detected in map rotation.");
                i += 1;
            break;
        }
    }
    
    level.mapvote_randomMapRotation = codam\_mm_mmm::array_shuffle(_tmp);
    for(i = 0; i < level.mapvote_randomMapRotation.size; i++)
    {
        level.mapvote_list += level.mapvote_randomMapRotation[i]["map"] + " (" + level.mapvote_randomMapRotation[i]["gametype"] + ")";
        
        if(i != level.mapvote_randomMapRotation.size - 1)
            level.mapvote_list += "\n\n";
    }
    if(level.mapvotereplay)
        level.mapvote_list += "\n\n" + "replay this map";
}

setupHud()
{
    // Destroy some unneeded hud elements since quantity is limited (max 62)

    if(isDefined(level.clock))
        level.clock destroy();

    players = getEntArray("player", "classname");
    for(i = 0; i < players.size; i++)
        if (isdefined(players[i]._stopwatch))
            players[i]._stopwatch destroy();

    if (isDefined(level.ham_hudscores))
    {
        if ( isdefined( level.gtd_call ) )
            teams = [[ level.gtd_call ]]( "teamsPlaying" );
        if ( !isdefined( teams ) || ( teams.size < 1 ) )
        {
            teams = [];
            teams[ teams.size ] = "allies";
            teams[ teams.size ] = "axis";
        }
        for ( i = 0; i < teams.size + 2; i++ )
        {
            if ( isdefined( level.ham_score[ "actual" ] ) &&
                 isdefined( level.ham_score[ "actual" ][ i ] ) )
                level.ham_score[ "actual" ][ i ] destroy();
            if ( isdefined( level.ham_score[ "numteam" ] ) &&
                 isdefined( level.ham_score[ "numteam" ][ i ] ) )
                level.ham_score[ "numteam" ][ i ] destroy();
            if ( isdefined( level.ham_score[ "alive" ] ) &&
                 isdefined( level.ham_score[ "alive" ][ i ] ) )
                level.ham_score[ "alive" ][ i ] destroy();
            if ( isdefined( level.ham_score[ "icon" ] ) &&
                 isdefined( level.ham_score[ "icon" ][ i ] ) )
                level.ham_score[ "icon" ][ i ] destroy();
        }
    }

    // Will close scoreboard
    players = getEntArray("player", "classname");
    for(i = 0; i < players.size; i++)
    {
        player = players[i];
        player.sessionstate = "spectator";
        player.spectatorclient = -1;
        resettimeout(); // I don't know what this is for
        player setClientCvar("g_scriptMainMenu", "main");
        player closeMenu();
    }

    // Offsets
    level.xMapName = 260;
    level.yMapName = 160;
    xMapVotes = level.xMapName + 100;
    yTitles = level.yMapName - 23;
    level.distanceBetween = 20;
    level.backgroundWidth = 139;

    // Countdown
    level.voteTimer = newHudElem();
    level.voteTimer.x = 320;
    level.voteTimer.y = 464;
    level.voteTimer.alignX = "center";
    level.voteTimer.alignY = "middle";
    level.voteTimer.font = "bigfixed";
    level.voteTimer.color = (0, 1, 0);
    additionalDelays = (0.2 + 0.1 + 0.05 + 1);
    level.voteTimer setTimer(level.mapvotetime + additionalDelays);
    
    // Instructions
    level.vote_instruction = newHudElem();
    level.vote_instruction.x = level.xMapName - 2;
    level.vote_instruction.y = yTitles;
    level.vote_instruction.fontscale = .8;
    level.vote_instruction.label = level.mapvote_instruction;
    level.vote_instruction.sort = 2;

    // Title of the vote count
    level.vote_votes = newHudElem();
    level.vote_votes.x = xMapVotes - 7;
    level.vote_votes.y = yTitles;
    level.vote_votes.fontscale = .8;
    level.vote_votes.label = level.mapvote_titleVotes;
    level.vote_votes.sort = 2;

    // Header background
    level.vote_header = newHudElem();
    level.vote_header.alpha = .9;
    level.vote_header.x = level.xMapName - 9;
    level.vote_header.y = yTitles - 4;
    level.vote_header.color = (0.37, 0.37, 0.16);
    level.vote_header setShader("white", level.backgroundWidth, 17);
    level.vote_header.sort = 1;

    // Main background
    level.vote_hud_bgnd = newHudElem();
    level.vote_hud_bgnd.alpha = .9;
    level.vote_hud_bgnd.x = level.xMapName - 9;
    level.vote_hud_bgnd.y = level.vote_header.y + 17.5;
    backgroundHeight = level.mapvote_currentchoices * 23;
    level.vote_hud_bgnd setShader("black", level.backgroundWidth, backgroundHeight);
    level.vote_hud_bgnd.sort = 1;

    // Choices
    level.vote_mapList = newHudElem();
    level.vote_mapList.x = level.xMapName;
    level.vote_mapList.y = level.yMapName;
    mapvote_list_localized = makeLocalizedString(level.mapvote_list);
    level.vote_mapList setText(mapvote_list_localized);
    level.vote_mapList.fontscale = .9;
    level.vote_mapList.sort = 4;

    // Votes counts
    for(i = 0; i < level.mapvote_currentchoices; i++)
    {
        level.mapvote_hud_counts[i] = newHudElem();
        level.mapvote_hud_counts[i].x = xMapVotes;
        if(i == 0)
            level.mapvote_hud_counts[i].y = level.yMapName;
        else
            level.mapvote_hud_counts[i].y = level.mapvote_hud_counts[i-1].y + level.distanceBetween;
        level.mapvote_hud_counts[i] setValue(0);
        level.mapvote_hud_counts[i].fontscale = .9;
        level.mapvote_hud_counts[i].sort = 4;
    }
}

destroyHud()
{
    printLn("######## destroyHud");

    level.voteTimer destroy();
    level.vote_instruction destroy();
    level.vote_votes destroy();
    level.vote_header destroy();
    level.vote_hud_bgnd destroy();
    level.vote_mapList destroy();
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

    if(level.mapvoterandom)
    {
        randMap = randomInt(level.mapvote_randomMapRotation.size);
        level.mapcandidate[mapCandidateIndex]["map"] = level.mapvote_randomMapRotation[randMap]["map"];
        level.mapcandidate[mapCandidateIndex]["mapname"] = "mystery map";
        level.mapcandidate[mapCandidateIndex]["gametype"] = level.mapvote_randomMapRotation[randMap]["gametype"];
        level.mapcandidate[mapCandidateIndex]["votes"] = 0;

        mapCandidateIndex ++;
    }
    
    for (i = 0; i < level.mapvote_randomMapRotation.size; i++)
    {
        if(!isDefined(level.mapvote_randomMapRotation[i]))
        {
            printLn("WARNING: Error detected in map rotation (runMapVote()). i = " + i);
            break;
        }

        level.mapcandidate[mapCandidateIndex]["map"] = level.mapvote_randomMapRotation[i]["map"];
        level.mapcandidate[mapCandidateIndex]["mapname"] = level.mapvote_randomMapRotation[i]["map"];
        level.mapcandidate[mapCandidateIndex]["gametype"] = level.mapvote_randomMapRotation[i]["gametype"];
        level.mapcandidate[mapCandidateIndex]["votes"] = 0;

        mapCandidateIndex ++;
    }
    
    if(level.mapvotereplay)
    {
        lastChoice = level.mapvote_currentchoices;
        level.mapcandidate[lastChoice]["map"] = level.mmmapname;
        level.mapcandidate[lastChoice]["mapname"] = "replay this map";
        level.mapcandidate[lastChoice]["votes"] = 0;
    }
    
    players = getEntArray("player", "classname");
    for(i = 0; i < players.size; i++)
    {
        players[i] thread playerVote();
    }
    thread voteLogic();
    wait 0.1;
}

voteLogic()
{
    for (; level.mapvotetime >= 0; level.mapvotetime--)
    {
        for (x = 0; x < 10; x++)
        {
            // Count votes
            for (i = 0; i < level.mapvote_currentchoices; i++)
                level.mapcandidate[i]["votes"] = 0;

            players = getEntArray("player", "classname");
            for (i = 0; i < players.size; i++)
                if (isDefined(players[i].votechoice))
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

    for (i = 0; i < level.mapvote_currentchoices; i++)
    {
        if (level.mapcandidate[i]["votes"] > topvotes)
        {
            nextmapnum = i;
            topvotes = level.mapcandidate[i]["votes"];
        }
    }
    setMapWinner(nextmapnum);
}

setMapWinner(val)
{
    printLn("######## setMapWinner");

    map = level.mapcandidate[val]["map"];
    mapname	= level.mapcandidate[val]["mapname"];
    gametype = level.mapcandidate[val]["gametype"];

    setCvar("sv_mapRotationCurrent", " gametype " + gametype + " map " + map);

    wait 0.1;
    level notify("voting_done");
    wait 0.05;

    iPrintLnBold(" ");
    iPrintLnBold(" ");
    iPrintLnBold(" ");
    iPrintLnBold("The winner is");
    iPrintLnBold("^2" + map);
    iPrintLnBold(" ");

    level.voteTimer fadeOverTime(1);
    level.vote_instruction fadeOverTime(1);
    level.vote_votes fadeOverTime(1);
    level.vote_header fadeOverTime(1);
    level.vote_hud_bgnd fadeOverTime(1);
    level.vote_mapList fadeOverTime(1);
    for(i = 0; i < level.mapvote_currentchoices; i++)
        level.mapvote_hud_counts[i] fadeOverTime(1);

    level.voteTimer.alpha = 0;
    level.vote_instruction.alpha = 0;
    level.vote_votes.alpha = 0;
    level.vote_header.alpha = 0;
    level.vote_hud_bgnd.alpha = 0;
    level.vote_mapList.alpha = 0;
    for(i = 0; i < level.mapvote_currentchoices; i++)
        level.mapvote_hud_counts[i].alpha = 0;

    players = getEntArray("player", "classname");
    for (i = 0; i < players.size; i++)
    {
        if (isDefined(players[i].vote_indicator))
        {
            players[i].vote_indicator fadeOverTime(1);
            players[i].vote_indicator.alpha = 0;
        }
    }
    wait 4;
    printLn("######## notify voting_complete");
    level notify("voting_complete");
}

playerVote()
{
    level endon("voting_done");
    self endon("disconnect");

    self.vote_indicator = newClientHudElem(self);
    self.vote_indicator.archived = false;
    self.vote_indicator.x = level.xMapName - 5;
    self.vote_indicator.alpha = 0;
    self.vote_indicator.color = (0.20, 1, 0.76);
    self.vote_indicator setShader("white", level.backgroundWidth - 8, 16);
    self.vote_indicator.sort = 3;

    hasVoted = false;

    for (;;)
    {
        wait 0.01;

        if (self attackButtonPressed())
        {
            if (!hasVoted)
            {
                self.vote_indicator.alpha = 0.3;
                self.votechoice = 0;
                hasVoted = true;
            }
            else
            {
                self.votechoice++;
            }

            if(self.votechoice >= level.mapvote_currentchoices)
                self.votechoice = 0;

            self.vote_indicator.y = (level.yMapName - 2) + (self.votechoice * level.distanceBetween);
        }

        while(self attackButtonPressed())
            wait 0.01;
    }
}