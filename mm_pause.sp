#pragma semicolon 1
#include <clientprefs>
#include <cstrike>
#include <sdktools>
#include <sourcemod>

new bool:g_ctUnpaused = false;
new bool:g_tUnpaused = false;

public OnMapStart() {
    g_ctUnpaused = false;
    g_tUnpaused = false;
}

public Action:Command_Pause(client, args) {
    if (IsPaused() || !IsValidClient(client))
        return Plugin_Handled;

    g_ctUnpaused = false;
    g_tUnpaused = false;

    ServerCommand("mp_pause_match");
    PrintToChatAll("%N has requested a pause.", client);

    return Plugin_Handled;
}

public Action:Command_Unpause(client, args) {
    if (!IsPaused() || !IsValidClient(client))
        return Plugin_Handled;

    new team = GetClientTeam(client);

    if (team == CS_TEAM_T)
        g_tUnpaused = true;
    else if (team == CS_TEAM_CT)
        g_ctUnpaused = true;

    if (g_tUnpaused && g_ctUnpaused)  {
        ServerCommand("mp_unpause_match");
    } else if (g_tUnpaused && !g_ctUnpaused) {
        PrintToChatAll("The T team wants to unpause. Waiting for the CT team to type \x05!unpause");
    } else if (!g_tUnpaused && g_ctUnpaused) {
        PrintToChatAll("The CT team wants to unpause. Waiting for the T team to type \x05!unpause");
    }

    return Plugin_Handled;
}

stock bool:IsValidClient(client) {
    if (client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client))
        return true;
    return false;
}

stock bool:IsPaused() {
    return bool:GameRules_GetProp("m_bMatchWaitingForResume");
}
