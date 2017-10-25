

ColourCrypter_MM_Variables =
{
	["ChimaeraShot"] ={
		["Key"] = {
			["R"] = 1/256;
			["G"] = 0/256;
			["B"] = (4+2)/256;
		},
		["SpellName"] = "Chimaera Shot";
	},
	["AimedShot"] ={
		["Key"] = {
			["R"] = 2/256;
			["G"] = 0/256;
			["B"] = (4+2)/256;
		},
		["SpellName"] = "Aimed Shot";
	},
	["RapidFire"] ={
		["Key"] = {
			["R"] = 2/256;
			["G"] = 0/256;
			["B"] = (1+4)/256;
		},
		["SpellName"] = "Rapid Fire";
	},
	["SteadyShot"] ={
		["Key"] = {
			["R"] = 3/256;
			["G"] = 0/256;
			["B"] = (4+2)/256;
		},
		["SpellName"] = "Steady Shot";
	},
	["GlaiveToss"] ={
		["Key"] = {
			["R"] = 3/256;
			["G"] = 0/256;
			["B"] = (1+4)/256;
		},
		["SpellName"] = "Glaive Toss";
	},
	["AMurderofCrows"] ={
		["Key"] = {
			["R"] = 4/256;
			["G"] = 0/256;
			["B"] = (4+2)/256;
		},
		["SpellName"] = "A Murder of Crows";
	},
	["MultiShot"] ={
		["Key"] = {
			["R"] = 4/256;
			["G"] = 0/256;
			["B"] = (1+4)/256;
		},
		["SpellName"] = "Multi-Shot";
	},
	["AspectoftheCheetah"] ={
		["Key"] = {
			["R"] = 5/256;
			["G"] = 0/256;
			["B"] = (4+2)/256;
		},
		["SpellName"] = "Aspect of the Cheetah";
	},
	["CounterShot"] ={
		["Key"] = {
			["R"] = 5/256;
			["G"] = 0/256;
			["B"] = (1+4)/256;
		},
		["SpellName"] = "Counter Shot";
	},
	["KillShot"] ={
		["Key"] = {
			["R"] = 6/256;
			["G"] = 0/256;
			["B"] = (1+4)/256;
		},
		["SpellName"] = "Kill Shot";
	},
	["Exhilaration"] ={
		["Key"] = {
			["R"] = 6/256;
			["G"] = 0/256;
			["B"] = (4+2)/256;
		},
		["SpellName"] = "Exhilaration";
	}
};


function ColourCrypter_MM_TimedUpdate()

	ColourCrypter_MM_ScanBuffs();
	
	if(ColourCrypter_MM_CheckIsInActiveCombat()) then
		ColourCrypter_Variables.LootPending = true;
		ColourCrypter_MM_Attack();
	else
		if(ColourCrypter_Variables.LootPending) then
			ColourCrypter_SetAction(ColourCrypter_AnyClass_Variable.Loot);
		elseif(not ColourCrypter_Variables.BuffStatus.AspectoftheCheetah) 
			and ColourCrypter_IsSpellReady(ColourCrypter_MM_Variables.AspectoftheCheetah.SpellName) then
			ColourCrypter_SetAction(ColourCrypter_MM_Variables.AspectoftheCheetah);
		else 
			ColourCrypter_SetAction(ColourCrypter_AnyClass_Variable.DoNothing);
		end
	end
	
end


function ColourCrypter_MM_ScanBuffs()
	--ColourCrypter_Variables.BuffStatus
	ColourCrypter_Variables.BuffStatus.CurrentTime = GetTime()
	ColourCrypter_Variables.BuffStatus.RapidFire = false;
	ColourCrypter_Variables.BuffStatus.AspectoftheCheetah = false;
	local i = 1;
	local nameExist = true;
	while nameExist do
		local name, rank, icon, count, dispelType, duration, expires =  UnitAura("player", i, "HELPFUL|PLAYER");
		if(name == "Rapid Fire") then
			ColourCrypter_Variables.BuffStatus.RapidFire = true;
		elseif(name == "Aspect of the Cheetah") then
			ColourCrypter_Variables.BuffStatus.AspectoftheCheetah = true;
		elseif(not name) then
			nameExist = false;
		end
		i = i + 1;
	end
