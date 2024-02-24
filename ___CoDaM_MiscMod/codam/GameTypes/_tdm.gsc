
//
///////////////////////////////////////////////////////////////////////////////
main()
{
	codam\utils::_debug( "I'M IN C_TDM" );

	// First time in, call the CoDaM initialization function with
	// ... the gametype registration function (which initializes
	// ... gametype-specific callbacks) and the actual game type string
	register = codam\init::main( ::gtRegister, "tdm" );

	[[ level.gtd_call ]]( "registerSpawn", "mp_teamdeathmatch_spawn",
								"nearteam" );

	return;
}

//
///////////////////////////////////////////////////////////////////////////////
gtRegister( register, post )
{
	// Since CoDaM treats the first registration of a callback as the
	// ... "default" call, must ensure that gametype-specific functions
	// ... are registered first during Init.

	if ( IsDefined( post ) )
		return;

	// Script-level	callbacks
	[[ register ]](	   "StartGameType", ::StartGameType );
	[[ register ]](	   "PlayerConnect", codam\callbacks::PlayerConnect );
	[[ register ]](	"PlayerDisconnect", codam\callbacks::PlayerDisconnect );
	[[ register ]](	    "PlayerDamage", codam\callbacks::PlayerDamage );
	[[ register ]](	    "PlayerKilled", codam\callbacks::PlayerKilled );

	// Game-type callbacks
	[[ register ]](   "finishPlayerKilled",
					codam\callbacks::finishPlayerKilled );
	[[ register ]](	        "gt_startGame", ::startGame );
	[[ register ]](	      "gt_autoBalance", ::autoBalance );
	[[ register ]](	      "gt_checkUpdate", ::checkUpdate );
	[[ register ]](            "gt_endMap", ::endMap );
	[[ register ]](          "gt_endRound", ::endRound );
	[[ register ]](       "gt_spawnPlayer", ::spawnPlayer );
	[[ register ]](    "gt_spawnSpectator", ::spawnSpectator );
	[[ register ]]( "gt_spawnIntermission", ::spawnIntermission );
	[[ register ]](		  "gt_respawn", ::respawn );
	[[ register ]](       "gt_menuHandler", ::menuHandler );
	[[ register ]](  "gt_timeLimitReached", ::timeLimitReached );
	[[ register ]]( "gt_scoreLimitReached", ::scoreLimitReached );

	return;
}

//
///////////////////////////////////////////////////////////////////////////////
StartGameType( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
				b0, b1,	b2, b2,	b4, b5,	b6, b7,	b8, b9 )
{
	// Call	the CoDaM initialization function without any args to
	// continue with framework/custom mods initialization.
	codam\init::main();

	if( !IsDefined( game[ "gamestarted" ] ) )
	{
		if ( level.ham_shortversion != "1.1" )
		{
			makeCvarServerInfo( "ui_tdm_timelimit", "30" );
			makeCvarServerInfo( "ui_tdm_scorelimit", "100" );

			game[ "menu_serverinfo" ] = "serverinfo_" +
							level.ham_g_gametype;
			precacheMenu( game[ "menu_serverinfo" ] );
		}

		[[ level.gtd_call ]]( "scoreboard" );
	}

	// Last call to CoDaM init to cause any last-minutes framework to
	// start.
	codam\init::main();

	game[ "gamestarted" ] =	true;
	[[ level.gtd_call ]]( "setClientNameMode", "auto_change" );
	thread [[ level.gtd_call ]]( "gt_startGame" );
	return;
}

