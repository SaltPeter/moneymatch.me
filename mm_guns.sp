#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <clientprefs>
#include <cstrike>

/*
* https://sm.alliedmods.net/api/index.php?fastload=show&id=35&
* https://sm.alliedmods.net/api/index.php?fastload=show&id=37&
* https://forums.alliedmods.net/showthread.php?t=135228
* 
*/

// sm_guns command
public Action Command_Guns(int client, int args) {
	/*
	Create panel
	[Weapon preferences]
	1. [none] ak47|m4a1|m4a4
	2. [none] usp|p2k|glock|tec9|57|cz75|p250|deagle
	*/
}

/*
* Once the player picks a team and spawns, they're given the "!guns" notification.
* aka after the player has been set up
*/
public Action GunHandler(int client) {
	PrintToChat(client, "\x01\x0B\x05[MM]\x01 Type \x05!guns\x01 to select your loadout.");
	PrintHintText(client,"<span style='color:green;'>Type <b>!ready</b> to ready up for the match.</span>");  
	
	if(GetClientTeam(client) == CS_TEAM_CT){
		GivePlayerItem(client, "weapon_m4a1");
		GivePlayerItem(client, "weapon_usp_silencer");
	}
	else if(GetClientTeam(client) == CS_TEAM_T){
		GivePlayerItem(client, "weapon_ak47");	
		GivePlayerItem(client, "weapon_glock");
	}
	/*
	* Store player's gun preferences as a cookie in the server.
	* Add the player's gun preferences to the their user table in the database (MySql).
	*/
}

public int GunPanelHandler(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select)
		PrintToConsole(param1, "You selected item: %d", param2);
	else if (action == MenuAction_Cancel)
		PrintToServer("Client %d's menu was cancelled.  Reason: %d", param1, param2);
}
 
public Action Panel_Gun(int client, intargs) {
	Panel panel = new Panel();
	panel.SetTitle("Preferred Guns");
	panel.DrawItem("Primary:");
	panel.DrawItem("Secondary:");
 
	panel.Send(client, GunPanelHandler, 20);
 
	delete panel;
 
	return Plugin_Handled;
}