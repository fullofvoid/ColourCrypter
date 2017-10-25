


-- Globals Section
-- Modifiers Ctrl - 1, alt-2, Shift-4, no repeat - 8, Print - 16


ColourCrypter_BD_Variables =
{
	--Left bar
	["Moonkin Form"] 		= {["Key"] = {["R"] = 1/256;["G"] = 0/256;["B"] = (4+2)/256;},},
	["Travel Form"] 		= {["Key"] = {["R"] = 2/256;["G"] = 0/256;["B"] = (4+2)/256;},},
	["Starsurge"]	 		= {["Key"] = {["R"] = 3/256;["G"] = 0/256;["B"] = (4+2)/256;},},
	["Starfall"]	 		= {["Key"] = {["R"] = 4/256;["G"] = 0/256;["B"] = (4+2)/256;},},
	["Astral Communion"]	= {["Key"] = {["R"] = 5/256;["G"] = 0/256;["B"] = (4+2)/256;},},
	["Incarnation: Chosen of Elune"]= {["Key"] = {["R"] = 6/256;["G"] = 0/256;["B"] = (4+2)/256;},},
	["Solar Beam"] 			= {["Key"] = {["R"] = 9/256;["G"] = 0/256;["B"] = (4+2)/256;},},
	["Remove Corruption"]	= {["Key"] = {["R"] =10/256;["G"] = 0/256;["B"] = (4+2)/256;},},
	["Healing Touch"]	 	= {["Key"] = {["R"] =11/256;["G"] = 0/256;["B"] = (4+2)/256;},},
	--Right bar
	["Sunfire"]  			= {["Key"] = {["R"] = 1/256;["G"] = 0/256;["B"] = (1+4)/256;},},
	["Moonfire"]  			= {["Key"] = {["R"] = 2/256;["G"] = 0/256;["B"] = (1+4)/256;},},
	["Solar Wrath"]  		= {["Key"] = {["R"] = 3/256;["G"] = 0/256;["B"] = (1+4)/256;},},
	["Lunar Strike"]  		= {["Key"] = {["R"] = 4/256;["G"] = 0/256;["B"] = (1+4)/256;},},
	["New Moon"]  			= {["Key"] = {["R"] = 5/256;["G"] = 0/256;["B"] = (1+4)/256;},},
	--["Shred"]  				= {["Key"] = {["R"] = 5/256;["G"] = 0/256;["B"] = (1+4)/256;},},
	--["Rip"]  				= {["Key"] = {["R"] = 6/256;["G"] = 0/256;["B"] = (1+4)/256;},},
	--["Ferocious Bite"]  	= {["Key"] = {["R"] = 7/256;["G"] = 0/256;["B"] = (1+4)/256;},},
	--["Berserk"]  			= {["Key"] = {["R"] = 8/256;["G"] = 0/256;["B"] = (1+4)/256;},},
	["Barkskin"]			= {["Key"] = {["R"] = 9/256;["G"] = 0/256;["B"] = (1+4)/256;},},
	["Renewal"]  			= {["Key"] = {["R"] =10/256;["G"] = 0/256;["B"] = (  4)/256;},},
	["Swiftmend"]  			= {["Key"] = {["R"] =11/256;["G"] = 0/256;["B"] = (1+4)/256;},},
	["Rejuvenation"]  		= {["Key"] = {["R"] =12/256;["G"] = 0/256;["B"] = (1+4)/256;},},
	
	["DotMinHealth"] = 400000;
	--
};

function ColourCrypter_BD_CheckSetAction(name)
	return ColourCrypter_CheckSetAction(name, ColourCrypter_BD_Variables[name]);
end

function ColourCrypter_BD_ScanBuffs()
	--ColourCrypter_Variables.BuffStatus
	ColourCrypter_Variables.BuffStatus.CurrentTime = GetTime()
	ColourCrypter_Variables.BuffStatus.MoonkinForm = false;
	ColourCrypter_Variables.BuffStatus.LunarEmpowerment = 0;
	ColourCrypter_Variables.BuffStatus.SolarEmpowerment = 0;
	ColourCrypter_Variables.BuffStatus.TravelForm = false;
	ColourCrypter_Variables.BuffStatus.CursePoison = false;
	ColourCrypter_Variables.BuffStatus.Rejuvenation = false;
	local i = 1;
	local nameExist = true;
	while nameExist do
		local name, rank, icon, count, dispelType, duration, expires =  UnitAura("player", i, "PLAYER");
		if(name == "Moonkin Form") then
			ColourCrypter_Variables.BuffStatus.MoonkinForm = true;
			--print("Unit test : Buff : Moonkin Form");
		elseif(name == "Lunar Empowerment") then
			ColourCrypter_Variables.BuffStatus.LunarEmpowerment = count;
			--print("Unit test : Buff : Lunar Empowerment");
		elseif(name == "Solar Empowerment") then
			ColourCrypter_Variables.BuffStatus.SolarEmpowerment = count;
			--print("Unit test : Buff : Solar Empowerment");
		elseif(name == "Travel Form") then
			ColourCrypter_Variables.BuffStatus.TravelForm = true;
			--print("Unit test : Buff : TravelForm");
		elseif(name == "Rejuvenation") then
			ColourCrypter_Variables.BuffStatus.Rejuvenation = true;
			--print("Unit test : Buff : Rejuvenation");
		elseif(dispelType == "Curse" or dispelType == "Poison" ) then
			ColourCrypter_Variables.BuffStatus.CursePoison = true;
			print("Unit test : Buff : curse poison");
		elseif(not name) then  
			nameExist = false;
		end
		i = i + 1;
	end
