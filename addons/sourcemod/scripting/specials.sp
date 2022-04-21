/*注:.下面有一些本人注释的改法,不会语言的人也可以修改你想要的一些功能,改完之后请重新编译插件!*/
//txt文本有说明，必看


#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <binhooks>
#define PLUGIN_VERSION "10.0.0.0' Mr Cheng"
bool g_TankEIST;
public Plugin myinfo =
{
	name = "多特",
	description = "战役中多特感,解决卡特,ems HUD显示!",
	author = "Mr Cheng",
	version = PLUGIN_VERSION,
	url = "qq群64854516"
};
/*后续还会继续更新如特感智商等等以提高难度，敬请期待....*/

public void OnPluginStart()
{
	CreateConVar("l4d2_SpecialsVersion", PLUGIN_VERSION, "One Specials Plguin.", FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_REPLICATED);
	
	//txt文本有说明，必看
	SetSpecialRunning(true);//false:不加载,true:加载     是否加载多特功能.
	
	SetSpecialSpawnMode(1);  //模式，请看txt说明
	
	SetSpecialSpawnSubMode(2); //子模式，请看txt说明
	
	SetSpecialAssault(true);    //特感刚产生是否立即会主动向幸存者发起袭击？？或许设置true后特感可能无法再蹲人，各有利弊吧.
	
	SetSpecialRespawnInterval(15);//设置特感再次产生的时间;
	SetSpecialMax(15);//设置特感产生的最大数量;
	/* enum ZombieType
	{
		SMOKER = 0,     
		BOOMER,       
		HUNTER,        
		SPITTER,     
		JOCKEY,       
		CHARGER,            
	}; */
	//ZombieType请看上面，从0到5循环，一次是从smoker到charger;
	for(int i=0;i<=5;i++)
	{
		SetSpecialSpawnLimit(view_as<ZombieType>( i ),5);//设置特感的最大数量.
		SetSpecialSpawnWeight(view_as<ZombieType>( i ),100);//设置特感的产生占比.
		SetSpecialSpawnMaxDis(view_as<ZombieType>( i ),2000);//设置特感的产生最大距离.
		SetSpecialSpawnMinDis(view_as<ZombieType>( i ),32);//设置特感的产生最小距离.
		SetSpecialSpawnDirChance(view_as<ZombieType>( i ),80);//设置特感的产生在前方的概率.
		SetSpecialSpawnArea(view_as<ZombieType>( i ),0);//设置特感的产生区域.
	}

	g_TankEIST = true;//坦克存在游戏时是否继续刷特;true=刷特，false=不刷特
	HookEvent("round_start", OnRoundStart);
	HookEvent("tank_spawn", OnTankSpawn);
	HookEvent("tank_killed", OnTankDeath);
	HookEvent("player_death", OnPlayerDeath);
	HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);	
	HookEvent("round_end", OnRoundEnd, EventHookMode_Pre);  
}

/*下面这段代码仅供参考:
**内容是特感根据人数增加而增加
**小于四人时特感数量总是为4，大于四人时每增加一个玩家增加一个特感.
**如果想改小于四人时的特感数量和每增加一个玩家增加多少特感请看下面的注释;
**/

public Action OnPlayerStuck(int client)
{
	if(IsValidClient(client) && IsPlayerAlive(client))
	{
		if(GetClientTeam(client)==3 && IsFakeClient(client) && !IsTank(client)) KickClient(client,"感染者卡住踢出");
	}
	return Plugin_Continue;
}

public Action OnRoundStart( Event hEvent, const char[] sName, bool bDontBroadcast )
{
	//开局后多少秒开始刷特,如果过了这个时间后还没有玩家离开开始区域，还是不会刷特，
	//然而如果玩家离开了安全区域，可是这个时间没过，也不会开始刷特.（默认5.0）
	CreateTimer( 5.0, Timer_DelaySpawnInfected);
	return Plugin_Continue;
}

public Action Timer_DelaySpawnInfected( Handle hTimer)
{
	SetSpecialRunning(true); 
}

public Action OnRoundEnd( Event hEvent, const char[] sName, bool bDontBroadcast )
{
	SetSpecialRunning(false); 
	return Plugin_Continue;
}

public void OnMapEnd()
{
	SetSpecialRunning(false); 
}

