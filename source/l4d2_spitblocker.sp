#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

new Float:block_square[2][3];
new bool:lateLoad;

public Plugin:myinfo =
{
	name = "L4D2 Spit Blocker",
	author = "ProdigySim + Estoopi + Jacob",
	description = "Blocks spit damage on c4m2/c4m3 elevators",
	version = "1.1",
	url = "http://bitbucket.org/ProdigySim/misc-sourcemod-plugins/"
};

public OnPluginStart()
{
	if(lateLoad)
	{
		SetupBlocks();
		for(new cl=1; cl <= MaxClients; cl++)
		{
			if(IsClientInGame(cl))
			{
				SDKHook(cl, SDKHook_OnTakeDamage, stop_spit_dmg);
			}
		}
	}
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	lateLoad=late;
	return APLRes_Success;
}

public OnMapStart()
{
	SetupBlocks();
}

SetupBlocks()
{
	decl String:mapname[64];
	GetCurrentMap(mapname, sizeof(mapname));
	// todo trie
	// todo not copy vectors
	// todo finish up todos
	// todo psychonc
	if(StrEqual(mapname, "c4m2_sugarmill_a"))
	{
		block_square[0][0] = -1411.940430;
		block_square[0][1] = -9491.997070;
		block_square[1][0] = -1545.875244;
		block_square[1][1] = -9602.097656;
	}
	else if(StrEqual(mapname, "c4m3_sugarmill_b"))
	{
		block_square[0][0] = -1411.940430;
		block_square[0][1] = -9491.997070;
		block_square[1][0] = -1545.875244;
		block_square[1][1] = -9602.097656;
	}
//	else if(StrEqual(mapname, "c2m2_fairgrounds"))
//	{
//		block_square[0][0] = -3666.130371;
//		block_square[0][1] = -654.031250;
//		block_square[1][0] = -3807.987793;
//		block_square[1][1] = -742.550232;
//	}
	else if(StrEqual(mapname, "c5m3_cemetery"))
	{
		block_square[0][0] = 5984.291992;
		block_square[0][1] = 416.196289;
		block_square[1][0] = 5904.873047;
		block_square[1][1] = 336.839905;
	}
	else if(StrEqual(mapname, "c8m3_sewers"))
	{
		block_square[0][0] = 14311.838867;
		block_square[0][1] = 11665.000977;
		block_square[1][0] = 14232.557617;
		block_square[1][1] = 11585.582031;
	}
	else if(StrEqual(mapname, "l4d_dbd2dc_clean_up"))
	{
		block_square[0][0] = -4194.448242;
		block_square[0][1] = 3614.163818;
		block_square[1][0] = -4625.936523;
		block_square[1][1] = 3539.908936;
	}
	else if(StrEqual(mapname, "l4d_dbd2dc_undead_center"))
	{
		block_square[0][0] = -6902.102539;
		block_square[0][1] = 8809.659180;
		block_square[1][0] = -7872.751953;
		block_square[1][1] = 8522.269531;
	}
	else if(StrEqual(mapname, "cdta_03warehouse"))
	{
		block_square[0][0] = 6311.086;
		block_square[0][1] = -13217.889;
		block_square[1][0] = 6192.448;
		block_square[1][1] = -13347.204;
	}

	else
	{
		block_square[0] = NULL_VECTOR;
		block_square[1] = NULL_VECTOR;
	}
}

public OnClientPostAdminCheck(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, stop_spit_dmg);
}

public Action:stop_spit_dmg(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(victim <= 0 || victim > MaxClients) return Plugin_Continue;
	if(!IsValidEdict(inflictor)) return Plugin_Continue;
	decl String:sInflictor[64];
	GetEdictClassname(inflictor, sInflictor, sizeof(sInflictor));
	//PrintToChatAll("OnTakeDamage: victim %i attacker %i inflictor %s damage %i type %i", victim, attacker, sInflictor, RoundToNearest(damage), damagetype);
	if(StrEqual(sInflictor, "insect_swarm"))
	{
		decl Float:origin[3];
		GetClientAbsOrigin(victim, origin);
		//PrintToChatAll("%.02f, %.02f  in %.02f, %.02f ; %.02f, %.02f", origin[0], origin[1], block_square[0][0], block_square[0][1], block_square[1][0], block_square[1][1]);
		if(isPointIn2DBox(origin[0], origin[1], block_square[0][0], block_square[0][1], block_square[1][0], block_square[1][1]))
		{
			//PrintToChatAll("BLOCKED");
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;	
}

// Is x0,y0 in the box defined by x1,y1 and x2,y2
stock bool:isPointIn2DBox(Float:x0, Float:y0, Float:x1, Float:y1, Float:x2, Float:y2)
{
	if(x1 > x2)
	{
		if(y1 > y2)
		{
			return x0 <= x1 && x0 >= x2 && y0 <= y1 && y0 >= y2;
		}
		else
		{
			return x0 <= x1 && x0 >= x2 && y0 >= y1 && y0 <= y2;
		}
	}
	else
	{
		if(y1 > y2)
		{
			return x0 >= x1 && x0 <= x2 && y0 <= y1 && y0 >= y2;
		}
		else
		{
			return x0 >= x1 && x0 <= x2 && y0 >= y1 && y0 <= y2;
		}
	}
}