end

function ColourCrypter_BD_ScanTargetDeBuffs()
	--ColourCrypter_Variables.BuffStatus
	ColourCrypter_Variables.BuffStatus.MoonfireRemainingTime = 0;
	ColourCrypter_Variables.BuffStatus.SunfireRemainingTime = 0;
	local i = 1;
	local nameExist = true;
	while nameExist do
		local name, rank, icon, count, dispelType, duration, expires =  UnitAura("target", i, "HARMFUL");
		if(name == "Sunfire") then
			ColourCrypter_Variables.BuffStatus.SunfireRemainingTime = expires- ColourCrypter_Variables.BuffStatus.CurrentTime;
			--print("Unit test : Target Buff : Sunfire");
		elseif(name == "Moonfire") then
			ColourCrypter_Variables.BuffStatus.MoonfireRemainingTime = expires- ColourCrypter_Variables.BuffStatus.CurrentTime;
			--print("Unit test : Target Buff : Moonfire");
		elseif(not name) then
			nameExist = false;
		end
		i = i + 1;
	end
end


function ColourCrypter_BD_TimedUpdate()
	ColourCrypter_BD_ScanBuffs();
	ColourCrypter_BD_ScanTargetDeBuffs();
	
	if(ColourCrypter_BD_CheckIsInActiveCombat()) then
		ColourCrypter_Variables.LootPending = false;
		ColourCrypter_BD_Attack();
	else
		--if(ColourCrypter_Variables.LootPending) then
		--	ColourCrypter_SetAction(ColourCrypter_AnyClass_Variable.Loot);
		--if(not ColourCrypter_Variables.BuffStatus.TravelForm 
			--and not ColourCrypter_Variables.BuffStatus.Prowl
		--	and IsFlyableArea() --IsOutdoors()
		--	and not  UnitAffectingCombat("player")) then
		--	if ColourCrypter_BD_CheckSetAction("Travel Form") then return; end
		--else 
			ColourCrypter_SetActionDoNothing();
		--end
	end
end


function ColourCrypter_BD_CheckIsInActiveCombat()
	
	local canAttack = UnitCanAttack("player", "target");
	local inRange = IsSpellInRange("Moonfire", "target");
	local inCombat = UnitAffectingCombat("player");
	--print(tostring(canAttack)..tostring(inRange)..tostring(inCombat))
	return (canAttack and inRange and inCombat);
end

function ColourCrypter_BD_Attack()
	if ColourCrypter_BD_Defend() then 
		return;
    elseif ColourCrypter_Variables.AoeAttack then
		ColourCrypter_BD_AttackAoe();
	--Single target
	else
		ColourCrypter_BD_AttackSingle();
	end
end
function ColourCrypter_BD_Defend()
-- interupt
--if ColourCrypter_Variables.BuffStatus.CursePoison, Apply Remove Corruption
-- Check health below 50 then 
	--if buff not up apply rejov 
	--apply swift mend, 
	--apply renwe, 
	--if buff not up apply survival instincts 
	if(ColourCrypter_IsTargetIntereptable()) then
		if ColourCrypter_BD_CheckSetAction("Solar Beam") then return true; end
	end
	if(ColourCrypter_Variables.BuffStatus.CursePoison) then
		if ColourCrypter_BD_CheckSetAction("Remove Corruption") then return true; end
	end
	if (UnitHealth("player")/UnitHealthMax("player")) < 0.70 then
		if ColourCrypter_BD_CheckSetAction("Barkskin") then return true; end
		if(not ColourCrypter_Variables.BuffStatus.Rejuvenation) then 
			if ColourCrypter_BD_CheckSetAction("Rejuvenation") then return true; end
		end
		if ColourCrypter_BD_CheckSetAction("Swiftmend") then return true; end
		if ColourCrypter_BD_CheckSetAction("Renewal") then return true; end
	end
	if(not ColourCrypter_Variables.BuffStatus.MoonkinForm) then
		if ColourCrypter_BD_CheckSetAction("Moonkin Form") then return true; end
	end
	return false;
