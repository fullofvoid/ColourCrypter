

-- Globals Section
-- Modifiers Ctrl - 1, alt-2, Shift-4, no repeat - 8, Print - 16
--ColourCrypter_Saved.AnyClass
ColourCrypter_AnyClass_Variable = {
	["DoNothing"] ={
		["Key"] = {
			["R"] = 13/256;
			["G"] = 0/256;
			["B"] = 0/256;
		},
		["SpellName"] = "No Action";
	},
	["Loot"] ={
		["Key"] = {
			["R"] = 1/256;
			["G"] = 0/256;
			["B"] = (1+4)/256;
		},
		["SpellName"] = "Loot";
	}
};

ColourCrypter_Variables =
{
	["AoeAttack"] = false,
	["UpdateInterval"] = 0,
	["ElapsedSinceLastUpdate"] = 0,
	["LootPending"] = false,
	["cryptotext"] = nil,
	["cryptotexture"] = nil,
	["LastActionName"] = "DoNothing",
	["BuffStatus"] = {};
	["DebugMode"] = false,
	Unit_Target = 0,
	Unit_Focus = 6,
	Unit_MouseOver = 7,
	Unit_Player = 1,
	Unit_Party1 = 2, 
	Unit_Party2 = 3,
	Unit_Party3 = 4,
	Unit_Party4 = 5,
	ActionObject = nil,
	ClickTimeBeforeCoolDownFinish = 2,
	CameraZoomIn = false,
	RunAuction = false
};
function ToggleMouseLook()
  if(IsMouselooking()) then
    MouselookStop();
  else
    MouselookStart();
  end
end
   
--  /run PostAllBagsToAuction()
--  /run print(GetContainerNumSlots(0))
function PostAllBagsToAuction()
  for i=0,4 do
    if (PostBagsToAuction(i,true) ) then return true end 
  end
  return false;
end  
function PostBagsToAuction(container, post)
  local numberOfSlots = GetContainerNumSlots(container); 
  for slot = 1,  numberOfSlots do
    local itemID = GetContainerItemID(container, slot);
    if(itemID) then
      if(PostItemToAuction(itemID, container, slot)) then return true; end
    end
  end
  return false;
end
function PostItemToAuction(itemID, container, slot)
  local texture, count, locked, quality, readable, lootable, itemLink, isFiltered, hasNoValue, itemID = GetContainerItemInfo(container, slot);
  if(count > 20)then count=20; end
  --print(itemID);
  local o={}
  TUJMarketInfo(itemID,o)
  local globalMedian = o['globalMedian'];
  
  if(globalMedian ) then
    
    local buyoutPrice = (globalMedian *0.9);
    local minBid = buyoutPrice * 0.5;
    print(itemLink .. o['globalMedian'] .. minBid..buyoutPrice );
    -- Place an item in the auction slot
    PickupContainerItem(container, slot);
    ClickAuctionSellItemButton();
    ClearCursor();
    -- Create 4 auctions of 5 items each for 1g bid, 1g50s buyout, 
    -- with a duration of 48 hours
    StartAuction(minBid, buyoutPrice, 3, count, 1)
    return true;
  end
  return false;
end

function SetMountedCamera()
   if((not ColourCrypter_Variables.CameraZoomIn) and IsFlying())then
    CameraZoomIn(50.0);
    ColourCrypter_Variables.CameraZoomIn = true;
   elseif((ColourCrypter_Variables.CameraZoomIn) and not IsFlying() )then
    CameraZoomOut(8.0);
    ColourCrypter_Variables.CameraZoomIn = false;
   end
end

