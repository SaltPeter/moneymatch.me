#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <clientprefs>
#include <cstrike>

new Handle:hDb;

/*
* https://wiki.alliedmods.net/SQL_%28SourceMod_Scripting%29
* The database tables are: users, matches
[users]
username (varchar)
password (hashed varchar)
email (varchar)
steamid (string)
write up an API to check steamid for play time
the data returned would be in json format
If user joins the wrong match, instead of being kicked immediately
the server searches the database for any matching servers with their steamid and redirects them
*/

public bool:connectMysqlDatabase() {
    if(hDb != INVALID_HANDLE)
        return true;
    
    //declarations
    decl String:error[255];
    new Handle:kv = CreateKeyValues("MySql");
    
    KvSetString(kv, "driver", "mysql");
    KvSetString(kv, "host", "localhost");
    KvSetString(kv, "database", "csgodraft2");
    KvSetString(kv, "user", "root");
    KvSetString(kv, "pass", "");
    
    hDb = SQL_ConnectCustom(kv, error, sizeof(error), true);
    LogMessage("successful connection");
    PrintToServer("successful connection");
    return hDb != INVALID_HANDLE;
}

/* Doing mysql stuff with sourcemod is a clusterfuck, make sure to refer to the documentation for sourcemod and to refer to 
design patterns used for csgohuge for an idea of how to handle data
*/

/* add a fetchinfo command similar to the helper function used in csgohuge to streamline obtaining information
from the database */

/*
It is desirable to not have the system do any database processing while the clients are playin in a match,
this is desired in order to limit bandwidth usage and therefore reduce latency for the players.

Theoretically multiple instances would be running concurrently on a single networked computer, so issues with scalability
arise. Have these challenges in mind when making a solution.
*/

/*
Database tables
[matches]
matchid
pending
cancelled
winner
ctscore
tscore
ctsteamid
tsteamid

[users]
userid
steamid
*/