//
///////////////////////////////////////////////////////////////////////////////
menuHandler( menu, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	self endon( "end_player" );

	for(;;)
	{
		resp = self [[ level.gtd_call ]]( "menuHandler", menu );

		if ( !IsDefined( resp ) || ( resp.size < 2 ) ||
		     !IsDefined( resp[ 0 ] ) || !IsDefined( resp[ 1 ] ) )
		{
			// Shouldn't happen ... but just in case
			wait( 1 );
			continue;
		}

		val = resp[ 1 ];
		switch ( resp[ 0 ] )
		{
		  case "team":
		  	switch ( val )
		  	{
		  	  case "spectator":
				if ( self.pers[ "team" ] != "spectator" )
					self [[ level.gtd_call ]](
								"goSpectate" );

				menu = undefined;
				break;
		  	  default:
		  	  	if ( ( val == "" ) ||
		  	  	     ![[ level.gtd_call ]]( "isTeam", val ) )
				{
					// Team not playing, try again!
					break;
				}

				if ( IsDefined( self.pers[ "team" ] ) &&
				     ( val == self.pers[ "team" ] ) )
				{
					// Same team selected!
					menu = undefined;
					break;
				}

				// Still alive ... changing teams?
				if ( self.sessionstate == "playing" )
					self [[ level.gtd_call ]]( "suicide" );

				// Okay, selected new team ...
				self notify( "end_respawn" );

				self.pers[ "team" ] = val;
				self.pers[ "weapon" ] = undefined;
				self.pers[ "savedmodel" ] = undefined;

				menu = game[ "menu_weapon_" + val ];
				self SetClientCvar( "g_scriptMainMenu", menu );
				self SetClientCvar( level.ui_weapontab, "1" );
				break;
		  	}
		  	break;
		  case "weapon":
			if ( ![[ level.gtd_call ]]( "isTeam",
							self.pers[ "team" ] ) )
			{
				// No team selected yet?
				menu = game[ "menu_team" ];
				break;
			}

			if ( !self [[ level.gtd_call ]]( "isWeaponAllowed",
									val ) )
			{
				self iPrintLn(
					"^3*** Weapon has been disabled." );
				break;
			}

			weapon = val;

			if ( IsDefined( self.pers[ "weapon" ] ) &&
			     ( self.pers[ "weapon" ] == weapon ) )
			{
				menu = undefined;
				break;	// Same weapon selected!
			}

			// Is the weapon available?
			weapon = self [[ level.gtd_call ]]( "assignWeapon",
									weapon );
			if ( !IsDefined( weapon ) )
			{
				self iPrintLn( "^3*** Weapon is unavailable." );
				break;
			}

			menu = undefined;

			if ( !IsDefined( self.pers[ "weapon" ] ) )
			{
				// First selected weapon ...
				self.pers[ "weapon" ] = weapon;
				switch ( level.ham_g_gametype )
				{
				  case "hq":
					self thread [[ level.gtd_call ]](
								"gt_respawn" );
					break;
				  default:
					self [[ level.gtd_call ]](
							"gt_spawnPlayer" );
					break;
				}

				self thread [[ level.gtd_call ]](
							"printJoinedTeam",
							 self.pers[ "team" ] );
			}
			else
			{
				// Already have a weapon, wait 'til next spawn
				self.pers[ "weapon" ] = weapon;

				// End of map will take care of storing player's
				// new weapon.  Need this in case a map_restart
				// is done.
				self [[ level.gtd_call ]]( "savePlayer" );

				if ( maps\mp\gametypes\_teams::useAn( weapon ) )
					text = &"MPSCRIPT_YOU_WILL_RESPAWN_WITH_AN";
				else
					text = &"MPSCRIPT_YOU_WILL_RESPAWN_WITH_A";

				weaponname = maps\mp\gametypes\_teams::getWeaponName( weapon );
				self iPrintLn( text, weaponname );
			}
		  	break;
		  case "menu":
			if ( ( val == "weapon" ) &&
		  	     IsDefined( self.pers[ "team" ] ) )
			  	menu = game[ "menu_weapon_" +
			  				self.pers[ "team" ] ];
		  	break;
		  default:
		  	menu = undefined;
		  	break;
		}
	}
}

