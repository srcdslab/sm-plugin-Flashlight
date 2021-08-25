#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#pragma newdecls required

Handle gH_LAW = INVALID_HANDLE;
Handle gH_Return = INVALID_HANDLE;
Handle gH_Sound = INVALID_HANDLE;
Handle gH_SoundAll = INVALID_HANDLE;

bool bLAW = true;
bool bRtn = false;
bool bSnd = false;
bool bSndAll = true;

char zsSnd[255];

public Plugin myinfo =
{
	name = "Flashlight",
	author = "Mitch, Botox, maxime1907",
	description = "Replaces +lookatweapon with a toggleable flashlight. Also adds the command: sm_flashlight",
	version = "1.4",
	url = "https://forums.alliedmods.net/showthread.php?t=227224"
};

public void OnPluginStart()
{
	gH_LAW = CreateConVar("sm_flashlight_lookatweapon", "1", 
					"0 = Doesn't use +lookatweapon; 1 = hooks +lookatweapon", 		FCVAR_NONE, true, 0.0, true, 1.0);
	gH_Return = CreateConVar("sm_flashlight_return", "0", 
					"0 = Doesn't return blocking +look at weapon; 1 = Does return", FCVAR_NONE, true, 0.0, true, 1.0);
	gH_Sound = CreateConVar("sm_flashlight_sound", "items/flashlight1.wav", 
					"Sound path to use when a player uses the flash light.", FCVAR_NONE);
	gH_SoundAll = CreateConVar("sm_flashlight_sound_all", "1", 
					"Play the sound to all players, or just to the activator?", FCVAR_NONE);

	HookConVarChange(gH_Sound, ConVarChanged);
	HookConVarChange(gH_LAW, ConVarChanged);
	HookConVarChange(gH_Return, ConVarChanged);
	HookConVarChange(gH_SoundAll, ConVarChanged);

	UpdateSound();

	AddCommandListener(Command_LAW, "+lookatweapon");	//Hooks cs:go's flashlight replacement 'look at weapon'.
	RegConsoleCmd("sm_flashlight", Command_FlashLight); 	//Bindable Flashlight command

	AutoExecConfig(true);
}

public void ConVarChanged(Handle cvar, const char[] oldVal, const char[] newVal)
{
	if(cvar == gH_LAW)
		bLAW = view_as<bool>(StringToInt(newVal));
	if(cvar == gH_Return)
		bRtn = view_as<bool>(StringToInt(newVal));
	if(cvar == gH_SoundAll)
		bSndAll = view_as<bool>(StringToInt(newVal));
	if(cvar == gH_Sound) {
		UpdateSound();
	}
}

public void UpdateSound() {
	char formatedSound[256];
	GetConVarString(gH_Sound, formatedSound, sizeof(formatedSound));
	if(StrEqual(formatedSound, "") || StrEqual(formatedSound, "0")) {
		bSnd = false;
	} else {
		strcopy(zsSnd, sizeof(zsSnd), formatedSound);
		bSnd = true;
		PrecacheSound(zsSnd);
		if(!StrEqual(formatedSound, "items/flashlight1.wav")) {
			Format(formatedSound, sizeof(formatedSound), "sound/%s", formatedSound);
			AddFileToDownloadsTable(formatedSound);
		}
	}
}

public void OnMapStart() {
	if(bSnd) {
		PrecacheSound(zsSnd, true);
	}
}

public Action Command_LAW(int client, const char[] command, int argc)
{
	if(!bLAW) //Enable this hook?
		return Plugin_Continue;

	if(!IsClientInGame(client)) //If player is not in-game then ignore!
		return Plugin_Continue;

	if(!IsPlayerAlive(client)) //If player is not alive then continue the command.
		return Plugin_Continue;	

	ToggleFlashlight(client);

	return (bRtn) ? Plugin_Continue : Plugin_Handled;
}

public Action Command_FlashLight(int client, int args)
{
	if (IsClientInGame(client) && IsPlayerAlive(client)) {
		ToggleFlashlight(client);
	}
	return Plugin_Handled;
}

stock void ToggleFlashlight(int client) {
	SetEntProp(client, Prop_Send, "m_fEffects", GetEntProp(client, Prop_Send, "m_fEffects") ^ 4);
	if(bSnd) {
		if(bSndAll) {
			EmitSoundToAll(zsSnd, client);
		} else {
			EmitSoundToClient(client, zsSnd);
		}
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	// Dead flashlight
	if (impulse == 100 && !IsPlayerAlive(client))
	{
		ToggleFlashlight(client);
	}

	return Plugin_Continue;
}