end


function ColourCrypter_MM_CheckIsInActiveCombat()
	local canAttack = UnitCanAttack("player", "target");
	local inRange = IsSpellInRange("Auto Shot", "target");
	local inCombat = UnitAffectingCombat("player");
	return (canAttack and inRange and inCombat);
end

function ColourCrypter_MM_Attack()
	--Exhilaration
	local unitH = UnitHealth("player");
	local unitMaxH = UnitHealthMax("player"); 
	if(unitH/unitMaxH) < 0.7 and 
		ColourCrypter_IsSpellReady(ColourCrypter_MM_Variables.Exhilaration.SpellName) then
		ColourCrypter_SetAction(ColourCrypter_MM_Variables.Exhilaration);
		return
	--coounter shot
	elseif(ColourCrypter_IsSpellReady(ColourCrypter_MM_Variables.CounterShot.SpellName) 
		and ColourCrypter_IsTargetIntereptable()) then
		ColourCrypter_SetAction(ColourCrypter_MM_Variables.CounterShot);
		return
	--RapidFire
	elseif ColourCrypter_IsSpellReady(ColourCrypter_MM_Variables.RapidFire.SpellName) then
		ColourCrypter_SetAction(ColourCrypter_MM_Variables.RapidFire);
		return
	--ChimaeraShot
	elseif ColourCrypter_IsSpellReady(ColourCrypter_MM_Variables.ChimaeraShot.SpellName) then
		ColourCrypter_SetAction(ColourCrypter_MM_Variables.ChimaeraShot);
		return
	--KillShot
	elseif ColourCrypter_IsSpellReady(ColourCrypter_MM_Variables.KillShot.SpellName) then
		ColourCrypter_SetAction(ColourCrypter_MM_Variables.KillShot);
		return
	end
	--AimedShot with crit buff
	local aimedSHotReady = ColourCrypter_IsSpellReady(ColourCrypter_MM_Variables.AimedShot.SpellName);
	if ColourCrypter_Variables.BuffStatus.RapidFire and aimedSHotReady then
		ColourCrypter_SetAction(ColourCrypter_MM_Variables.AimedShot);
		return
	end
	local targetHealth = UnitHealth("target");
	local targetMaxValue = UnitHealthMax("target"); 
	if  (targetHealth/targetMaxValue) > 0.8  and aimedSHotReady then
		ColourCrypter_SetAction(ColourCrypter_MM_Variables.AimedShot);
		return
	end
	if (not ColourCrypter_Variables.BuffStatus.RapidFire) then
		--AMurderofCrows
		if  ColourCrypter_IsSpellReady(ColourCrypter_MM_Variables.AMurderofCrows.SpellName) then
			ColourCrypter_SetAction(ColourCrypter_MM_Variables.AMurderofCrows);
			return
		--GlaiveToss
		elseif ColourCrypter_IsSpellReady(ColourCrypter_MM_Variables.GlaiveToss.SpellName) then
			ColourCrypter_SetAction(ColourCrypter_MM_Variables.GlaiveToss);
			return
		end
	end
	if ColourCrypter_Variables.AoeAttack then
		--MultiShot
		if ColourCrypter_IsSpellReady(ColourCrypter_MM_Variables.MultiShot.SpellName) then
			ColourCrypter_SetAction(ColourCrypter_MM_Variables.MultiShot);
			return
		end
	--AimedShot
	elseif aimedSHotReady then
		ColourCrypter_SetAction(ColourCrypter_MM_Variables.AimedShot);
		return
	end
	--SteadyShot
	if ColourCrypter_IsSpellReady(ColourCrypter_MM_Variables.SteadyShot.SpellName) then
		ColourCrypter_SetAction(ColourCrypter_MM_Variables.SteadyShot);
		return
	else
		ColourCrypter_SetAction(ColourCrypter_AnyClass_Variable.DoNothing);
	end
end