public Action OnTankSpawn( Event hEvent, const char[] sName, bool bDontBroadcast )
{
	int client = GetClientOfUserId(hEvent.GetInt( "userid" ));	
	if(IsValidClient(client) && GetClientTeam(client) == 3)
	{
		if(!g_TankEIST)
			SetSpecialRunning(false);  
	}
	return Plugin_Continue;
}

public Action OnTankDeath( Event hEvent, const char[] sName, bool bDontBroadcast )
{
	int client = GetClientOfUserId(hEvent.GetInt( "userid" ));
	if (IsValidClient(client) && GetClientTeam(client)==3)
	{
		if(!g_TankEIST)
			CreateTimer( 0.2, Timer_DelayDeath);
	}
	return Plugin_Continue;
}

public Action Timer_DelayDeath( Handle hTimer)
{
	SetSpecialRunning(true); 
	for (int i = 1; i <= MaxClients; i++)
		if(IsTank(i) && IsPlayerAlive(i))
	{
		SetSpecialRunning(false);
		break;
	}
}

//这个是必需的,否则数量可能并不精准，这是由于系统的限制，目前只能通过这种方法控制精准度
public Action OnPlayerDeath( Event hEvent, const char[] sName, bool bDontBroadcast )
{
	int client = GetClientOfUserId(hEvent.GetInt( "userid" ));
	if (IsValidClient(client) && IsFakeClient(client) && GetClientTeam(client)==3)
	{
		RequestFrame(Timer_KickBot, GetClientUserId(client));
	}
}

public void Timer_KickBot(any client) 
{
	client = GetClientOfUserId(client);
	if (client>0 && IsClientInGame(client)) 
	{
		if (IsFakeClient(client) && !IsClientInKickQueue(client)) KickClient(client);
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
		SteMaxSpecialsCount(true);
}


public void Event_PlayerDisconnect( Event hEvent, const char[] sName, bool bDontBroadcast )
{
	int client = GetClientOfUserId(hEvent.GetInt( "userid" ));
	if(!client || (IsClientConnected(client) && !IsClientInGame(client))) return; 
	if(!IsFakeClient(client))
	{
		CreateTimer( 0.2, Timer_DelayCheckDisconnect);
	}
	if(IsTank(client))
		SetSpecialRunning(true); 
}

public Action Timer_DelayCheckDisconnect( Handle hTimer, any UserID )
{
	SteMaxSpecialsCount(false);
}

public void SteMaxSpecialsCount(bool IsClientPutInServer)
{
	int RealPlayer_count;
	int AddSpecialFromSurvivor = 2;//此处改每增加一个玩家可增加多少个特感;
	int Specials_count = 6;//此处改的内容为游戏中玩家数量小于等于4时特感的固定数量为多少
	char line[128];
	for (int i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i) && !IsFakeClient(i))
			++RealPlayer_count;
	
	if(RealPlayer_count<=4)
		SetSpecialMax(Specials_count);
	else 
	{
		Specials_count = AddSpecialFromSurvivor * (RealPlayer_count - 4) + Specials_count;
		SetSpecialMax(Specials_count);
	}
	
	if(IsClientPutInServer)
		Format(line, sizeof(line), "幸存者增加了,特感数量为%d特", Specials_count);
	else
		Format(line, sizeof(line), "幸存者减少了,特感数量为%d特", Specials_count);
	HUDSetLayout(HUD_SCORE_4, HUD_FLAG_ALIGN_LEFT|HUD_FLAG_BLINK|HUD_FLAG_COUNTDOWN_WARN, line);
	HUDPlace(HUD_SCORE_4,0.35,0.05,1.0,0.05);
	CreateTimer(5.0, delay_timer);
}

public Action delay_timer(Handle timer)
{
	if(HUDSlotIsUsed(HUD_SCORE_4))
		RemoveHUD(HUD_SCORE_4);
}

stock bool IsValidClient(int client)
{
	return (client > 0 && client <= MaxClients && IsClientInGame(client));
}

stock bool IsTank( int client )
{
	if( IsValidClient(client) && GetClientTeam( client ) == 3 )
		if( GetEntProp( client, Prop_Send, "m_zombieClass" ) == 8 )
			return true;
	
	return false;
}