function ColourCrypter_OnLoad(self) 
	print("Loading ColourCrypter"); 
	ColourCrypter_InitVariables() 
	  --parent frame 
	local frameParent = CreateFrame("Frame", "ColourCrypterFrame", UIParent) 
	frameParent:SetSize(170, 16) 
	frameParent:SetPoint("TOPLEFT") 
	
	
	local frameLeft = CreateFrame("Frame", "ColourCrypterFrameLeft", frameParent) 
	frameLeft:SetSize(20, 16) 
	frameLeft:SetPoint("TOPLEFT", frameParent)
	
	
	local frameRight = CreateFrame("Frame", "ColourCrypterFrameRight", frameParent) 
	frameRight:SetSize(150, 16) 
	frameRight:SetAllPoints()
	frameRight:SetPoint("TOPLEFT", frameParent, "TOPLEFT", 20, 0)
	
	frameRight.text = frameRight:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	frameRight.text:SetAllPoints();
	frameRight.text:SetText("Action");
	ColourCrypter_Variables.cryptotext = frameRight.text;
	
	
	ColourCrypter_Variables.cryptotexture = frameLeft:CreateTexture()
	ColourCrypter_Variables.cryptotexture:SetAllPoints() 
	ColourCrypter_Variables.cryptotexture:SetColorTexture(1,1,1) 
	frameLeft.background = ColourCrypter_Variables.cryptotexture
	
	frameParent:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	frameParent:RegisterEvent("PLAYER_LEAVE_COMBAT");
	frameParent:RegisterEvent("UI_ERROR_MESSAGE");
	frameParent:RegisterEvent("LOOT_OPENED");
	frameParent:SetScript("OnEvent", ColourCrypter_HandleEvents);
end



function ColourCrypter_HandleEvents(self, event, ...)

	-- local player = UnitGUID("player")
  
	--if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		--local timestamp, type, hideCaster,                                                                      -- arg1  to arg3
		--  sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags,   -- arg4  to arg11
		--  spellId, spellName, spellSchool,                                                                      -- arg12 to arg14
		--  amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...             -- arg15 to arg23
		  --print("spellId:"..tostring(spellId).." spellName:"..tostring(spellName).." spellSchool:"..tostring(spellSchool)  );

	--elseif (event == "PLAYER_ENTER_COMBAT") then
		--print("Swinging ")	
	--elseif (event == "PLAYER_LEAVE_COMBAT") then
		--print("Stop Swinging ")
	if (event == "UI_ERROR_MESSAGE") then
		local message = ...
		if(message ==50 or message ==54) then
			ColourCrypter_Variables.LootPending = false;
		elseif(ColourCrypter_Variables.DebugMode) then
			print ("Last action:"..ColourCrypter_Variables.LastActionName..", Message:"..message);
		end
	elseif (event =="LOOT_OPENED") then
		ColourCrypter_Variables.LootPending = false;
  end
end

function ColourCrypter_InitVariables() 
	ColourCrypter_Variables.UpdateInterval = 0.05;
	ColourCrypter_Variables.ElapsedSinceLastUpdate = 0;
	ColourCrypter_Variables.LootPending = false;
	ColourCrypter_Variables.AoeAttack = false;
end

-- Functions Section
function ColourCrypter_OnUpdate(self, elapsed)
	ColourCrypter_Variables.ElapsedSinceLastUpdate = ColourCrypter_Variables.ElapsedSinceLastUpdate + elapsed; 	

	--if (ColourCrypter_Variables.ElapsedSinceLastUpdate > ColourCrypter_Variables.UpdateInterval) then
	ColourCrypter_TimedUpdate(elapsed)
	--	ColourCrypter_Variables.ElapsedSinceLastUpdate = 0;		
	
	--end
end