//
///////////////////////////////////////////////////////////////////////////////
spawnPlayer( text, a1, method, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	codam\utils::debug( 80, "tdm/spawnPlayer:: |", self.name, "|",
			self.pers[ "team" ], "|", self.pers[ "weapon" ], "|" );

	_team = self.pers[ "team" ];

	self.sessionteam = self [[ level.gtd_call ]]( "sessionteam" );

	// Save player's info across map rotations
	self [[ level.gtd_call ]]( "savePlayer" );

	// Previously spawned ...
	if ( IsDefined( self.spawned ) )
		return;

	// Make it so ...
	self [[ level.gtd_call ]]( "spawnPlayer" );

	level thread [[ level.gtd_call ]]( "gt_updateTeamStatus" );

	if ( IsDefined( self.pers[ "weapon1" ] ) &&
	     IsDefined( self.pers[ "weapon2" ] ) )
	{
		/*self [[ level.gtd_call ]]( "assignWeaponSlot", "primary",
							self.pers[ "weapon1" ],
							undefined, true );
		self [[ level.gtd_call ]]( "assignWeaponSlot", "primaryb",
							self.pers[ "weapon2" ],
							undefined, true );*/
		self [[ level.gtd_call ]]( "assignWeaponSlot", "primary",
							self.pers[ "weapon1" ], undefined );
		self [[ level.gtd_call ]]( "assignWeaponSlot", "primaryb",
							self.pers[ "weapon2" ], undefined );
		_weap = self.pers[ "spawnweapon" ];
		if ( !IsDefined( _weap ) || ( _weap == "none" ) )
			_weap = self.pers[ "weapon1" ];
		self setSpawnWeapon( _weap );
		self switchToWeapon( _weap );
	}
	else
	{
		_weap = self.pers[ "weapon" ];

		__weap = self [[ level.gtd_call ]]( "assignWeaponSlot",
							"primary", _weap );
		self setSpawnWeapon( __weap );
		self switchToWeapon( __weap );
	}

	self [[ level.gtd_call ]]( "givePistol" );
	self [[ level.gtd_call ]]( "giveGrenade", _weap );

	switch ( level.ham_g_gametype )
	{
	  case "dm":
		text = &"DM_KILL_OTHER_PLAYERS";
		break;
	  case "re":
	  	if ( !level.allowrespawn &&
		     game[ "mapstarted" ] )
			self.spawned = true;

		if ( _team == game[ "re_attackers" ] )
			text = game[ "re_attackers_obj_text" ];
		else if ( _team == game[ "re_defenders" ] )
			text = game[ "re_defenders_obj_text" ];
		break;
	  case "sd":
	  	if ( !level.allowrespawn &&
		     game[ "mapstarted" ] )
			self.spawned = true;

		if ( _team == game[ "attackers" ] )
			text = &"SD_OBJ_ATTACKERS";
		else if ( _team == game[ "defenders" ] )
			text = &"SD_OBJ_DEFENDERS";
		break;
	  case "tdm":
		if ( _team == "allies" )
			text = &"TDM_KILL_AXIS_PLAYERS";
		else if( _team == "axis" )
			text = &"TDM_KILL_ALLIED_PLAYERS";
		break;
	  default:
		// New gametype?
	  	break;
	}

	if ( IsDefined( text ) )
	{
		if ( IsDefined( a1 ) )
			self SetClientCvar( "cg_objectiveText", text, a1 );
		else
			self SetClientCvar( "cg_objectiveText", text );
	}

	return;
}

//
///////////////////////////////////////////////////////////////////////////////
spawnSpectator( origin, angles, spClass, method, text, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	level [[ level.gtd_call ]]( "resetPlayer", self );

	switch ( level.ham_g_gametype )
	{
	  case "tdm":
	  	spClass = "mp_teamdeathmatch_intermission";
	  	text = &"TDM_ALLIES_KILL_AXIS_PLAYERS";
	  	break;
	  case "dm":
	  	spClass = "mp_deathmatch_intermission";
		text = &"DM_KILL_OTHER_PLAYERS";
	  	break;
	  case "sd":
	  	spClass = "mp_searchanddestroy_intermission";
		if ( game[ "attackers" ] == "allies" )
			text = &"SD_OBJ_SPECTATOR_ALLIESATTACKING";
		else
			text = &"SD_OBJ_SPECTATOR_AXISATTACKING";
	  	break;
	  case "re":
	  	spClass = "mp_retrieval_intermission";
	  	text = game[ "re_spectator_obj_text" ];	// From map script
	  	break;
	  default:
		// New gametype?
	  	break;
	}

	if ( IsDefined( spClass ) )
		self [[ level.gtd_call ]]( "spawnSpectator", spClass,
								origin, angles,
								method );
	if ( IsDefined( text ) )
	{
		if ( IsDefined( a5 ) )
			self SetClientCvar( "cg_objectiveText", text, a5 );
		else
			self SetClientCvar( "cg_objectiveText", text );
	}

	self thread [[ level.gtd_call ]]( "manageSpectate", "spec" );

	level thread [[ level.gtd_call ]]( "gt_updateTeamStatus" );
	return;
}

