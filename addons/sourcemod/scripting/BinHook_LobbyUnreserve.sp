/*注:.其他任何插件或者cfg设置都不允许有sv_allow_lobby_connect_only相关设置，一旦出现玩家进不去服务器弹出
像\“该会话已不可用\“等提示概不负责！
**/

#include <sourcemod>
#include <sdktools>
#include <binhooks/binhooks_Other>

#pragma semicolon 1
#pragma newdecls required
#define UNRESERVE_VERSION "1.0.0"

public Plugin myinfo = 
{
	name = "L4D2 Remove Lobby Reservation",
	author = "Mr Cheng",
	description = "破除匹配机制以让服务器进更多玩家",
	version = UNRESERVE_VERSION,
	url = "qq群64854516"
}

public void OnPluginStart()
{
	SetConVarInt(FindConVar("sv_allow_lobby_connect_only"),1); //服务器自动开启匹配
	RegAdminCmd("sm_unserver", Command_Unreserve, ADMFLAG_BAN, "主动移除匹配");
	CreateConVar("l4d2_unreserve_version", UNRESERVE_VERSION, "Version of the Lobby Unreserve plugin.",FCVAR_SPONLY|FCVAR_NOTIFY);
	HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);
}

public void Event_PlayerDisconnect( Event hEvent, const char[] sName, bool bDontBroadcast )
{
	int client = GetClientOfUserId(hEvent.GetInt( "userid" ));
	if(!client || (IsClientConnected(client) && !IsClientInGame(client))) return; 
	if(client && !IsFakeClient(client) && !OtherRealPlayerConnecting(client))
	{
		auto_restart_server(); //重启服务器为了重开匹配
	}
}

public void OnClientPutInServer(int client)
{
	RequestFrame(ClientPutInServer, GetClientUserId(client));
}

public void ClientPutInServer(any client) 
{
	client = GetClientOfUserId(client);
	if (IsValidClient(client) && !IsFakeClient(client))
	{
		int connectnum = GetAllRealPlayerCount();
		if(connectnum == 4)   //服务器为多少人时移除匹配
		{
			PrintToChatAll("服务器取消大厅匹配设置.");
			BinHook_LobbyUnreserve();
		}
	}
}

public Action Command_Unreserve(int client, int args)
{
	BinHook_LobbyUnreserve();
	PrintToChatAll("管理员手动移除了大厅匹配.");
	return Plugin_Handled;
}

int GetAllRealPlayerCount()
{
	int count = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && !IsFakeClient(i))
		{
			count++;
		}
	}
	return count;
}

stock bool OtherRealPlayerConnecting(int client)
{
	for (int i = 1; i < MaxClients+1; i++)
		if(IsClientConnected(i) && !IsFakeClient(i) && i!=client)
			return true;
	return false;
}

stock bool IsValidClient(int client)
{
	return (client > 0 && client <= MaxClients && IsClientInGame(client));
}

void auto_restart_server()
{
	SetCommandFlags("crash", GetCommandFlags("crash") &~ FCVAR_CHEAT);
	ServerCommand("crash");
	SetCommandFlags("sv_crash", GetCommandFlags("sv_crash") &~ FCVAR_CHEAT);
	ServerCommand("sv_crash");
}