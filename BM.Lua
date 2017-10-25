


-- Globals Section
-- Modifiers Ctrl - 1, alt-2, Shift-4, no repeat - 8, Print - 16


ColourCrypter_BM_Variables =
{
	["SteadyFocusShootingOn"] = false;
	["BestialWrathCoolDownRemaining"] = 0;
	["FocusFire"] ={
		["Key"] = {
			["R"] = 1/256;
			["G"] = 0/256;
			["B"] = (4+2)/256;
		},
		["SpellName"] = "Focus Fire";
		["BestialWrathDelay"] = 6;
	},	
	["BestialWrath"] ={
		["Key"] = {
			["R"] = 2/256;
			["G"] = 0/256;
			["B"] = (4+2)/256;
		},
		["SpellName"] = "Bestial Wrath";
	},	
	["CounterShot"] ={
		["Key"] = {
			["R"] = 2/256;
			["G"] = 0/256;
			["B"] = (1+4)/256;
		},
		["SpellName"] = "Counter Shot";
	},	
	["KillCommand"] ={
		["Key"] = {
			["R"] = 3/256;
			["G"] = 0/256;
			["B"] = (4+2)/256;
		},
		["SpellName"] = "Kill Command";
		["BestialWrathDelay"] = 3;
	},	
	["KillShot"] ={
		["Key"] = {
			["R"] = 3/256;
			["G"] = 0/256;
			["B"] = (1+4)/256;
		},
		["SpellName"] = "Kill Shot";
	},
	["ArcaneShot"] ={
		["Key"] = {
			["R"] = 4/256;
			["G"] = 0/256;
			["B"] = (4+2)/256;
		},
		["SpellName"] = "Arcane Shot";
	},
	["CobraShot"] ={
		["Key"] = {
			["R"] = 4/256;
			["G"] = 0/256;
			["B"] = (1+4)/256;
		},
		["SpellName"] = "Cobra Shot";
	},
	["Barrage"] ={
		["Key"] = {
			["R"] = 5/256;
			["G"] = 0/256;
			["B"] = (4+2)/256;
		},
		["SpellName"] = "Barrage";
	},
	["MultiShot"] ={
		["Key"] = {
			["R"] = 5/256;
			["G"] = 0/256;
			["B"] = (1+4)/256;
		},
		["SpellName"] = "Multi-Shot";
	},
	["MendPet"] ={
		["Key"] = {
			["R"] = 6/256;
			["G"] = 0/256;
			["B"] = (4+2)/256;
		},
		["SpellName"] = "Mend Pet";
	},
	["AspectoftheCheetah"] ={
		["Key"] = {
			["R"] = 6/256;
			["G"] = 0/256;
			["B"] = (1+4)/256;
		},
		["SpellName"] = "Aspect of the Cheetah";
	}
};

function ColourCrypter_BM_TimedUpdate()

	
	ColourCrypter_BM_ScanBuffs();
	
	if(ColourCrypter_BM_CheckIsInActiveCombat()) then
		ColourCrypter_Variables.LootPending = true;
		ColourCrypter_BM_Attack();
	else
		ColourCrypter_BM_Variables.SteadyFocusShootingOn = false;
		if(ColourCrypter_Variables.LootPending) then
			ColourCrypter_SetAction(ColourCrypter_AnyClass_Variable.Loot);
		elseif(not ColourCrypter_Variables.BuffStatus.AspectoftheCheetah) 
			and ColourCrypter_IsSpellReady(ColourCrypter_BM_Variables.AspectoftheCheetah.SpellName) then
			ColourCrypter_SetAction(ColourCrypter_BM_Variables.AspectoftheCheetah);
		else 
			ColourCrypter_SetAction(ColourCrypter_AnyClass_Variable.DoNothing);
		end
	end
end


