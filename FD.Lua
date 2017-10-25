
--

---------------------------------------------------------------------FD.Lua-----------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------FD.Lua-----------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------FD.Lua-----------------------------------------------------------------------------------------------------------------
--
--
-- Globals Section
-- Modifiers Ctrl - 1, alt-2, Shift-4, no repeat - 8, Print - 16


ColourCrypter_FD_Variables =
{
  ReHealMode = false,
  --Left bar
  ["Travel Form"]       = {["Key"] = {["R"] = 1/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Bear Form"]         = {["Key"] = {["R"] = 2/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Moonfire"]          = {["Key"] = {["R"] = 3/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Swipe"]             = {["Key"] = {["R"] = 4/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Thrash"]            = {["Key"] = {["R"] = 5/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Ashamane's Frenzy"] = {["Key"] = {["R"] = 6/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Skull Bash"]        = {["Key"] = {["R"] = 7/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Mighty Bash"]       = {["Key"] = {["R"] = 8/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Maim"]              = {["Key"] = {["R"] = 9/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Remove Corruption"] = {["Key"] = {["R"] =10/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Healing Touch"]     = {["Key"] = {["R"] =11/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Regrowth"]          = {["Key"] = {["R"] =12/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  --Right bar
  ["Cat Form"]          = {["Key"] = {["R"] = 1/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["Rake"]              = {["Key"] = {["R"] = 2/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["Tiger's Fury"]      = {["Key"] = {["R"] = 3/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["Savage Roar"]       = {["Key"] = {["R"] = 4/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["Shred"]             = {["Key"] = {["R"] = 5/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["Rip"]               = {["Key"] = {["R"] = 6/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["Ferocious Bite"]    = {["Key"] = {["R"] = 7/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["Berserk"]           = {["Key"] = {["R"] = 8/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["Survival Instincts"]= {["Key"] = {["R"] = 9/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  --["Renewal"]         = {["Key"] = {["R"] =10/256;["G"] = 0/256;["B"] = (  4)/256;},},
  ["Swiftmend"]         = {["Key"] = {["R"] =11/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["Rejuvenation"]      = {["Key"] = {["R"] =12/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  --
};

--
  --function FeralRotation()
  --if predatory swift apply healing touch
  --If helth below 30% set RehealMode On
  --If ReHealMode Selfheal()
  -- SingleAttack()
  
  --Function Selfheal()
  --  StunTarget()
  --  Apply swift mend, rejov, regrowth
  --  If Health is above 0.8 RehealMode Of
  
    --function StunTarget()
  --If not Mighty Bash, Survival Instinct, Maim on Target
  --  If in catform apply Maim return true
  --  apply Mighty Bash return ture
  --  apply survival insinct return true
  --return false  
  
  --function SingleAttack 
  -- Remove correption
  -- refresh Cat
  -- skull bash
  -- if combo > 0 refresh savage roar
  -- if energy is less than Max energu - 70, apply tiger fury
  -- if svage roar apply rake
  -- if tiger and savage apply ashamane
  -- apply Berserk
  -- if 5 combo
  --    if target is above 25% health, refresh rip
  --    if energy less than 50, do nothing return false
  --    apply furious bite
  -- apply shread

  
function ColourCrypter_FD_TimedUpdate()  
  if(ColourCrypter_FD_CheckIsInActiveCombat()) then
    ColourCrypter_Variables.LootPending = false;
    if (ColourCrypter_FD_FeralRotation()) then return true; end
  end
    ColourCrypter_SetActionDoNothing();
    return false;
end


function ColourCrypter_FD_CheckIsInActiveCombat()
  
  local canAttack = UnitCanAttack("player", "target");
  local inRange = IsCurrentSpell("Auto Attack");
  local inCombat = UnitAffectingCombat("player");
  return (canAttack and inRange and inCombat);
end

function ColourCrypter_FD_FeralRotation()
  if(ColourCrypter_GetBuffRemainingTime("player", "Predatory Swiftness")> 0) then
    if ColourCrypter_FD_CheckSetAction("Regrowth") then return true; end
  end
  local unitHealth = (UnitHealth("player"))/UnitHealthMax("player");
  if(unitHealth < 0.3) then ColourCrypter_FD_Variables.ReHealMode = true;  
  elseif(unitHealth > 0.8) then ColourCrypter_FD_Variables.ReHealMode = false; end
  if(ColourCrypter_FD_Variables.ReHealMode) then 
    if ColourCrypter_FD_Selfheal(unitHealth) then return true; end
  end 
  return ColourCrypter_FD_SingleAttack();
end
    

function ColourCrypter_FD_CheckSetAction(spellName, actionName, target)
  if(not actionName) then actionName = spellName; end
  return ColourCrypter_CheckSetAction(spellName, ColourCrypter_FD_Variables[actionName], target);
end

function ColourCrypter_FD_Selfheal(unitHealth)
  if(ColourCrypter_FD_StunTarget()) then return true; end
  if ColourCrypter_FD_CheckSetAction("Swiftmend") then return true; end
  if(ColourCrypter_GetBuffRemainingTime("player", "Rejuvenation")< 1) then
    if ColourCrypter_FD_CheckSetAction("Rejuvenation") then return true; end
  end
  if ColourCrypter_FD_CheckSetAction("Regrowth") then return true; end
  return false;
end

function ColourCrypter_FD_StunTarget()
  local maimRemaining = ColourCrypter_GetDebuffRemainingTime("target", "Maim");
  local mbRemaining = ColourCrypter_GetDebuffRemainingTime("target", "Mighty Bash");
  local siRemaing = ColourCrypter_GetBuffRemainingTime("player", "Survival Instincts");
  
  if(maimRemaining  <= 0 and mbRemaining <= 0 and siRemaing <= 0) then
    if ColourCrypter_FD_CheckSetAction("Maim") then return true; end
    if ColourCrypter_FD_CheckSetAction("Mighty Bash") then return true; end
    if ColourCrypter_FD_CheckSetAction("Survival Instincts") then return true; end
  end 
  return false 
end


function ColourCrypter_FD_SingleAttack()
  
    if ColourCrypter_RF_Cure_Unit() then return true; end
    if(not UnitAura("player", "Cat Form", nil, "HELPFUL|PLAYER")) then
      if ColourCrypter_FD_CheckSetAction("Cat Form") then return true; end
    else
      if(ColourCrypter_IsTargetIntereptable()) then
        if ColourCrypter_FD_CheckSetAction("Skull Bash") then return true; end
      end
      if ColourCrypter_GetBuffRemainingTime("player", "Savage Roar") < 1 then
        if ColourCrypter_FD_CheckSetAction("Savage Roar") then return true; end
      end
      if(UnitPower("player") <(UnitPowerMax("player")-70)) then
        if ColourCrypter_FD_CheckSetAction("Tiger's Fury") then return true; end
      end
      if ColourCrypter_GetBuffRemainingTime("player", "Savage Roar") > 0 then
        if(ColourCrypter_GetDebuffRemainingTime("target", "Rake") < 1 )then
          if ColourCrypter_FD_CheckSetAction("Rake") then return true; end
        end
        if ColourCrypter_GetBuffRemainingTime("player", "Tiger's Fury") > 0 then
          if ColourCrypter_FD_CheckSetAction("Ashamane's Frenzy") then return true; end
        end
      end
      if ColourCrypter_FD_CheckSetAction("Berserk") then return true; end
      if(GetComboPoints("player", "target") >= 5)then
        if(ColourCrypter_GetDebuffRemainingTime("target", "Rip") < 1 and (UnitHealth("target")/UnitHealthMax("target")) > 0.25) then
          if ColourCrypter_FD_CheckSetAction("Rip") then return true; end
        end
        if(UnitPower("player") < 50) then 
          ColourCrypter_SetActionDoNothing();
          return true;
        else
          if ColourCrypter_FD_CheckSetAction("Ferocious Bite") then return true; end
        end
        return ColourCrypter_FD_CheckSetAction("Ferocious Bite");
      end
      return ColourCrypter_FD_CheckSetAction("Shred");
    end
    return false;
end

function ColourCrypter_RF_Cure_Unit()
  local i = 1;
  local nameExist = true;
  while nameExist do
    local name, rank, icon, count, dispelType, duration, expires =  UnitAura("player", i, "HARMFUL");
    if(dispelType == "Curse" or dispelType == "Poison") then
      if ColourCrypter_FD_CheckSetAction("Remove Corruption") then return true; end
    elseif(not name) then
      nameExist = false;
    end
    i = i + 1;
  end  
  return false;
end

