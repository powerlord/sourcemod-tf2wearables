/**
 * vim: set ts=4 :
 * =============================================================================
 * TF2 Wearables Test
 * Test to get item information from loadout slots
 *
 * TF2 Wearables Test (C)2014 Powerlord (Ross Bemrose).  All rights reserved.
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
#include <tf2wearables>
#pragma semicolon 1

#define VERSION "1.0.1"

public Plugin:myinfo = {
	name			= "TF2 Wearables Test",
	author			= "Powerlord",
	description		= "Test to get item information from loadout slots",
	version			= VERSION,
	url				= ""
};

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	if (GetEngineVersion() != Engine_TF2)
	{
		strcopy(error, err_max, "Plugin is for TF2 only.");
		return APLRes_Failure;
	}
	
	return APLRes_Success;
}
  
public OnPluginStart()
{
	LoadTranslations("common.phrases");
	CreateConVar("tf2wearablestest_version", VERSION, "TF2 Wearables Test version", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);
	
	RegAdminCmd("checkmyitems", Cmd_CheckMyItems, ADMFLAG_GENERIC, "Check my item indexes and classes");
	RegAdminCmd("checkitems", Cmd_CheckItems, ADMFLAG_GENERIC, "Check a specific target's item indexes and classes");
}

public Action:Cmd_CheckMyItems(client, args)
{
	if (client == 0)
	{
		ReplyToCommand(client, "%t", "Command is in-game only");
		return Plugin_Handled;
	}
	
	ReplyToCommand(client, "Processed items for %N", client);
	ProcessItems(client, client);
	
	return Plugin_Handled;
}

public Action:Cmd_CheckItems(client, args)
{
	if (args == 0)
	{
		ReplyToCommand(client, "Syntax: checkitems target");
		return Plugin_Handled;
	}
	
	decl String:pattern[64];
	
	GetCmdArg(1, pattern, sizeof(pattern));
	
	decl String:targetName[64];
	new targets[MaxClients];
	new bool:isMl;
	
	new count = ProcessTargetString(pattern, client, targets, MaxClients, COMMAND_FILTER_NO_IMMUNITY, targetName, sizeof(targetName), isMl);
	
	if (isMl)
	{
		Format(targetName, sizeof(targetName), "%T", targetName, client);
	}
	
	if (count <= 0)
	{
		ReplyToTargetError(client, count);
		return Plugin_Handled;
	}
	
	ReplyToCommand(client, "Processed items for %s", targetName);
	
	for (new i = 0; i < count; i++)
	{
		ProcessItems(client, targets[i]);
	}
	
	return Plugin_Handled;
}

ProcessItems(client, target)
{
	for (new i = 0; i < TF2_LOADOUT_SLOT_COUNT; i++)
	{
		new item = TF2_GetPlayerLoadoutSlot(target, TF2LoadoutSlot:i);
		
		if (item > -1)
		{
			decl String:classname[64];
			GetEntityClassname(item, classname, sizeof(classname));
			new itemDefinitionIndex = GetEntProp(item, Prop_Send, "m_iItemDefinitionIndex");
			
			ReplyToCommand(client, "%N Item Slot %d: ent %d, class \"%s\", index %d", target, i, item, classname, itemDefinitionIndex);
		}
	}
}