function ColourCrypter_BM_ScanBuffs()
	--ColourCrypter_Variables.BuffStatus
	ColourCrypter_Variables.BuffStatus.CurrentTime = GetTime()
	ColourCrypter_Variables.BuffStatus.FrenzyStack = 0;
	ColourCrypter_Variables.BuffStatus.FrenzyRemainingTime = 0;
	ColourCrypter_Variables.BuffStatus.FocusFire = false;
	ColourCrypter_Variables.BuffStatus.SteadyFocus = false;
	ColourCrypter_Variables.BuffStatus.AspectoftheCheetah = false;
	local i = 1;
	local nameExist = true;
	while nameExist do
		local name, rank, icon, count, dispelType, duration, expires =  UnitAura("player", i, "HELPFUL|PLAYER");
		if(name == "Frenzy") then
			ColourCrypter_Variables.BuffStatus.FrenzyStack = count;
			ColourCrypter_Variables.BuffStatus.FrenzyRemainingTime = expires- ColourCrypter_Variables.BuffStatus.CurrentTime;
		elseif(name == "Focus Fire") then
			ColourCrypter_Variables.BuffStatus.FocusFire = true;
		elseif(name =="Steady Focus") then
			ColourCrypter_BM_Variables.SteadyFocusShootingOn = false;
			ColourCrypter_Variables.BuffStatus.SteadyFocus = true;
		elseif(name == "Aspect of the Cheetah") then
			ColourCrypter_Variables.BuffStatus.AspectoftheCheetah = true;
		elseif(not name) then
			nameExist = false;
		end
		i = i + 1;
	end
end

function ColourCrypter_BM_WaitingForFocusFire()
	--if frenzy <= 0 return false
	--else if frenzy is about to expir
	--else if bw cooldown < ColourCrypter_BM_Variables.FocusFire.BestialWrathDelay return false;
	--else if frenzy >= 5 return true
	--else if FocusFire buff not on return true;
	-- else return false;
	if(not ColourCrypter_IsSpellReady(ColourCrypter_BM_Variables.FocusFire.SpellName)) then return false;
	elseif(ColourCrypter_Variables.BuffStatus.FrenzyStack <= 0) then return false 
	elseif (ColourCrypter_Variables.BuffStatus.FrenzyRemainingTime <= 3) then return true 
	elseif (ColourCrypter_BM_GetBestialWrathCoolDownRemaining() <= ColourCrypter_BM_Variables.FocusFire.BestialWrathDelay
		and ColourCrypter_BM_GetBestialWrathCoolDownRemaining() > 0) then
		return false;
	elseif (ColourCrypter_Variables.BuffStatus.FrenzyStack >= 5) then return true;
	elseif ((not ColourCrypter_Variables.BuffStatus.FocusFire) and ColourCrypter_Variables.BuffStatus.FrenzyStack >= 2) then return true;
	else return false;
	end
end


function ColourCrypter_BM_GetBestialWrathCoolDownRemaining()
	if(not ColourCrypter_BM_Variables.BestialWrathCoolDownRemaining) then		
		local start, duration, enable = GetSpellCooldown(ColourCrypter_BM_Variables.BestialWrath.SpellName);
		ColourCrypter_BM_Variables.BestialWrathCoolDownRemaining = (start + duration - ColourCrypter_Variables.BuffStatus.CurrentTime);
	end
	return ColourCrypter_BM_Variables.BestialWrathCoolDownRemaining;
end

function ColourCrypter_BM_CheckIsInActiveCombat()
	local canAttack = UnitCanAttack("player", "target");
	local inRange = IsSpellInRange("Auto Shot", "target");
	local inCombat = UnitAffectingCombat("player");
	return (canAttack and inRange and inCombat);
end