function ColourCrypter_TimedUpdate(elapsed)
  --if(ColourCrypter_Variables.RunAuction) then 
  --  PostAllBagsToAuction();
  --  return;
  --end
	-- start, duration, enable =  GetSpellCooldown("Auto Attack")
	-- print("start:"..start..", duration:"..duration..", enable:"..enable)
	-- start, duration, enable =  GetSpellCooldown("Auto Shot")
	-- print("start:"..start..", duration:"..duration..", enable:"..enable)
	-- start, duration, enable =  GetSpellCooldown("Attack")
	-- -- print("start:"..(start or "")..", duration:"..(duration or "")..", enable:"..(enable or ""))
	--isCurrent = IsCurrentSpell("Auto Shot")
	SetMountedCamera();
	if(ColourCrypter_Variables.RunAuction) then
	 if(not PostAllBagsToAuction()) then
	   ColourCrypter_Variables.RunAuction = false;
	 end
	end
	local name = UnitCastingInfo("player");
	if(name) then 
		ColourCrypter_Variables.cryptotext:SetText("Casting "..name);
		ColourCrypter_SetActionDoNothing();
		return;
	end
	local name = UnitChannelInfo("player");
	if(name) then 
		ColourCrypter_Variables.cryptotext:SetText("Channeling "..name);
		ColourCrypter_SetActionDoNothing();
		return;
	end
	
	local specId = GetSpecializationInfo(GetSpecialization());
	if specId == 581 then 
		ColourCrypter_VDH_TimedUpdate();
	elseif specId == 253 then 
		 ColourCrypter_BM_TimedUpdate();
	--elseif specId == 254 then 
		-- ColourCrypter_MM_TimedUpdate();
	elseif specId == 102 then
		 --Balance
		 ColourCrypter_BD_TimedUpdate();
	-- elseif specId == 103 then
		-- --Feral
		-- ColourCrypter_FD_TimedUpdate();
	-- elseif specId == 104 then
		-- --Gardian
	-- elseif specId == 105 then
		-- --Restro
		-- ColourCrypter_RD_TimedUpdate();
	end
end

function ColourCrypter_GetBuffRemainingTime(unit, buff)
  return ColourCrypter_GetAuraRemainingTime(unit, buff, "HELPFUL|PLAYER");
end 

function ColourCrypter_GetDebuffRemainingTime(unit, buff)
  return ColourCrypter_GetAuraRemainingTime(unit, buff, "HARMFUL|PLAYER");
end 
 
function ColourCrypter_GetAuraRemainingTime(unit, buff, filter)
    if(buff) then
      local name, rank, icon, count, dispelType, duration, expires =  UnitAura(unit, buff, nil, filter);
      --print("unit:"..unit..", buff:"..buff..", remainingTime:"..(expires - GetTime()));
      local remainingTime = 0;
      if(expires) then
        remainingTime = expires - GetTime();
      end
      return remainingTime;
    else
      return 0;
     end
end 


function ColourCrypter_IsTargetIntereptable()
	local name, subText, text, texture, startTime, endTime, isTradeSkill, castID, uninterruptible = UnitCastingInfo("target");
	if(name)then
  	if(uninterruptible == nil or uninterruptible == false ) then 
  	   return true, true; 
  	end
  	return false, true;
	end
	local name2, subText2, text2, texture2, startTime2, endTime2, isTradeSkill2, uninterruptible2 = UnitChannelInfo("target");
	if(name2)then
  	if(uninterruptible2 == nil or uninterruptible2 == false) then  
  	   return true, true; 
  	end
  	return false, true;
	end
	return false, false; 
end

--unit: target, focus, player, party1, party2, party3, party4, mouseover
function ColourCrypter_IsSpellReady(spell, unit)
	local start, duration, enable = GetSpellCooldown(spell);
	if(not duration) then duration = 0; end;
	if(duration > ColourCrypter_Variables.ClickTimeBeforeCoolDownFinish) then return false; end
	if(unit) then if( not IsSpellInRange(spell, unit)) then return false; end end
	local isUsable, notEnoughMana = IsUsableSpell(spell);
	return (isUsable and (not notEnoughMana));
end

function ColourCrypter_SetActionDoNothing()
		ColourCrypter_Variables.cryptotexture:SetColorTexture(ColourCrypter_AnyClass_Variable.DoNothing.Key.R,
			ColourCrypter_AnyClass_Variable.DoNothing.Key.G,
			ColourCrypter_AnyClass_Variable.DoNothing.Key.B);
		ColourCrypter_Variables.cryptotext:SetText("Last action:"..ColourCrypter_Variables.LastActionName);
end

