#define MAXPLAYERS 2
#pragma semicolon 1
#include <clientprefs>
#include <cstrike>
#include <sdktools>
#include <sourcemod>

new bool:g_ctUnpaused = false;
new bool:g_tUnpaused = false;

new string:firstPause;
new string:secondPause;

public OnMapStart() {
    g_ctUnpaused = false;
    g_tUnpaused = false;
}

public Action:Command_Pause(client, args) {
    if(IsWarmup() || IsPaused() || !IsValidClient(client))
        return Plugin_Handled;
	
	if(firstPause != client && secondPause != client){
		if(firstPause != client){
			firstPause = client;
		}
		else if(secondPause != client){
			secondPause = client;
		}
	}

    g_ctUnpaused = false;
    g_tUnpaused = false;

    ServerCommand("mp_pause_match");
    PrintToChatAll("%N has requested a pause.", client);

    return Plugin_Handled;
}

public Action:Command_Unpause(client, args) {
    if(IsWarmup() || !IsPaused() || !IsValidClient(client))
        return Plugin_Handled;

    new team = GetClientTeam(client);

    if(team == CS_TEAM_T)
        g_tUnpaused = true;
    else if (team == CS_TEAM_CT)
        g_ctUnpaused = true;

    if(g_tUnpaused && g_ctUnpaused)  {
        ServerCommand("mp_unpause_match");
    } else if (g_tUnpaused && !g_ctUnpaused) {
        PrintToChatAll("The T team wants to unpause. Waiting for the CT team to type \x05!unpause");
    } else if (!g_tUnpaused && g_ctUnpaused) {
        PrintToChatAll("The CT team wants to unpause. Waiting for the T team to type \x05!unpause");
    }

    return Plugin_Handled;
}

public Action:Command_Ready(client, args) {
    if(!IsWarmup())
    	return Plugin_Handled;
	else {
	// ready the player, but if they leave then unready them or their instance?
	// find a way to prevent the game from starting if there are only players on one team.
	example: no players on CT, all players on T are readied
	// maybe make it scaleable
	}
}

public Action:Command_Unready(client, args) {
    if(!IsWarmup())
    	return Plugin_Handled;
	else {
	
	}
}

stock bool:IsValidClient(client) {
    if(client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client))
    	return true;
    return false;
}

stock bool:IsPaused() {
    return bool:GameRules_GetProp("m_bMatchWaitingForResume");
}

stock bool:IsWarmup() {
	return bool:GameRules_GetProp("m_bWarmupPeriod");
}