function ColourCrypter_BM_Attack()

    --steady focus finisher
	if ColourCrypter_BM_Variables.SteadyFocusShootingOn 
		and ColourCrypter_IsSpellReady(ColourCrypter_BM_Variables.CobraShot.SpellName) then
		ColourCrypter_SetAction(ColourCrypter_BM_Variables.CobraShot);
	--FocusFire
	elseif ColourCrypter_BM_WaitingForFocusFire() then
		ColourCrypter_SetAction(ColourCrypter_BM_Variables.FocusFire);
	--coounter shot
	elseif(ColourCrypter_IsSpellReady(ColourCrypter_BM_Variables.CounterShot.SpellName) 
		and ColourCrypter_IsTargetIntereptable()) then
		ColourCrypter_SetAction(ColourCrypter_BM_Variables.CounterShot);
	--BestialWrath
	elseif ColourCrypter_IsSpellReady(ColourCrypter_BM_Variables.BestialWrath.SpellName) then
		ColourCrypter_SetAction(ColourCrypter_BM_Variables.BestialWrath);
	--AOE
	elseif ColourCrypter_Variables.AoeAttack then
		ColourCrypter_BM_AttackAoe();
	--Single target
	else
		ColourCrypter_BM_AttackSingle();
	end
end



function ColourCrypter_BM_AttackAoe()
	ColourCrypter_BM_ScanPetBuffs();
	if not ColourCrypter_Variables.BuffStatus.BeastCleave 
		and ColourCrypter_IsSpellReady(ColourCrypter_BM_Variables.MultiShot.SpellName) then
			ColourCrypter_SetAction(ColourCrypter_BM_Variables.MultiShot);
	--Barrage
	elseif ColourCrypter_IsSpellReady(ColourCrypter_BM_Variables.Barrage.SpellName) then
		ColourCrypter_SetAction(ColourCrypter_BM_Variables.Barrage);
	-- Steady focus cobra shot
	elseif (not ColourCrypter_Variables.BuffStatus.SteadyFocus)
			and ColourCrypter_IsSpellReady(ColourCrypter_BM_Variables.CobraShot.SpellName) then
			ColourCrypter_BM_Variables.SteadyFocusShootingOn = true;
			ColourCrypter_SetAction(ColourCrypter_BM_Variables.CobraShot);
	--KillCommand
	elseif (ColourCrypter_BM_GetBestialWrathCoolDownRemaining() > ColourCrypter_BM_Variables.KillCommand.BestialWrathDelay
			or ColourCrypter_BM_GetBestialWrathCoolDownRemaining() < 0)
		and ColourCrypter_IsSpellReady(ColourCrypter_BM_Variables.KillCommand.SpellName)
		and(IsSpellInRange(ColourCrypter_BM_Variables.KillCommand.SpellName, "target")) then
		ColourCrypter_SetAction(ColourCrypter_BM_Variables.KillCommand);
	--KillShot
	elseif ColourCrypter_IsSpellReady(ColourCrypter_BM_Variables.KillShot.SpellName) then
		ColourCrypter_SetAction(ColourCrypter_BM_Variables.KillShot);
	else
		local petHealth = UnitHealth("pet");
		local petMaxValue = UnitHealthMax("pet"); 
		if (petHealth/petMaxValue)<0.9
			and (not ColourCrypter_Variables.BuffStatus.MendPet)
			and ColourCrypter_IsSpellReady(ColourCrypter_BM_Variables.MendPet.SpellName) then
			ColourCrypter_SetAction(ColourCrypter_BM_Variables.MendPet);
			return;
		end
		local focus = UnitPower("player", SPELL_POWER_FOCUS );
		--Arcane shot
		if focus > 60
			and ColourCrypter_IsSpellReady(ColourCrypter_BM_Variables.ArcaneShot.SpellName) then
			ColourCrypter_SetAction(ColourCrypter_BM_Variables.ArcaneShot);
			--Finally cobra shot
		elseif ColourCrypter_IsSpellReady(ColourCrypter_BM_Variables.CobraShot.SpellName) then
			ColourCrypter_SetAction(ColourCrypter_BM_Variables.CobraShot);
		else
			ColourCrypter_SetAction(ColourCrypter_AnyClass_Variable.DoNothing);
		end
	end
end