--unit: target, focus, player, party1, party2, party3, party4, mouseover
function ColourCrypter_SetAction(name, action, unit)
    local target target = 0; 
    if    (unit == "target") then target =  ColourCrypter_Variables.Unit_Target;
    elseif(unit == "focus")  then target =  ColourCrypter_Variables.Unit_Focus;
    elseif(unit == "player") then target =  ColourCrypter_Variables.Unit_Player;
    elseif(unit == "party1") then target =  ColourCrypter_Variables.Unit_Party1;
    elseif(unit == "party2") then target =  ColourCrypter_Variables.Unit_Party2;
    elseif(unit == "party3") then target =  ColourCrypter_Variables.Unit_Party3;
    elseif(unit == "party4") then target =  ColourCrypter_Variables.Unit_Party4;
    elseif(unit == "mouseover") then target =  ColourCrypter_Variables.Unit_MouseOver;
    end
		ColourCrypter_Variables.cryptotexture:SetColorTexture(action.Key.R,(target/256),action.Key.B);
		ColourCrypter_Variables.cryptotext:SetText(name);
		ColourCrypter_Variables.LastActionName = name;
end
--ColourCrypter_CheckSetAction(spell, action, unit, auraToAvoid, auraToAvoidOnUnit, auraFilter)
--unit: target, focus, player, party1, party2, party3, party4, mouseover
--auraFilter: HELPFUL(default), HARMFUL
function ColourCrypter_CheckSetAction(spell, action, unit, auraToAvoid, auraToAvoidOnUnit, auraFilter)
  if(not action) then action = spell; end;
  if(not auraFilter) then auraFilter = "HELPFUL"; end
  if(auraToAvoid) then
    if(not auraToAvoidOnUnit) then auraToAvoidOnUnit = "player" end
    if(ColourCrypter_GetAuraRemainingTime(auraToAvoidOnUnit, auraToAvoid, auraFilter) > ColourCrypter_Variables.ClickTimeBeforeCoolDownFinish) then return false; end
  end
  local ready = ColourCrypter_IsSpellReady(spell, unit);
  if(ready) then
     ColourCrypter_SetAction(spell, ColourCrypter_Variables.ActionObject[action], unit);
  end
  return ready;
end

function usage()
	SetCVar("scriptProfile", 1);
	UpdateAddOnCPUUsage();
	local addonCount =  GetNumAddOns();
	local i = 1
	while ( i<= addonCount) do
		local usage = GetAddOnCPUUsage(i);
		if(usage > 0) then
			local name = GetAddOnInfo(i);
			print (name..": "..usage);
		end
		i = i+1;
	end
end

function debugmode()
	ColourCrypter_Variables.DebugMode = (not ColourCrypter_Variables.DebugMode);
	if(ColourCrypter_Variables.DebugMode) then
		print("DebugMode on:");
		
		-- for actionKey, action in pairs(ColourCrypter_MM_Variables) do
			-- if type(action) == "table" then
				-- local spellName = action["SpellName"];
				-- local name, rank, icon, castingTime, minRange, maxRange, spellID = GetSpellInfo(spellName);
				-- local spellIDs = action["SpellID"]
				-- print(tostring(actionKey), ": ", tostring(spellID),": ", tostring(spellIDs))

			-- end
		-- end				
	else
		print("DebugMode off:");
	end
end
	
function spell(spellName)
	local name, rank, icon, castingTime, minRange, maxRange, spellID = GetSpellInfo(spellName);
	print(name..":"..spellID);
end
function printSpec()
  print(GetSpecializationInfo(GetSpecialization()));
end
function boo()
	local i = 1
	local nameExist = true;
	while (nameExist) do
		 local name, rank, icon, count =  UnitAura("player", i, "HELPFUL|PLAYER");
		 print(tostring(name)..":"..tostring(rank)..":"..tostring(count));
		 i = i + 1;
		 nameExist = (name ~= nil)
	end
end



---------------------------------------------------------------------VDH.Lua-----------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------VDH.Lua-----------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------VDH.Lua-----------------------------------------------------------------------------------------------------------------


