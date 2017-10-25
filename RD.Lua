

---------------------------------------------------------------------RD.Lua-----------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------RD.Lua-----------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------RD.Lua-----------------------------------------------------------------------------------------------------------------
--  /run ColourCrypter_RD_Variables.LifebloomTriger   =  8000;
--  /run ColourCrypter_RD_Variables.WildGrowthTriger  = 36000;
--  /run ColourCrypter_RD_Variables.RegrowthTriger    = 28000;
--  /run ColourCrypter_RD_Variables.SwiftmendTriger   =216000;

--  /run ColourCrypter_RD_Variables.RejuvenationTriger= 32000;
--  /run ColourCrypter_RD_Variables.RejuvenationGermnationTriger= 32000;



-- Globals Section
-- Modifiers Ctrl - 1, alt-2, Shift-4, no repeat - 8, Print - 16


ColourCrypter_RD_Variables =
{

  IsSolo = false;
  InReHealMode = false;
  --Left bar
  ["Swiftmend"]           = {["Key"] = {["R"] = 1/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Regrowth"]            = {["Key"] = {["R"] = 2/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Wild Growth"]         = {["Key"] = {["R"] = 3/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Flourish"]            = {["Key"] = {["R"] = 4/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Barkskin"]            = {["Key"] = {["R"] = 5/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Innervate"]           = {["Key"] = {["R"] = 6/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  
  
  ["Rake"]                = {["Key"] = {["R"] = 9/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Cat Form"]            = {["Key"] = {["R"] =10/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Moonfire"]            = {["Key"] = {["R"] =11/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Rebirth"]             = {["Key"] = {["R"] =12/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  
  --Right bar
  ["Lifebloom"]           = {["Key"] = {["R"] = 1/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["Rejuvenation"]        = {["Key"] = {["R"] = 2/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["Healing Touch"]       = {["Key"] = {["R"] = 3/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["Essence of G'Hanir"]  = {["Key"] = {["R"] = 4/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["Ironbark"]            = {["Key"] = {["R"] = 5/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["Nature's Cure"]       = {["Key"] = {["R"] = 6/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  
  ["Ferocious Bite"]      = {["Key"] = {["R"] = 8/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["Shred"]               = {["Key"] = {["R"] = 9/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["Rip"]                 = {["Key"] = {["R"] =10/256;["G"] = 0/256;["B"] = (  4)/256;},},
  ["Sunfire"]             = {["Key"] = {["R"] =11/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["Revitalize"]          = {["Key"] = {["R"] =12/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  
  
  --Bottom Right bar
  ["Thrash"]              = {["Key"] = {["R"] = 1/256;["G"] = 0/256;["B"] = (  4)/256;},},
  ["Mangle"]              = {["Key"] = {["R"] = 2/256;["G"] = 0/256;["B"] = (  4)/256;},},
  ["Ironfur"]             = {["Key"] = {["R"] = 3/256;["G"] = 0/256;["B"] = (  4)/256;},},
  ["Frenzied Regeneration"]={["Key"] = {["R"] = 4/256;["G"] = 0/256;["B"] = (  4)/256;},},
  ["Bear Form"]            ={["Key"] = {["R"] = 5/256;["G"] = 0/256;["B"] = (  4)/256;},},
  
};


function ColourCrypter_RD_CheckSetAction(spellName, actionName, target)
  if(not actionName) then actionName = spellName; end;
  return ColourCrypter_CheckSetAction(spellName, ColourCrypter_RD_Variables[actionName], target);
end


function ColourCrypter_RD_CheckBuffAndSetAction(spellName, actionName, buffToAvoid, unitEnumToTarget, unitStringToCheckBuffOn)
  if(ColourCrypter_GetBuffRemainingTime(unitStringToCheckBuffOn, buffToAvoid) < 1 ) then
    if ColourCrypter_RD_CheckSetAction(spellName, actionName, unitEnumToTarget) then return true; end
  end
end

function ColourCrypter_RD_TimedUpdate()
  ColourCrypter_Variables.LootPending = false;  
  --cure
  if ColourCrypter_RD_Cure() then return; end
  
  if(ColourCrypter_RD_Variables.IsSolo) then
    if(ColourCrypter_RD_CheckIsBearInActiveCombat()) then
      if ColourCrypter_RD_BearAttackCycle() then return; end
    end
  else
    if ColourCrypter_RD_HealDungen() then return; end
  end
   
  ColourCrypter_SetActionDoNothing();
    
  
end

function ColourCrypter_RD_CheckIsBearInActiveCombat()
  
  local canAttack = UnitCanAttack("player", "target");
  local inRange = IsCurrentSpell("Auto Attack");
  local inCombat = UnitAffectingCombat("player");
  return (canAttack and inRange and inCombat);
end

function ColourCrypter_RD_Cure_Unit(unit, unitCode)
  if(UnitExists(unit)) then
    if(IsSpellInRange("Nature's Cure", unit)) then
      local i = 1;
      local nameExist = true;
      while nameExist do
        local name, rank, icon, count, dispelType, duration, expires =  UnitAura(unit, i, "HARMFUL");
        if(dispelType == "Curse" or dispelType == "Poison" or dispelType =="Magic") then
          if ColourCrypter_RD_CheckSetAction("Nature's Cure", nil, unitCode) then return true; end
        elseif(not name) then
          nameExist = false;
        end
        i = i + 1;
      end
    end
  end
  return false;
end

function ColourCrypter_RD_Cure()
  if(ColourCrypter_RD_Cure_Unit("player", ColourCrypter_Variables.Unit_Player)) then return true; end
  if(ColourCrypter_RD_Cure_Unit("focus", ColourCrypter_Variables.Unit_Focus)) then return true; end
  if(ColourCrypter_RD_Cure_Unit("party1", ColourCrypter_Variables.Unit_Party1)) then return true; end
  if(ColourCrypter_RD_Cure_Unit("party2", ColourCrypter_Variables.Unit_Party2)) then return true; end
  if(ColourCrypter_RD_Cure_Unit("party3", ColourCrypter_Variables.Unit_Party3)) then return true; end
  if(ColourCrypter_RD_Cure_Unit("party4", ColourCrypter_Variables.Unit_Party4)) then return true; end
  
  if(UnitIsDead("mouseover")) then
    if(IsSpellInRange("Rebirth", "mouseover")) then
      if(UnitAffectingCombat("player")) then
        if ColourCrypter_RD_CheckSetAction("Rebirth") then return true; end
      else
        if ColourCrypter_RD_CheckSetAction("Revitalize") then return true; end
      end
    end
  end
  return false;
end

 
--function ColourCrypter_RD_HealDungen()
-- if 4 guys have less than 0.7 cast wild growth on self
-- if 3 guys have less then 0.7 cast Innervate
-- if is less then 0.4 Barkskin
-- healUnit(self)
-- healTank()
-- if mana is less than 0.2 return
-- healUnit(party1)
-- healUnit(party2)
-- healUnit(party3)
-- healUnit(party4)

--function healUnit(unit)
--int unitHealth = GetUnithealth(); --> (unithealth+incoming heals)/unit max health
--if unit has buff reJov -> unitHealth += .2;
--if unit has buff germination -> unitHealth += .2;
--if(unit health < 1) apply(rejov), apply(germiination) --apply checks hot buffs
--if(unit health < .8) apply(regrowth) apply(healingtouch) 


--functionhealTank()
--if clearcast regrowth
--int unitHealth = GetUnithealth(); --> (unithealth+incoming heals)/unit max health
--if health < 1 run lifebloom
--if health < 0.9 apply rejov, germination
--if health < 0.85 apply regrowth
--if health < 0.8 apply swift mend
--if health < 0.6 apply flurish/ghnair
--if health < 0.5 apply Iornbark
--if health < 0.75 apply healing touch

--BearAttackCycle
--if low helth set rehealmode true
--if rehalmode on BearHeal
--else bear attack

--BearAttack
--Bearform, Thrash, mangel, moonfire, Ironfur, Frenzy regen, Iron Bark

--BearHeal
--swiftmend,Barkskin,rejov, germin,  regrowth, flurish/ghnair, lifebloom
--If helth still below 0.9 regrowth
--set set rehealmode false

function ColourCrypter_RD_HealDungen()
  local numberOfModerateDamagedMembers = 0;
  if((UnitHealth("player")/UnitHealthMax("player")) < 0.7) then numberOfModerateDamagedMembers = numberOfModerateDamagedMembers + 1; end
  if((UnitHealth("party1")/UnitHealthMax("party1")) < 0.7)and (not UnitIsDead("party1") and UnitExists("party1")) then numberOfModerateDamagedMembers = numberOfModerateDamagedMembers + 1; end
  if((UnitHealth("party2")/UnitHealthMax("party2")) < 0.7)and (not UnitIsDead("party2") and UnitExists("party1")) then numberOfModerateDamagedMembers = numberOfModerateDamagedMembers + 1; end
  if((UnitHealth("party3")/UnitHealthMax("party3")) < 0.7)and (not UnitIsDead("party3") and UnitExists("party1")) then numberOfModerateDamagedMembers = numberOfModerateDamagedMembers + 1; end
  if((UnitHealth("party4")/UnitHealthMax("party4")) < 0.7)and (not UnitIsDead("party4") and UnitExists("party1")) then numberOfModerateDamagedMembers = numberOfModerateDamagedMembers + 1; end
  
  
  if(numberOfModerateDamagedMembers >= 2) then
    if ColourCrypter_RD_CheckBuffAndSetAction("Wild Growth", nil, "Wild Growth", ColourCrypter_Variables.Unit_Player, "player") then return true end
  end
  if(numberOfModerateDamagedMembers >= 3) then
    if ColourCrypter_RD_CheckSetAction("Innervate", nil, ColourCrypter_Variables.Unit_Player) then return true; end
  end
  if (UnitHealth("player")/UnitHealthMax("player")) < 0.4 then 
    if ColourCrypter_RD_CheckSetAction("Barkskin", nil, ColourCrypter_Variables.Unit_Player) then return true; end
  end
  if ColourCrypter_RD_HealUnit("player", ColourCrypter_Variables.Unit_Player) then return true end
  
  if ColourCrypter_RD_HealTank() then return true end
  if( (UnitPower("player")/UnitPowerMax("player")) > 0.2) then
    if ColourCrypter_RD_HealUnit("party1", ColourCrypter_Variables.Unit_Party1) then return true end
    if ColourCrypter_RD_HealUnit("party2", ColourCrypter_Variables.Unit_Party2) then return true end
    if ColourCrypter_RD_HealUnit("party3", ColourCrypter_Variables.Unit_Party3) then return true end
    if ColourCrypter_RD_HealUnit("party4", ColourCrypter_Variables.Unit_Party4) then return true end
  end
  return false;
end

function UnitGetIncomingHealsFixed(unitString)
  local value = UnitGetIncomingHeals(unitString);
  if(not value) then value = 0; end
  return value;
end

function ColourCrypter_RD_HealUnit(unitString, unit)
  if(UnitIsDead(unitString) or (not UnitExists(unitString))) then return false; end 

  local unitHealth = (UnitHealth(unitString)+UnitGetIncomingHealsFixed(unitString))/UnitHealthMax(unitString);
  if(ColourCrypter_GetBuffRemainingTime(unitString, "Rejuvenation") > 1) then unitHealth = unitHealth+ 0.2; end
  if(ColourCrypter_GetBuffRemainingTime(unitString, "Rejuvenation (Germination)") > 1) then unitHealth = unitHealth+ 0.2; end 
  if(unitHealth < 1)then
    if ColourCrypter_RD_CheckBuffAndSetAction("Rejuvenation", nil, "Rejuvenation", unit, unitString) then return true end
    if ColourCrypter_RD_CheckBuffAndSetAction("Rejuvenation", nil, "Rejuvenation (Germination)", unit, unitString) then return true end
    if ColourCrypter_RD_CheckBuffAndSetAction("Regrowth", nil, "Regrowth", unit, unitString) then return true end
    if ColourCrypter_RD_CheckSetAction("Healing Touch", nil, unit) then return true; end
  end 
  return false;
end

function ColourCrypter_RD_HealTank()

  if(UnitIsDead("focus") or (not UnitExists("focus"))) then return false; end
  local focusHealth = (UnitHealth("focus")+UnitGetIncomingHealsFixed("focus"))/UnitHealthMax("focus");
  if(focusHealth < 1) then 
    if ColourCrypter_RD_CheckBuffAndSetAction("Lifebloom", nil, "Lifebloom", ColourCrypter_Variables.Unit_Focus, "focus") then return true end
  end
  if(focusHealth < 0.8) then
    if ColourCrypter_RD_CheckSetAction("Swiftmend", nil,  ColourCrypter_Variables.Unit_Focus) then return true; end
  end
  if(focusHealth < 0.9) then 
    if ColourCrypter_RD_CheckBuffAndSetAction("Rejuvenation", nil, "Rejuvenation", ColourCrypter_Variables.Unit_Focus, "focus") then return true end
    if ColourCrypter_RD_CheckBuffAndSetAction("Rejuvenation", nil, "Rejuvenation (Germination)", ColourCrypter_Variables.Unit_Focus, "focus") then return true end
  end
  if(focusHealth < 0.85) then 
    if ColourCrypter_RD_CheckBuffAndSetAction("Regrowth", nil, "Regrowth", ColourCrypter_Variables.Unit_Focus, "focus") then return true end
  end
  if(focusHealth < 0.6) then
    if ColourCrypter_RD_CheckSetAction("Flourish") then return true; end
    if ColourCrypter_RD_CheckSetAction("Essence of G'Hanir") then return true; end
  end
  if(focusHealth < 0.5) then
    if ColourCrypter_RD_CheckSetAction("Ironbark", nil,  ColourCrypter_Variables.Unit_Focus) then return true; end
  end
  if(ColourCrypter_GetBuffRemainingTime("player", "Clearcasting")> 0) then
    if ColourCrypter_RD_CheckSetAction("Regrowth", nil,  ColourCrypter_Variables.Unit_Focus) then return true; end
  end
  
  if(focusHealth < 0.75) then
    if ColourCrypter_RD_CheckSetAction("Healing Touch", nil,  ColourCrypter_Variables.Unit_Focus) then return true; end
  end
  return false;
end


function ColourCrypter_RD_BearAttackCycle()
  local unitHealth = (UnitHealth("player"))/UnitHealthMax("player");
  if(unitHealth < 0.25) then ColourCrypter_RD_Variables.InReHealMode = true; end
  if(ColourCrypter_RD_Variables.InReHealMode) then
    if(ColourCrypter_RD_BearHeal()) then return true; end
  else
    if (ColourCrypter_RD_BearAttack()) then return true; end
  end
  return false;
end

function ColourCrypter_RD_BearHeal()
  if ColourCrypter_RD_CheckSetAction("Swiftmend") then return true; end
  if ColourCrypter_RD_CheckSetAction("Barkskin") then return true; end
  if ColourCrypter_RD_CheckBuffAndSetAction("Rejuvenation", nil, "Rejuvenation", nil, "player") then return true end
  if ColourCrypter_RD_CheckBuffAndSetAction("Rejuvenation", nil, "Rejuvenation (Germination)", nil, "player") then return true end
  if ColourCrypter_RD_CheckBuffAndSetAction("Regrowth", nil, "Regrowth", nil, "player") then return true end
  if ColourCrypter_RD_CheckSetAction("Ironbark") then return true; end
  if ColourCrypter_RD_CheckSetAction("Flourish") then return true; end
  if ColourCrypter_RD_CheckSetAction("Essence of G'Hanir") then return true; end
  if ColourCrypter_RD_CheckBuffAndSetAction("Lifebloom", nil, "Lifebloom", nil, "player") then return true end
  local unitHealth = (UnitHealth("player")/UnitHealthMax("player"));
  if(unitHealth < 0.95) then
    if ColourCrypter_RD_CheckSetAction("Regrowth") then return true; end
  else
    ColourCrypter_RD_Variables.InReHealMode = false;
  end
  return false;
end


--BearAttack
--Bearform, Thrash, mangel, moonfire, Ironfur, Frenzy regen, Iron Bark
function ColourCrypter_RD_BearAttack()
  if(not UnitAura("player", "Bear Form", nil, "HELPFUL|PLAYER")) then
    if ColourCrypter_RD_CheckSetAction("Bear Form") then return true; end
  else
    if ColourCrypter_RD_CheckSetAction("Thrash") then return true; end
    if ColourCrypter_RD_CheckSetAction("Mangle") then return true; end
    if(ColourCrypter_GetDebuffRemainingTime("target", "Moonfire") < 6) then
      if ColourCrypter_RD_CheckSetAction("Moonfire") then return true; end
    end
    if ColourCrypter_RD_CheckSetAction("Ironfur") then return true; end
    if ColourCrypter_RD_CheckSetAction("Frenzied Regeneration") then return true; end
  end
end

--function ColourCrypter_RD_FeralAffinity_Attack()
--  if(not UnitAura("player", "Cat Form", nil, "HELPFUL|PLAYER")) then
--    if(ColourCrypter_GetDebuffRemainingTime("target", "Moonfire") < 1) then
--      if ColourCrypter_RD_CheckSetAction("Moonfire", nil, ColourCrypter_Variables.Unit_Target) then return true; end
--    end
--    if(ColourCrypter_GetDebuffRemainingTime("target", "Sunfire") < 1) then
--      if ColourCrypter_RD_CheckSetAction("Sunfire", nil, ColourCrypter_Variables.Unit_Target) then return true; end
--    end  
--    if ColourCrypter_RD_CheckSetAction("Cat Form") then return true; end
--  else
--    if(ColourCrypter_GetDebuffRemainingTime("target", "Rake") < 1) then
--      if ColourCrypter_RD_CheckSetAction("Rake", nil, ColourCrypter_Variables.Unit_Target) then return true; end
--    end
--    if(GetComboPoints("player", "target") < 5)then
--      if ColourCrypter_RD_CheckSetAction("Shred", nil, ColourCrypter_Variables.Unit_Target) then return true; end
--      if(ColourCrypter_GetDebuffRemainingTime("target", "Moonfire") < 1) or (ColourCrypter_GetDebuffRemainingTime("target", "Sunfire") < 1) then
--        if ColourCrypter_RD_CheckSetAction("Cat Form") then return true; end
--      end
--    else
--      local healthPer = UnitHealth("target")/UnitHealthMax("target");
--      if(healthPer > 0.25) then
--        if ColourCrypter_RD_CheckSetAction("Rip", nil, ColourCrypter_Variables.Unit_Target) then return true; end
--      elseif(UnitPower("player") > 50) then
--        if ColourCrypter_RD_CheckSetAction("Ferocious Bite", nil, ColourCrypter_Variables.Unit_Target) then return true; end
--      end
--    end
--    
--  end
--  return false;
--end