function ColourCrypter_BM_ScanPetBuffs()
	--ColourCrypter_Variables.BuffStatus
	--ColourCrypter_Variables.BuffStatus.CurrentTime = GetTime()
	ColourCrypter_Variables.BuffStatus.BeastCleave = false;
	ColourCrypter_Variables.BuffStatus.MendPet = false;
	local i = 1;
	local nameExist = true;
	while nameExist do
		local name, rank, icon, count, dispelType, duration, expires =  UnitAura("pet", i, "HELPFUL|PLAYER");
		if(name == "Beast Cleave") then
			ColourCrypter_Variables.BuffStatus.BeastCleave = true;
		elseif(name == "Mend Pet") then
			ColourCrypter_Variables.BuffStatus.MendPet = true;
		elseif(not name) then
			nameExist = false;
		end
		i = i + 1;
	end
end

function ColourCrypter_BM_AttackSingle()
	--KillCommand
	if (ColourCrypter_BM_GetBestialWrathCoolDownRemaining() > ColourCrypter_BM_Variables.KillCommand.BestialWrathDelay
			or ColourCrypter_BM_GetBestialWrathCoolDownRemaining() < 0)
		and ColourCrypter_IsSpellReady(ColourCrypter_BM_Variables.KillCommand.SpellName)
		and(IsSpellInRange(ColourCrypter_BM_Variables.KillCommand.SpellName, "target")) then
		ColourCrypter_SetAction(ColourCrypter_BM_Variables.KillCommand);
	--KillShot
	elseif ColourCrypter_IsSpellReady(ColourCrypter_BM_Variables.KillShot.SpellName) then
		ColourCrypter_SetAction(ColourCrypter_BM_Variables.KillShot);
	--name, type, difficulty, difficultyName, maxPlayers, playerDifficulty, isDynamicInstance, mapID, instanceGroupSize = GetInstanceInfo()
	--Barrage
	elseif ColourCrypter_IsSpellReady(ColourCrypter_BM_Variables.Barrage.SpellName) then
		ColourCrypter_SetAction(ColourCrypter_BM_Variables.Barrage);
	-- Steady focus cobra shot
	elseif (not ColourCrypter_Variables.BuffStatus.SteadyFocus)
			and ColourCrypter_IsSpellReady(ColourCrypter_BM_Variables.CobraShot.SpellName) then
			ColourCrypter_BM_Variables.SteadyFocusShootingOn = true;
			ColourCrypter_SetAction(ColourCrypter_BM_Variables.CobraShot);
	else
		ColourCrypter_BM_ScanPetBuffs();
		local petHealth = UnitHealth("pet");
		local petMaxValue = UnitHealthMax("pet"); 
		if( (petHealth/petMaxValue)<0.9
			and (not ColourCrypter_Variables.BuffStatus.MendPet)
			and ColourCrypter_IsSpellReady(ColourCrypter_BM_Variables.MendPet.SpellName)) then
			ColourCrypter_SetAction(ColourCrypter_BM_Variables.MendPet);
			return;
		end
		local focus = UnitPower("player", SPELL_POWER_FOCUS );
		--Arcane shot
		if focus > 60
			and ColourCrypter_IsSpellReady(ColourCrypter_BM_Variables.ArcaneShot.SpellName) then
			ColourCrypter_SetAction(ColourCrypter_BM_Variables.ArcaneShot);
			--Finally cobra shot
		elseif ColourCrypter_IsSpellReady(ColourCrypter_BM_Variables.CobraShot.SpellName) then
			ColourCrypter_SetAction(ColourCrypter_BM_Variables.CobraShot);
		else
			ColourCrypter_SetAction(ColourCrypter_AnyClass_Variable.DoNothing);
		end
	end
	-- start, duration, enable = GetSpellCooldown(index, "bookType") or GetSpellCooldown("name") or GetSpellCooldown(id)
	--isUsable, notEnoughMana = IsUsableSpell(index, "bookType") or IsUsableSpell("name")
	--name, rank, icon, castingTime, minRange, maxRange, spellID = GetSpellInfo("Bestial Wrath")
	--print(tostring(spellID));
	--start, duration, enable = GetSpellCooldown("GetSpellCooldown");
end