ColourCrypter_VDH_Variables =
{
-- ColourCrypter_Variables.AoeAttack

  --Left bar
  ["Soul Carver"]       	= {["Key"] = {["R"] = 1/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Fiery Brand"]       	= {["Key"] = {["R"] = 2/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Immolation Aura"]     = {["Key"] = {["R"] = 3/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Sigil of Flame"]      = {["Key"] = {["R"] = 4/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Shear"]       				= {["Key"] = {["R"] = 5/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Throw Glaive"]       	= {["Key"] = {["R"] = 6/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Felblade"]       			= {["Key"] = {["R"] = 7/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["8"]       						= {["Key"] = {["R"] = 8/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["9"]       						= {["Key"] = {["R"] = 9/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["10"]	 								= {["Key"] = {["R"] =10/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Sigil of Silence"]    = {["Key"] = {["R"] =11/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Consume Magic"]       = {["Key"] = {["R"] =12/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  --Right bar
  ["Demon Spikes"]       	= {["Key"] = {["R"] = 1/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["Soul Cleave"]       	= {["Key"] = {["R"] = 2/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["Metamorphosis"]       = {["Key"] = {["R"] = 3/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["4"]       						= {["Key"] = {["R"] = 4/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["5"]       						= {["Key"] = {["R"] = 5/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["6"]       						= {["Key"] = {["R"] = 6/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["7"]       						= {["Key"] = {["R"] = 7/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["8"]       						= {["Key"] = {["R"] = 8/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["9"]		 								= {["Key"] = {["R"] = 9/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["10"]       						= {["Key"] = {["R"] =10/256;["G"] = 0/256;["B"] = (  4)/256;},},
  ["11"]       						= {["Key"] = {["R"] =11/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["Empower Wards"]				= {["Key"] = {["R"] =12/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  --
};


function ColourCrypter_VDH_TimedUpdate()
  ColourCrypter_Variables.ActionObject = ColourCrypter_VDH_Variables;
  if(ColourCrypter_VDH_CheckIsInActiveCombat()) then
    ColourCrypter_Variables.LootPending = false;
    if (ColourCrypter_VDH_Attack()) then return true; end
  end
    ColourCrypter_SetActionDoNothing();
    return false;
end


function ColourCrypter_VDH_CheckIsInActiveCombat()
  
  local canAttack = UnitCanAttack("player", "target");
  local inRange = IsCurrentSpell("Auto Attack");
  local inCombat = UnitAffectingCombat("player");
  return (canAttack and inRange and inCombat);
end


--ColourCrypter_CheckSetAction(spell, action, unit, auraToAvoid, auraToAvoidOnUnit, auraFilter)
--unit: target, focus, player, party1, party2, party3, party4, mouseover
--auraFilter: HELPFUL(default), HARMFUL

function ColourCrypter_VDH_Attack()
  local interabtable, casting = ColourCrypter_IsTargetIntereptable();
  
  if (casting) then
    if (interabtable) then
      if ColourCrypter_CheckSetAction("Consume Magic", nil, "target") then return true; end
      if ColourCrypter_CheckSetAction("Sigil of Silence", nil, nil, "Empower Wards", "player") then return true; end
    else
      if ColourCrypter_CheckSetAction("Empower Wards") then return true; end
    end
  end
  local unitHealth = (UnitHealth("player"))/UnitHealthMax("player");
  --if(unitHealth < 0.9)then
    if ColourCrypter_CheckSetAction("Demon Spikes", nil, nil, "Demon Spikes") then return true; end
  --end
  if(unitHealth < 0.3)then
    if ColourCrypter_CheckSetAction("Metamorphosis") then return true; end
  end
  local  unitPower = UnitPower("player");
  if(unitPower > 60) then
    if ColourCrypter_CheckSetAction("Soul Cleave") then return true; end
  end
  if ColourCrypter_CheckSetAction("Soul Carver", nil, "target") then return true; end 
  if ColourCrypter_CheckSetAction("Fiery Brand", nil, "target") then return true; end 
  if ColourCrypter_CheckSetAction("Immolation Aura") then return true; end 
  if ColourCrypter_CheckSetAction("Sigil of Flame") then return true; end 
  if(ColourCrypter_Variables.AoeAttack) then
    if ColourCrypter_CheckSetAction("Throw Glaive", nil, "target") then return true; end
  end 
  if ColourCrypter_CheckSetAction("Felblade", nil, "target") then return true; end
  return ColourCrypter_CheckSetAction("Shear", nil, "target");
end



---------------------------------------------------------------------BM.Lua-----------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------BM.Lua-----------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------BM.Lua-----------------------------------------------------------------------------------------------------------------


ColourCrypter_BM_Variables =
{
-- ColourCrypter_Variables.AoeAttack

  --Left bar
  ["Aspect of the Wild"]  = {["Key"] = {["R"] = 1/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Kill Command"]        = {["Key"] = {["R"] = 2/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Dire Beast"]          = {["Key"] = {["R"] = 3/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Counter Shot"]        = {["Key"] = {["R"] = 4/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Exhilaration"]        = {["Key"] = {["R"] = 5/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["6"]                   = {["Key"] = {["R"] = 6/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["7"]                   = {["Key"] = {["R"] = 7/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["8"]                   = {["Key"] = {["R"] = 8/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["9"]                   = {["Key"] = {["R"] = 9/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["10"]                  = {["Key"] = {["R"] =10/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["11"]                  = {["Key"] = {["R"] =11/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["12"]                  = {["Key"] = {["R"] =12/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  --Right bar
  ["Bestial Wrath"]       = {["Key"] = {["R"] = 1/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["Mend Pet"]            = {["Key"] = {["R"] = 2/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["Cobra Shot"]          = {["Key"] = {["R"] = 3/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["Multi-Shot"]          = {["Key"] = {["R"] = 4/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["Fetch"]               = {["Key"] = {["R"] = 5/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["6"]                   = {["Key"] = {["R"] = 6/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["7"]                   = {["Key"] = {["R"] = 7/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["8"]                   = {["Key"] = {["R"] = 8/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["9"]                   = {["Key"] = {["R"] = 9/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["10"]                  = {["Key"] = {["R"] =10/256;["G"] = 0/256;["B"] = (  4)/256;},},
  ["11"]                  = {["Key"] = {["R"] =11/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["12"]                  = {["Key"] = {["R"] =12/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  --
};


function ColourCrypter_BM_TimedUpdate()
  ColourCrypter_Variables.ActionObject = ColourCrypter_BM_Variables;
  if(ColourCrypter_BM_CheckIsInActiveCombat()) then
    ColourCrypter_Variables.LootPending = true;
    if (ColourCrypter_BM_Attack()) then return true; end
  end
  
  if(not UnitAffectingCombat("player") and ColourCrypter_Variables.LootPending) then
    ColourCrypter_CheckSetAction("Fetch") ; 
    return true;
  end
  ColourCrypter_SetActionDoNothing();
  return false;
end


function ColourCrypter_BM_CheckIsInActiveCombat()
  
  local canAttack = UnitCanAttack("player", "target");
   local inCombat = UnitAffectingCombat("player");
  return (canAttack and inCombat);
end


--ColourCrypter_CheckSetAction(spell, action, unit, auraToAvoid, auraToAvoidOnUnit, auraFilter)
--unit: target, focus, player, party1, party2, party3, party4, mouseover
--auraFilter: HELPFUL(default), HARMFUL

function ColourCrypter_BM_Attack()
  local interabtable, casting = ColourCrypter_IsTargetIntereptable();
  if (interabtable) then
    if ColourCrypter_CheckSetAction("Counter Shot", nil, "target") then return true; end
  end
  
  local unitHealth = (UnitHealth("player"))/UnitHealthMax("player");
  if(unitHealth < 0.6)then
    if ColourCrypter_CheckSetAction("Exhilaration") then return true; end
  end
  local petHealth = (UnitHealth("pet"))/UnitHealthMax("pet");
  if(unitHealth < 0.99)then
    if ColourCrypter_CheckSetAction("Mend Pet") then return true; end
  end
  
  if ColourCrypter_CheckSetAction("Dire Beast", nil, "target") then return true; end
  if ColourCrypter_CheckSetAction("Aspect of the Wild") then return true; end
  if ColourCrypter_CheckSetAction("Bestial Wrath") then return true; end
  
  
  local start, duration, enable = GetSpellCooldown("Bestial Wrath");
  if(not duration) then duration = 1000; end;
  if(duration <5) then 
    ColourCrypter_SetActionDoNothing();
    return true; 
  end
  if ColourCrypter_CheckSetAction("Kill Command", nil, "target") then return true; end
  if ColourCrypter_CheckSetAction("Cobra Shot", nil, "target") then return true; end 
  
  ColourCrypter_SetActionDoNothing();
  return true;
end



---------------------------------------------------------------------BD.Lua-----------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------BD.Lua-----------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------BD.Lua-----------------------------------------------------------------------------------------------------------------



-- Globals Section
-- Modifiers Ctrl - 1, alt-2, Shift-4, no repeat - 8, Print - 16


ColourCrypter_BD_Variables =
{
  --Left bar
  ["Moonkin Form"]      = {["Key"] = {["R"] = 1/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Travel Form"]       = {["Key"] = {["R"] = 2/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Starsurge"]         = {["Key"] = {["R"] = 3/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Starfall"]          = {["Key"] = {["R"] = 4/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Astral Communion"]  = {["Key"] = {["R"] = 5/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Celestial Alignment"]= {["Key"] = {["R"] = 6/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Stellar Flare"]     = {["Key"] = {["R"] = 7/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Solar Beam"]        = {["Key"] = {["R"] = 9/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Remove Corruption"] = {["Key"] = {["R"] =10/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  ["Healing Touch"]     = {["Key"] = {["R"] =11/256;["G"] = 0/256;["B"] = (4+2)/256;},},
  --Right bar
  ["Sunfire"]           = {["Key"] = {["R"] = 1/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["Moonfire"]          = {["Key"] = {["R"] = 2/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["Solar Wrath"]       = {["Key"] = {["R"] = 3/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["Lunar Strike"]      = {["Key"] = {["R"] = 4/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["New Moon"]          = {["Key"] = {["R"] = 5/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  --["Shred"]           = {["Key"] = {["R"] = 5/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  --["Rip"]             = {["Key"] = {["R"] = 6/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  --["Ferocious Bite"]  = {["Key"] = {["R"] = 7/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  --["Berserk"]         = {["Key"] = {["R"] = 8/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["Barkskin"]          = {["Key"] = {["R"] = 9/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["Renewal"]           = {["Key"] = {["R"] =10/256;["G"] = 0/256;["B"] = (  4)/256;},},
  ["Swiftmend"]         = {["Key"] = {["R"] =11/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  ["Rejuvenation"]      = {["Key"] = {["R"] =12/256;["G"] = 0/256;["B"] = (1+4)/256;},},
  
  ["DotMinHealth"] = 400000;
  --
};


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

  ColourCrypter_Variables.ActionObject = ColourCrypter_BD_Variables;
  ColourCrypter_BD_ScanBuffs();
  ColourCrypter_BD_ScanTargetDeBuffs();
  
  if(ColourCrypter_BD_CheckIsInActiveCombat()) then
    ColourCrypter_Variables.LootPending = false;
    ColourCrypter_BD_Attack();
  else
    --if(ColourCrypter_Variables.LootPending) then
    --  ColourCrypter_SetAction(ColourCrypter_AnyClass_Variable.Loot);
    if(not ColourCrypter_Variables.BuffStatus.TravelForm 
      and not ColourCrypter_Variables.BuffStatus.Prowl
      and IsOutdoors() --IsFlyableArea()
      and not  UnitAffectingCombat("player")) then
      if ColourCrypter_CheckSetAction("Travel Form") then return; end
      else 
        ColourCrypter_SetActionDoNothing();
      end
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
  local interabtable, casting = ColourCrypter_IsTargetIntereptable();
  if (interabtable) then
    if ColourCrypter_CheckSetAction("Solar Beam") then return true; end
  end
  if(ColourCrypter_Variables.BuffStatus.CursePoison) then
    if ColourCrypter_CheckSetAction("Remove Corruption") then return true; end
  end
  if (UnitHealth("player")/UnitHealthMax("player")) < 0.70 then
    if ColourCrypter_CheckSetAction("Barkskin") then return true; end
    if(not ColourCrypter_Variables.BuffStatus.Rejuvenation) then 
      if ColourCrypter_CheckSetAction("Rejuvenation") then return true; end
    end
    if ColourCrypter_CheckSetAction("Swiftmend") then return true; end
    if ColourCrypter_CheckSetAction("Renewal") then return true; end
  end
  if(not ColourCrypter_Variables.BuffStatus.MoonkinForm) then
    if ColourCrypter_CheckSetAction("Moonkin Form") then return true; end
  end
  return false;
end

--ColourCrypter_CheckSetAction(spell, action, unit, auraToAvoid, auraToAvoidOnUnit, auraFilter)
--unit: target, focus, player, party1, party2, party3, party4, mouseover
--auraFilter: HELPFUL(default), HARMFUL
function ColourCrypter_BD_AttackAoe()
  if ColourCrypter_CheckSetAction("Celestial Alignment") then return true; end
  local  unitPower = UnitPower("player");
  if( unitPower < 25) then
    if ColourCrypter_CheckSetAction("Astral Communion") then return true; end
  end
  --dump astral power
  if ColourCrypter_CheckSetAction("Stellar Flare", nil, "target", "Stellar Flare", "target", "HARMFUL") then return true; end
  if(ColourCrypter_Variables.BuffStatus.LunarEmpowerment  < 3 and ColourCrypter_Variables.BuffStatus.SolarEmpowerment  < 3) then
    if ColourCrypter_CheckSetAction("Starsurge", nil, "target") then return true; end
  end
  if(unitPower > 90)then
    if ColourCrypter_CheckSetAction("Starfall") then return true; end
  end
  --Generate astral power
  if ColourCrypter_CheckSetAction("Moonfire", nil, "target", "Moonfire", "target","HARMFUL" ) then return true; end
  if ColourCrypter_CheckSetAction("Sunfire", nil, "target", "Sunfire", "target", "HARMFUL") then return true; end
  if ColourCrypter_CheckSetAction("New Moon", nil, "target") then return true; end;
  if(ColourCrypter_Variables.BuffStatus.LunarEmpowerment > 0) then 
    if ColourCrypter_CheckSetAction("Lunar Strike", nil, "target") then return true; end
  end
  if(ColourCrypter_Variables.BuffStatus.SolarEmpowerment > 0 ) then
    if ColourCrypter_CheckSetAction("Solar Wrath", nil, "target") then return true; end
  end
  if ColourCrypter_CheckSetAction("Lunar Strike", nil, "target") then return true; end
  ColourCrypter_SetActionDoNothing();
end

--ColourCrypter_CheckSetAction(spell, action, unit, auraToAvoid, auraToAvoidOnUnit, auraFilter)
--unit: target, focus, player, party1, party2, party3, party4, mouseover
--auraFilter: HELPFUL(default), HARMFUL
function ColourCrypter_BD_AttackSingle()
  if ColourCrypter_CheckSetAction("Celestial Alignment") then return true; end
  local  unitPower = UnitPower("player");
  if( unitPower < 25) then
    if ColourCrypter_CheckSetAction("Astral Communion") then return true; end
  end
  --dump astral power
  if ColourCrypter_CheckSetAction("Stellar Flare", nil, "target", "Stellar Flare", "target", "HARMFUL") then return true; end
  if(ColourCrypter_Variables.BuffStatus.LunarEmpowerment  < 3 and ColourCrypter_Variables.BuffStatus.SolarEmpowerment  < 3) then
    if ColourCrypter_CheckSetAction("Starsurge", nil, "target") then return true; end
  end
  if(unitPower > 90)then
    if ColourCrypter_CheckSetAction("Starfall") then return true; end
  end
  
  --Generate astral power
  if ColourCrypter_CheckSetAction("Moonfire", nil, "target", "Moonfire", "target","HARMFUL" ) then return true; end
  if ColourCrypter_CheckSetAction("Sunfire", nil, "target", "Sunfire", "target", "HARMFUL") then return true; end
  if ColourCrypter_CheckSetAction("New Moon", nil, "target") then return true; end;
  if(ColourCrypter_Variables.BuffStatus.SolarEmpowerment > 0 ) then
    if ColourCrypter_CheckSetAction("Solar Wrath", nil, "target") then return true; end
  end
  if(ColourCrypter_Variables.BuffStatus.LunarEmpowerment > 0) then 
    if ColourCrypter_CheckSetAction("Lunar Strike", nil, "target") then return true; end
  end
  if ColourCrypter_CheckSetAction("Solar Wrath") then return true; end
  ColourCrypter_SetActionDoNothing();
end



