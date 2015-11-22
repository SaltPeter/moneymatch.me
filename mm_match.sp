// The preprocessor directive below requires the user to add semicolons to the end of each statement.
#pragma semicolon 1
#include <clientprefs>
#include <cstrike>
#include <sdktools>
#include <sourcemod>

#include "mm_guns.sp"
#include "mm_pause.sp"

public Plugin:myinfo = {
	name = "DraftProMM",
	author = "xrlk",
	description = "A 1v1 money match plugin.",
	version = "0.1",
	url = "https://csgodraftpro.com"
}

// The game is played to win 8 rounds.
// There is a 5 second countdown before the beginning of each round.
enum PlayerInfo {
	// Fetch player's preferred items and steamids using MySql database.
	bool:isReady = false,
	bool:cantimeOut = true,
	String:steamid, // Find out when the earliest possible time is for you to set the steamid through the client's executable
	String:preferredRifle,
	String:preferredPistol,
	int:playerScore = 0
};

// They can be multidimensional if you need several "objects" per player or similar.
new playerArray[MAXPLAYERS + 1][PlayerInfo];
new bool:theBoolean = playerArray[isReady];
// Come up with an iterative solution to update the playerArrays to adjust to the constant change of players in the server.

public OnPluginStart() {
	// Event hooks
	HookEvent("player_spawn", OnPlayerSpawn);
	
	// Set !guns command.
	RegConsoleCmd("sm_guns", Panel_Gun, "Displays gun selection menu.");
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
    char gunsChatCommands[][] = { "guns", ".gun", ".guns", "!gun", "!guns", "gnus" };

	// Pauses the game
	if (strcmp(sArgs[0], ".pause", false) == 0 || strcmp(sArgs[0], "!pause", false) == 0) {
		
 		return Plugin_Handled;// Block the client's messsage from broadcasting
	}
	// Ready up the player's instance
	if (strcmp(sArgs[0], ".ready", false) == 0 || strcmp(sArgs[0], "!ready", false) == 0) {

 		return Plugin_Handled;// Block the client's messsage from broadcasting
	}
	// Unready the player's instance
	if (strcmp(sArgs[0], ".unready", false) == 0 || strcmp(sArgs[0], "!unready", false) == 0) {

 		return Plugin_Handled;// Block the client's messsage from broadcasting
	}
	// Open the gun panel
    for (int i = 0; i < sizeof(gunsChatCommands); i++) {
        if (strcmp(sArgs[0], gunsChatCommands[i], false) == 0) {
        	Panel_Gun;
			return Plugin_Handled;// Block the client's messsage from broadcasting
        }
    }
	
	return Plugin_Continue;// Let say continue normally
}

/*
* Player spawn event - gives the appropriate weapons to a player for his arena.
* Warning: do NOT assume this is called before or after the round start event!
*/
public Action OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));
	// ONCE THE PLAYER SPAWNS, PREVENT A TEAM CHANGE?
	// MAYBE HAVE THE PRE-MATCH WEBSITE-SIDE STUFF DECIDE WHETHER THE PLAYER GETS T-SIDE OR CT-SIDE??
	GunHandler(client);
}