//
///////////////////////////////////////////////////////////////////////////////
spawnIntermission( spClass, method, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	switch ( level.ham_g_gametype )
	{
	  case "sd":
	  	spClass = "mp_searchanddestroy_intermission";
	  	break;
	  case "re":
	  	spClass = "mp_retrieval_intermission";
	  	break;
	  default:
	  	if ( !IsDefined( spClass ) )
		  	spClass = "mp_teamdeathmatch_intermission";
	  	break;
	}

	self [[ level.gtd_call ]]( "spawnIntermission", spClass, method );
	return;
}

//
///////////////////////////////////////////////////////////////////////////////
respawn( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	self endon( "end_respawn" );
	self endon( "spawned" );

	if( !IsDefined( self.pers[ "weapon" ] ) )
		return;		// No weapon?

	self [[ level.gtd_call ]]( "respawn" );

	wait( 0.05 );	// Get some air ...

	self.spawned = undefined;
	self thread [[ level.gtd_call ]]( "gt_spawnPlayer" );

	return;
}

//
///////////////////////////////////////////////////////////////////////////////
startGame( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	level endon( "end_map" );

	level.starttime = getTime();

	[[ level.gtd_call ]]( "delayMapStart" );

  	[[ level.gtd_call ]]( "mapClock" );

	thread [[ level.gtd_call ]]( "gt_endMap" );
	thread [[ level.gtd_call ]]( "gt_checkUpdate", "timelimit" );
	thread [[ level.gtd_call ]]( "gt_checkUpdate", "scorelimit" );
	thread [[ level.gtd_call ]]( "gt_autoBalance" );

	level notify( "start_map" );

	for(;;)
	{
		[[ level.gtd_call ]]( "checkTimeLimit", "gt_timeLimitReached" );
		wait( 1 );
	}
}

//
///////////////////////////////////////////////////////////////////////////////
autoBalance( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	level endon( "end_map" );

	for(;;)
	{
		wait( 10 );

		if ( level.teambalance > 0 )
			thread codam\commander::procCmds( "eventeams" );
	}

	return;
}

//
///////////////////////////////////////////////////////////////////////////////
checkUpdate( var, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	level endon( "end_map" );

	for(;;)
	{
		level waittill( "update_" + var );

		switch ( var )
		{
		  case "timelimit":
			level.starttime = getTime();
		  	[[ level.gtd_call ]]( "mapClock" );	// Adjust timer
		  	[[ level.gtd_call ]]( "checkTimeLimit",
		  				"gt_timeLimitReached" );
		  	break;
		  case "scorelimit":
		  	[[ level.gtd_call ]]( "checkScoreLimit",
		  				"gt_scoreLimitReached" );
		  	break;
		}
	}
}

//
///////////////////////////////////////////////////////////////////////////////
timeLimitReached( limit, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	timepassed = ( getTime() - level.starttime ) / 60000.0;

	if ( timepassed < limit )
		return ( false );

	return ( true );
}

//
scoreLimitReached( limit, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	switch ( level.ham_g_gametype )
	{
	  case "dm":
	  case "bel":
		players = getentarray( "player", "classname" );
		for( i = 0; i < players.size; i++)
			if ( players[ i ].score >= limit )
				return ( true );

		return ( false );
	}

	// TDM
	if ( ( [[ level.gtd_call ]]( "getTeamScore", "allies" ) >= limit ) ||
	     ( [[ level.gtd_call ]]( "getTeamScore", "axis" ) >= limit ) )
		return ( true );

	return ( false );
}

