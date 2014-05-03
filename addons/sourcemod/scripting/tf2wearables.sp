/**
 * vim: set ts=4 :
 * =============================================================================
 * TF2 Wearables
 * API for dealing with TF2 Wearables.  May be submitted for inclusion with
 * the TF2 extension
 *
 * TF2 Wearable Tools (C)2013-2014 Powerlord (Ross Bemrose).
 * All rights reserved.
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 *
 * Version: $Id$
 */

#include <sourcemod>
#include <sdktools>

#define VERSION "1.1.0"

public Plugin:myinfo = 
{
	name = "[TF2] Wearable Item Tools",
	author = "Powerlord",
	description = "Quick API for dealing with wearable items",
	version = VERSION,
	url = "<- URL ->"
}

new Handle:hGameConf;
new Handle:hEquipWearable;
new Handle:hRemoveWearable;
new Handle:hIsWearable;
new Handle:hGetEntFromSlot;

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	new EngineVersion:version = GetEngineVersion();
	
	if (version != Engine_TF2)
	{
		strcopy(error, err_max, "Only supported on TF2");
		return APLRes_Failure;
	}
	
	RegPluginLibrary("tf2wearables");
	
	CreateNative("TF2_EquipPlayerWearable", Native_EquipWearable);
	CreateNative("TF2_RemovePlayerWearable", Native_RemoveWearable);
	CreateNative("TF2_IsWearable", Native_IsWearable);
	CreateNative("TF2_GetPlayerLoadoutSlot", Native_GetLoadoutSlot);
	
	return APLRes_Success;
}

public OnPluginStart()
{
	CreateConVar("tf2wearables_version", VERSION, "Version of TF2 Wearables API", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);
	
	hGameConf = LoadGameConfigFile("tf2.wearables");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "CTFPlayer::EquipWearable");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	hEquipWearable = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "CTFPlayer::RemoveWearable");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	hRemoveWearable = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "CBaseEntity::IsWearable");
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	hIsWearable = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "CTFPlayer::GetEntityForLoadoutSlot");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
	hGetEntFromSlot = EndPrepSDKCall();
}

public Native_EquipWearable(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if (client < 1 || client > MaxClients || !IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Client %d is invalid", client);
		return;
	}
	
	new wearable = GetNativeCell(2);
	
	if (!Internal_IsWearable(wearable))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%d is not a wearable", wearable);
	}
	
	SDKCall(hEquipWearable, client, wearable);
}

public Native_RemoveWearable(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if (client < 1 || client > MaxClients || !IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Client %d is invalid", client);
		return;
	}
	
	new wearable = GetNativeCell(2);

	if (!Internal_IsWearable(wearable))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%d is not a wearable", wearable);
	}
	
	SDKCall(hRemoveWearable, client, wearable);
}

public Native_IsWearable(Handle:plugin, numParams)
{
	new entity = GetNativeCell(1);
	
	return Internal_IsWearable(entity);
}

bool:Internal_IsWearable(entity)
{
	if (entity <= MaxClients || !IsValidEntity(entity))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%d is an invalid entity", entity);
		return false;
	}
	
	return SDKCall(hIsWearable, entity);
}

public Native_GetLoadoutSlot(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if (client < 1 || client > MaxClients || !IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Client %d is invalid", client);
		return -1;
	}
	
	new TF2LoadoutSlot:slot = GetNativeCell(2);
	
	return SDKCall(hGetEntFromSlot, client, slot);
}
