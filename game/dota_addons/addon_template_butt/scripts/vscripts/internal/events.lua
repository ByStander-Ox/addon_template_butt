BUTTINGS = BUTTINGS or {MAX_LEVEL = MAX_LEVEL}

require("internal/utils/butt_api")

ListenToGameEvent("game_rules_state_change", function()
	if (GameRules:State_Get()==DOTA_GAMERULES_STATE_HERO_SELECTION) then
		
		GameRules:SetSameHeroSelectionEnabled( 1 == BUTTINGS.ALLOW_SAME_HERO_SELECTION )
		GameRules:SetUseUniversalShopMode( 1 == BUTTINGS.UNIVERSAL_SHOP_MODE )
		GameRules:SetGoldTickTime( 60/BUTTINGS.GOLD_PER_MINUTE )

		
		GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel( BUTTINGS.ALTERNATIVE_XP_TABLE() )
		GameRules:GetGameModeEntity():SetUseCustomHeroLevels(true)
		GameRules:SetUseCustomHeroXPValues(true)
		GameRules:GetGameModeEntity():SetCustomHeroMaxLevel(BUTTINGS.MAX_LEVEL)

		if ("AR"==BUTTINGS.GAME_MODE) then
			local time = ( 1 == BUTTINGS.HERO_BANNING ) and 16 or 0
			GameRules:GetGameModeEntity():SetThink( function()
				for p,player in pairs(PlayerList:GetValidTeamPlayers()) do
					player:MakeRandomHeroSelection()
				end
			end, time)
		end
		
		if ( 0 == BUTTINGS.HERO_BANNING ) then
			GameRules:GetGameModeEntity():SetDraftingBanningTimeOverride( 0 )
		else
			GameRules:GetGameModeEntity():SetDraftingBanningTimeOverride( 16 )
		end

		if ( 1 == BUTTINGS.SIDE_SHOP ) then
			for _,pos in pairs(Butt:OldSideshopLocations()) do
				Butt:CreateSideShop(pos)
			end
		end
		if ( 1 == BUTTINGS.OUTPOST_SHOP ) then
			for o,outpost in pairs(Butt:AllOutposts()) do
				Butt:CreateSideShop(outpost:GetAbsOrigin())
			end
		end

	-- elseif (GameRules:State_Get()>=DOTA_GAMERULES_STATE_PRE_GAME) then
		-- GameRules:GetGameModeEntity():SetThink( function(asd)
		-- 	if (1==BUTTINGS.FREE_COURIER) then TeamList:GetFreeCouriers() end
		-- end, 5 )
	end
end, nil)

-- local l1 = ListenToGameEvent("npc_spawned", function(keys)
-- 	if (1==BUTTINGS.FREE_COURIER) then
-- 		local unit = EntIndexToHScript(keys.entindex)
-- 		local alreadyHasCourier = PlayerResource:GetNthCourierForTeam(0, unit:GetTeam())
-- 		if (unit:GetName()=="npc_dota_courier") and (alreadyHasCourier) and (unit~=alreadyHasCourier) then
-- 			unit:Destroy()
-- 		end
-- 	elseif (GameRules:State_Get()>=DOTA_GAMERULES_STATE_PRE_GAME) then
-- 		StopListeningToGameEvent(l1)
-- 	end
-- end, nil)


ListenToGameEvent("dota_player_pick_hero", function(keys)
end, self)

ListenToGameEvent("dota_player_killed",function(kv)
	if (1==BUTTINGS.ALT_WINNING) then
		-- local unit = PlayerResource:GetSelectedHeroEntity(kv.PlayerID)
		for _,t in ipairs(TeamList:GetPlayableTeams()) do
			if (PlayerResource:GetTeamKills(t)>=BUTTINGS.ALT_KILL_LIMIT) then
				GameRules:SetGameWinner(t)
			end
		end
end
end, nil)

ListenToGameEvent("entity_killed", function(keys)
	local killedUnit = EntIndexToHScript(keys.entindex_killed)
	if killedUnit:IsRealHero() and not killedUnit:IsTempestDouble() and not killedUnit:IsReincarnating() then

		-- fix respawn lvl>25
		if (killedUnit:GetLevel()>1) then
			print(killedUnit,killedUnit:GetName(),4*killedUnit:GetLevel() * BUTTINGS.RESPAWN_TIME_PERCENTAGE * 0.01)
			killedUnit:SetTimeUntilRespawn(4 * killedUnit:GetLevel() * BUTTINGS.RESPAWN_TIME_PERCENTAGE * 0.01)
		end

		-- tombstone
		if (1==BUTTINGS.TOMBSTONE) then
			local tombstoneItem = CreateItem("item_tombstone", killedUnit, killedUnit)
			if (tombstoneItem) then
				local tombstone = SpawnEntityFromTableSynchronous("dota_item_tombstone_drop", {})
				tombstone:SetContainedItem(tombstoneItem)
				tombstone:SetAngles(0, RandomFloat(0, 360), 0)
				FindClearSpaceForUnit(tombstone, killedUnit:GetAbsOrigin(), true)
			end
		end

	end
end, nil)