//
playerScoreLimit( limit, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	if ( isPlayer( self ) &&
	     ( self.score >= limit ) )
		return ( true );

	return ( false );
}

//
///////////////////////////////////////////////////////////////////////////////
endRound( announce, roundwinner, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{

	codam\utils::debug( 0, "endRound:: |", announce, "|",
							roundwinner, "|" );

	level thread [[ level.gtd_call ]]( "hud_announce", announce );

	wait( 2 );	// Allow time to view "start" message

	[[ level.gtd_call ]]( "resetScores" );
	[[ level.gtd_call ]]( "saveAllPlayers" );
	[[ level.gtd_call ]]( "map_restart", true );
	return;
}

//
///////////////////////////////////////////////////////////////////////////////
endMap( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	level waittill( "end_map" );
	level.mapended = true;

	game[ "state" ] = "intermission";
	level notify( "intermission" );

	_endMap( level.ham_g_gametype );

	wait( 10 );	// Allow time for the scoreboard to be viewed

	[[ level.gtd_call ]]( "saveAllPlayers" );
	[[ level.gtd_call ]]( "exitLevel", false );
}

//
_endMap( type )
{
	switch ( type )
	{
	  case "dm":
	  case "bel":
		highscore = 0;
		tied = true;
		players = getentarray( "player", "classname" );
		for( i = 0; i < players.size; i++)
		{
			player = players[ i ];
			if ( player.score > highscore )
			{
				winner = player;
				tied = false;
				highscore = player.score;
				name = player.name;
			}
			else if ( player.score == highscore )
				tied = true;
		}

		for( i = 0; i < players.size; i++)
		{
			player = players[ i ];
			player CloseMenu();
			player SetClientCvar( "g_scriptMainMenu", "main" );
			if ( tied )
				player SetClientCvar( "cg_objectiveText",
						&"MPSCRIPT_THE_GAME_IS_A_TIE" );
			else if ( IsDefined( name ) )
				player SetClientCvar( "cg_objectiveText",
							&"MPSCRIPT_WINS", name );
			player [[ level.gtd_call ]]( "gt_spawnIntermission" );
		}

		if ( !tied )
		{
			winners = [];
			winners[ 0 ] = winner;
			[[ level.gtd_call ]]( "logPrint", "winner", "", winners );
		}
		break;
	  case "hq":
	  case "tdm":
		alliedscore = [[ level.gtd_call ]]( "getTeamScore", "allies" );
		axisscore = [[ level.gtd_call ]]( "getTeamScore", "axis" );

		if ( alliedscore == axisscore )
		{
			text = &"MPSCRIPT_THE_GAME_IS_A_TIE";
			winningteam = undefined;
		}
		else if ( alliedscore > axisscore )
		{
			text = &"MPSCRIPT_ALLIES_WIN";
			winningteam = "allies";
			losingteam = "axis";
		}
		else
		{
			text = &"MPSCRIPT_AXIS_WIN";
			winningteam = "axis";
			losingteam = "allies";
		}

		winners = [];
		losers = [];

		players = getentarray( "player", "classname" );
		for( i = 0; i < players.size; i++)
		{
			player = players[ i ];

			if ( IsDefined( winningteam ) )
			{
				_team = player.pers[ "team" ];
				if ( IsDefined( _team ) )
				{
					if ( _team == winningteam )
						winners[ winners.size ] = player;
					else if ( _team == losingteam )
						losers[ losers.size ] = player;
				}
			}

			player CloseMenu();
			player SetClientCvar( "g_scriptMainMenu", "main" );
			player SetClientCvar( "cg_objectiveText", text );
			player [[ level.gtd_call ]]( "gt_spawnIntermission" );
		}

		if ( IsDefined( winningteam ) )
		{
			[[ level.gtd_call ]]( "logPrint", "winner",
							winningteam, winners );
			[[ level.gtd_call ]]( "logPrint", "loser",
							losingteam, losers );
		}
		break;
	}

	return;
}

//
///////////////////////////////////////////////////////////////////////////////
