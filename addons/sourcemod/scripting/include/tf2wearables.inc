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
#if defined _tf2wearables_included_
  #endinput
#endif
#define _tf2wearables_included_

#include <sourcemod>

// This order is taken from g_szLoadoutStringsForDisplay in server_srv.so
// Frankly, it makes a lot more sense than the version that contains aGrenade
// since grenades have never existed in TF2
enum TF2LoadoutSlot
{
	TF2LoadoutSlot_Primary,
	TF2LoadoutSlot_Secondary,
	TF2LoadoutSlot_Melee,
	TF2LoadoutSlot_Unknown1,
	TF2LoadoutSlot_Building,
	TF2LoadoutSlot_Unknown2,
	TF2LoadoutSlot_PDA2,
	TF2LoadoutSlot_Misc1,
	TF2LoadoutSlot_Misc2,
	TF2LoadoutSlot_Action,
	TF2LoadoutSlot_Misc3,
}

/**
 * Equip a wearable item on a player
 * The wearable equivalent of EquipPlayerItem.
 *
 * NOTE: Due to game restrictions, items will be invisible on non-bot players
 *
 * @param client	Client who should equip this
 * @param wearable	The entity index of the wearable
 * @return			True if it was equipped, false otherwise
 */
native TF2_EquipPlayerWearable(client, wearable);

/**
 * Remove a wearable item from a player
 * The wearable equivalent of RemovePlayerItem.
 *
 * @param client	Client who should remove this
 * @param wearable	The entity index of the wearable, use 
 * @return			True if it was equipped, false otherwise
 */
native TF2_RemovePlayerWearable(client, wearable);

/**
 * Is an entity a wearable?
 *
 * @param entity	The entity to check
 * @return			True if it is a wearable, false if not
 * @error			If the entity index is an invalid entity
 */
native bool:TF2_IsWearable(entity);

/**
 * Get the entity equipped in a loadout slot
 * 
 * @param client		Client whose item we want
 * @param slot		The slot whose item we want
 * @return entity		Entity index or -1 if no item found
 */
native TF2_GetPlayerLoadoutSlot(client, TF2LoadoutSlot:slot);

/**
 * Removes a weapon from a client's weapon slot
 *
 * @param client		Player's index.
 * @param slot			Slot index (0-5)
 * @noreturn
 * @error				Invalid client, invalid slot or lack of mod support
 */
stock TF2_RemoveWeaponSlotFix(client, slot)
{
	new weaponIndex;
	while ((weaponIndex = GetPlayerWeaponSlot(client, slot)) != -1)
	{
		new wearable = GetEntPropEnt(weaponIndex, Prop_Send, "m_hExtraWearable");
		if (wearable > MaxClients)
		{
			TF2_RemovePlayerWearable(client, wearable);
			AcceptEntityInput(wearable, "Kill");
		}
		
		RemovePlayerItem(client, weaponIndex);
		AcceptEntityInput(weaponIndex, "Kill");
	}
}

/**
 * Removes all weapons from a client
 *
 * @param client		Player's index.
 * @noreturn
 */
stock TF2_RemoveAllWeaponsFix(client)
{
	for (new i = 0; i <= 5; i++)
	{
		TF2_RemoveWeaponSlotFix(client, i);
	}
}

/**
 * Removes all non-weapon Wearables from a client
 *
 * @param client		Player's index.
 * @noreturn
 */
stock TF2_RemoveAllWearables(client)
{
	for (new i = TF2LoadoutSlot_Misc1; i <= TF2LoadoutSlot_Misc3; i++)
	{
		new wearable = TF2_GetItemForLoadoutSlot(client, i);
		if (IsValidEntity(wearable))
		{
			TF2_RemovePlayerWearable(client, wearable);
			AcceptEntityInput(wearable, "Kill");
		}
	}
}

public SharedPlugin:__pl_tf2wearables =
{
	name = "tf2wearables",
	file = "tf2wearables.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

public __pl_tf2wearables_SetNTVOptional()
{
	MarkNativeAsOptional("EquipPlayerWearable");
	MarkNativeAsOptional("RemovePlayerWearable");
	MarkNativeAsOptional("IsWearable");
	//MarkNativeAsOptional("GetPlayerWearableSlot");
}