end


function ColourCrypter_BD_AttackAoe()
	--if not debuf moonfire
	--if not debuf sunfire
	--star fall
	--Lunar strike
	if ColourCrypter_BD_CheckSetAction("Incarnation: Chosen of Elune") then return true; end
	local  unitPower = UnitPower("player");
	if( unitPower < 25) then
		if ColourCrypter_BD_CheckSetAction("Astral Communion") then return true; end
	end
	if(ColourCrypter_Variables.BuffStatus.LunarEmpowerment > 1 or ColourCrypter_Variables.BuffStatus.SolarEmpowerment > 1) then
		if ColourCrypter_BD_CheckSetAction("Starfall") then return true; end
	else
		if ColourCrypter_BD_CheckSetAction("Starsurge") then return true; end
	end
	
	local targetHealth = UnitHealth("target");
	if ( targetHealth  > ColourCrypter_BD_Variables.DotMinHealth ) then 
		if(ColourCrypter_Variables.BuffStatus.MoonfireRemainingTime < 6) then
			if ColourCrypter_BD_CheckSetAction("Moonfire") then return true; end
		end
		if(ColourCrypter_Variables.BuffStatus.SunfireRemainingTime < 6) then
			if ColourCrypter_BD_CheckSetAction("Sunfire") then return true; end
		end
	end
	local charges, maxCharges, start, duration = GetSpellCharges("New Moon") ;
	
	if(charges > 1) then
		if ColourCrypter_BD_CheckSetAction("New Moon") then return true; end;
	end
	if(ColourCrypter_Variables.BuffStatus.LunarEmpowerment > 0) then 
		if ColourCrypter_BD_CheckSetAction("Lunar Strike") then return true; end
	end
	if(ColourCrypter_Variables.BuffStatus.SolarEmpowerment > 0) then
		if ColourCrypter_BD_CheckSetAction("Solar Wrath") then return true; end
	end
	
	if ColourCrypter_BD_CheckSetAction("New Moon") then return true; end;
	if ColourCrypter_BD_CheckSetAction("Lunar Strike") then return true; end
	ColourCrypter_SetActionDoNothing();
end

function ColourCrypter_BD_AttackSingle()
	
	--Incarnation: Chosen of Elune
	--if power less than 25 Astral Communion
	--if not debuf moonfire
	--if not debuf sunfire
	--star surge
	--Starsurge
	--if LunarEmpowerment Lunar Strike
	--Solar Wrath
	
	
	if ColourCrypter_BD_CheckSetAction("Incarnation: Chosen of Elune") then return true; end
	local  unitPower = UnitPower("player");
	if( unitPower < 25) then
		if ColourCrypter_BD_CheckSetAction("Astral Communion") then return true; end
	end
	if(ColourCrypter_Variables.BuffStatus.LunarEmpowerment > 2 or ColourCrypter_Variables.BuffStatus.SolarEmpowerment > 2) then
		if ColourCrypter_BD_CheckSetAction("Starfall") then return true; end
	else
		if ColourCrypter_BD_CheckSetAction("Starsurge") then return true; end
	end
	
	local targetHealth = UnitHealth("target");
	if ( targetHealth  > ColourCrypter_BD_Variables.DotMinHealth ) then 
		if(ColourCrypter_Variables.BuffStatus.MoonfireRemainingTime < 6) then
			if ColourCrypter_BD_CheckSetAction("Moonfire") then return true; end
		end
		if(ColourCrypter_Variables.BuffStatus.SunfireRemainingTime < 6) then
			if ColourCrypter_BD_CheckSetAction("Sunfire") then return true; end
		end
	end
	local charges, maxCharges, start, duration = GetSpellCharges("New Moon") ;
	
	if(charges > 1) then
		if ColourCrypter_BD_CheckSetAction("New Moon") then return true; end;
	end
	if(ColourCrypter_Variables.BuffStatus.SolarEmpowerment > 0 ) then
		if ColourCrypter_BD_CheckSetAction("Solar Wrath") then return true; end
	end
	if(ColourCrypter_Variables.BuffStatus.LunarEmpowerment > 0) then 
		if ColourCrypter_BD_CheckSetAction("Lunar Strike") then return true; end
	end
	
	if ColourCrypter_BD_CheckSetAction("New Moon") then return true; end;
		if ColourCrypter_BD_CheckSetAction("Solar Wrath") then return true; end
	ColourCrypter_SetActionDoNothing();
end
