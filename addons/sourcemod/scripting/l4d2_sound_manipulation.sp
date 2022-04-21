#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>

ConVar hMaxReviveCount, cvarSoundFlags;
int iMaxRevive, iSoundFlags;

public Plugin myinfo = 
{
	name = "Sound Manipulation: REWORK",
	author = "Sir",
	description = "Allows control over certain sounds",
	version = "1.0",
	url = "The webternet."
}

public void OnPluginStart()
{
	hMaxReviveCount	= FindConVar("survivor_max_incapacitated_count");
	cvarSoundFlags	= CreateConVar("l4d2_sound_manipulation_flags", "1", "参数(survivor_max_incapacitated_count=0)时阻止不正常的心跳声音(倒地即死). 0=禁用, 1=启用.");

	hMaxReviveCount.AddChangeHook(FlagsChanged);
	cvarSoundFlags.AddChangeHook(FlagsChanged);

	AutoExecConfig(true, "l4d2_sound_manipulation");
	
	AddNormalSoundHook(SoundHook);
}

public void OnConfigsExecuted()
{
	cvarSoundFlagsConfigs();
}

public void FlagsChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    cvarSoundFlagsConfigs();
}

void cvarSoundFlagsConfigs()
{
	iMaxRevive = hMaxReviveCount.IntValue;
	iSoundFlags = cvarSoundFlags.IntValue;
}

public Action SoundHook(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH],int &entity, int &channel, float &volume, int &level, int &pitch, int &flags,char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (iSoundFlags <= 0)
		return Plugin_Continue;

	if (iMaxRevive <= 0 && StrEqual(sample, "player/heartbeatloop.wav", false))
		return Plugin_Stop;

	return Plugin_Continue;
}

