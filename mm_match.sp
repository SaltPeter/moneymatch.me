#define MAXPLAYERS 2
// The preprocessor directive below requires the user to add semicolons to the end of each statement.
#pragma semicolon 1
#include <clientprefs>
#include <cstrike>
#include <sdktools>
#include <sourcemod>

#include "mm_pause.sp"
#include "mm_sql.sp"

public Plugin:myinfo = {
	name = "DraftProMM",
	author = "xrlk",
	description = "A 1v1 money match plugin.",
	version = "0.1",
	url = "https://csgodraftpro.com"
}

// The game is played to win 8 rounds. There is a 5 second countdown before the beginning of each round.
enum PlayerInfo {
	// Fetch player's preferred items and steamids using MySql database.
	bool:isReady = false,
	bool:cantimeOut = true,
	String:steamid, // Find out when the earliest possible time is for you to set the steamid through the client's executable
	int:playerScore = 0
};

// They can be multidimensional if you need several "objects" per player or similar.
new playerArray[MAXPLAYERS + 1][PlayerInfo];
new bool:theBoolean = playerArray[isReady];
// Come up with an iterative solution to update the playerArrays to adjust to the constant change of players in the server.

public OnPluginStart() {
	if(!connectMysqlDatabase()) {
        LogError("Unable to connect to mysql database.");
		PrintToServer("unsuccessful connection error");
	}
    else {
		LogError("Successfully connected to database.");
		PrintToServer("successful connection");
	}
	
	// Server commands
	// ServerCommand("mp_warmuptime 600");
	// Server commands don't work for setting the warmup time.
	// THe only way to set the warmup time might be to change the warmup time in clients.inc
	// Find a way to change the warmup time from within the moneymatch scripts.
	
	// Event hooks
	HookEvent("player_spawn", OnPlayerSpawn);

	// Set !pause command.
    RegConsoleCmd("sm_pause", Command_Pause, "Requests a pause");
	// Set !unpause command.
    RegConsoleCmd("sm_unpause", Command_Unpause, "Requests an unpause");
	// Set !ready command.
	RegConsoleCmd("sm_ready", Command_Ready, "Readies the player");
	// Set !unready command.
	RegConsoleCmd("sm_unready", Command_Unready, "Unreadies the player");
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs) {
	// Pauses the game
	if(strcmp(sArgs[0], ".pause", false) == 0 || strcmp(sArgs[0], "!pause", false) == 0) {
		Command_Pause;
 		return Plugin_Handled;//Block the client's messsage from broadcasting
	}
	// Unpauses the game
	if(strcmp(sArgs[0], ".unpause", false) == 0 || strcmp(sArgs[0], "!unpause", false) == 0) {
		Command_Unpause;
 		return Plugin_Handled;//Block the client's messsage from broadcasting
	}
	// Ready up the player's instance
	if(strcmp(sArgs[0], ".ready", false) == 0 || strcmp(sArgs[0], "!ready", false) == 0) {
		Command_Ready;
 		return Plugin_Handled;//Block the client's messsage from broadcasting
	}
	// Unready the player's instance
	if(strcmp(sArgs[0], ".unready", false) == 0 || strcmp(sArgs[0], "!unready", false) == 0) {
		Command_Unready;
 		return Plugin_Handled;//Block the client's messsage from broadcasting
	}

	return Plugin_Continue;//Let say continue normally
}

/*
* Player spawn event - gives the appropriate weapons to a player for his arena.
* Warning: do NOT assume this is called before or after the round start event!
*/
public Action OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));
	SpawnHandler(client);
}

/*
* https://sm.alliedmods.net/api/index.php?fastload=show&id=35&
* https://sm.alliedmods.net/api/index.php?fastload=show&id=37&
* 
* Shutdown server script (5 minute timeout)
* https://forums.alliedmods.net/showthread.php?p=1542241
* 
* https://forums.alliedmods.net/showthread.php?t=135228
* Once the player picks a team and spawns, they're given the "!guns" notification.
* aka after the player has been set up
* if(GetClientTeam(client) == CS_TEAM_CT){}

- Disable team selection, the users are already given pre-selected teams before they join the server, disable teamswap.
If both players leave and return, make sure the server doesn't place them on the wrong team if they return.

The server should pull the player's steamid and assign its value to their respective team, and then when the player connects
they should check their steamid against the assigned steamid for the team, if they don't match then don't allow that player to join the team.
If the player doesnt match any steamids then kick them and ban them from the server instance (assuming the ban would be removed once the server de-instances).
*/
public Action SpawnHandler(int client) {
	PrintToChat(client, "Type !pause when the match is live, to pause the match if necessary. You will only get one pause per game.");
	PrintToChat(client, "Type !ready when you are ready to play. All players must ready up within 5 minutes or else the match is cancelled.");
	
	new weaponIdx;
	
	for(new i = 0; i <= 3; i++) {
		if((weaponIdx = GetPlayerWeaponSlot(client, i)) != -1) {  
			RemovePlayerItem(client, weaponIdx);
			RemoveEdict(weaponIdx);
		}
	}

	GivePlayerItem(client, "weapon_knife");
	GivePlayerItem(client, "weapon_ak47");
	GivePlayerItem(client, "weapon_usp_silencer");
	/* Store player's gun preferences as a cookie in the server.
	* Add the player's gun preferences to the their user table in the database (MySql).	*/
}
