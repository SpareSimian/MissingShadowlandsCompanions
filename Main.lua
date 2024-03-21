local addonName, addon = ...
LibStub('AceAddon-3.0'):NewAddon(addon, addonName, 'AceConsole-3.0')

-- TODO:
-- Watch for "GARRISON_FOLLOWER_ADDED" event to remove elements from missing list as they're acquired. (now testing)

-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- sources
-- Data from https://docs.google.com/spreadsheets/d/16etPtUTrVxiNl50iNHvi-Sqs6-goOPOjf2kVp8hZeJM/edit#gid=0

local KyrianSoulbinds = { 
   ["Pelagos"] = 1,
   ["Kleia"] = 2,
   ["Mikanikos"] = 3,
}
local NecrolordSoulbinds = { 
   ["Plague Deviser Marileth"] = 1,
   ["Emeni"] = 2,
   ["Bonesmith Heirmir"] = 3,
}
local NightFaeSoulbinds = { 
   ["Niya"] = 1,
   ["Dreamweaver"] = 2,
   ["Hunt-Captain Korayn"] = 3,
}
local VenthyrSoulbinds = { 
   ["Nadjia the Mistblade"] = 1,
   ["Theotar"] = 2,
   ["General Draven"] = 3,
}
local Soulbinds = { 
   [Enum.CovenantType.Kyrian] = KyrianSoulbinds,
   [Enum.CovenantType.Venthyr] = VenthyrSoulbinds,
   [Enum.CovenantType.NightFae] = NightFaeSoulbinds,
   [Enum.CovenantType.Necrolord] = NecrolordSoulbinds,
}

-- for Renown, value is renown level at which companion is acquired
local KyrianRenownCompanions = {
   ["Pelodis"] = 4,
   ["Sika"] = 12,
   ["Clora"] = 17,
   ["Apolon"] = 27,
   ["Bron"] = 33,
   ["Disciple Kosmas"] = 38,
   ["Hermestes"] = 44,
   ["Cromas the Mystic"] = 62,
   ["Auric Spiritguide"] = 71,
}
local NecrolordRenownCompanions = {
   ["Secutor Mevix"] = 4,
   ["Gunn Gorgebone"] = 12,
   ["Rencissa the Dynamo"] = 17,
   ["Khaliiq"] = 27,
   ["Plaguey"] = 33,
   ["Rathan"] = 38,
   ["Lyra Hailstorm"] = 44,
   ["Enceladus"] = 62,
   ["Deathfang"] = 71,
}
local NightFaeRenownCompanions = {
   ["Guardian Kota"] = 4,
   ["Te'zan"] = 12,
   ["Master Sha'lor"] = 17,
   ["Qadarin"] = 27,
   ["Watcher Vesperbloom"] = 33,
   ["Groonoomcrooek"] = 38,
   ["Sulanoom"] = 44,
   ["Elwyn"] = 62,
   ["Yanlar"] = 71,
}
local VenthyrRenownCompanions = {
   ["Rahel"] = 4,
   ["Stonehead"] = 12,
   ["Simone"] = 17,
   ["Lost Sybille"] = 27,
   ["Vulca"] = 33,
   ["Bogdan"] = 38,
   ["Chachi the Artiste"] = 44,
   ["Madame Iza"] = 62,
   ["Lucia"] = 71,
}
local RenownCompanions = {
   [Enum.CovenantType.Kyrian] = KyrianRenownCompanions,
   [Enum.CovenantType.Venthyr] = VenthyrRenownCompanions,
   [Enum.CovenantType.NightFae] = NightFaeRenownCompanions,
   [Enum.CovenantType.Necrolord] = NecrolordRenownCompanions,
}

-- for Torghast, argument is first layer they can appear on
local KyrianTorghastCompanions = {
   ["Kythekios"] = 2,
   ["Teliah"] = 3,
   ["Telethakas"] = 3,
   ["Molako"] = 1,
   ["Hala"] = 1,
   ["Ispiron"] = 1,
   ["ELGU - 007"] = 1,
   ["Kiaranyka"] = 1,
}
local NecrolordTorghastCompanions = {
   ["Gorgelimb"] = 2,
   ["Talethi"] = 3,
   ["Velkein"] = 3,
   ["Ashraka"] = 1,
   ["Assembler Xertora"] = 1,
   ["Rattlebag"] = 1,
   ["Ryuja Shockfist"] = 1,
   ["Kinessa the Absorbent"] = 1,
}
local NightFaeTorghastCompanions = {
   ["Yira'lya"] = 2,
   ["Chalkyth"] = 3,
   ["Blisswing"] = 3,
   ["Karynmwylyann"] = 1,
   ["Lloth'wellyn"] = 1,
   ["Duskleaf"] = 1,
   ["Ella"] = 1,
   ["Spore of Marasmius"] = 1,
}
local VenthyrTorghastCompanions = {
   ["Kaletar"] = 2,
   ["Ayeleth"] = 3,
   ["Dug Gravewell"] = 3,
   ["Thela Soulsipper"] = 1,
   ["Stonehuck"] = 1,
   ["Nerith Darkwing"] = 1,
   ["Steadyhands"] = 1,
   ["Lassik Spinebender"] = 1,
}
local NoneTorghastCompanions = {
   ["Meatball"] = 4,
   ["Croman"] = 4,
}
local TorghastCompanions = {
   [Enum.CovenantType.None] = NoneTorghastCompanions,
   [Enum.CovenantType.Kyrian] = KyrianTorghastCompanions,
   [Enum.CovenantType.Venthyr] = VenthyrTorghastCompanions,
   [Enum.CovenantType.NightFae] = NightFaeTorghastCompanions,
   [Enum.CovenantType.Necrolord] = NecrolordTorghastCompanions,
}

-- end of follower source data
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

local function copyTable(orig)
   local copy = {}
   for orig_key, orig_value in pairs(orig) do
      copy[orig_key] = orig_value
   end
   return copy
end

local function isNotInCompanionList(companion, t)
   for covenant, companionList in pairs(t) do
      for listCompanion, source in pairs(companionList) do
         return false
      end
   end
   return true
end

local function tablelength(T)
   local count = 0
   for _ in pairs(T) do count = count + 1 end
   return count
end

local playerNameKey -- "name - realm" used as key in persistent data
local missingKey = "missing"
local minimapButtonCreated = false

local function createMinimapButton()
   local prettyName = "Missing Shadowlands Companions"
   local miniButton = LibStub("LibDataBroker-1.1"):NewDataObject(addonName, {
      type = "data source",
      text = prettyName,
      icon = "Interface\\Icons\\sanctum_features_missiontable",
      OnClick = function(self, btn)
         mslcDisplayMissing()
      end,
      OnTooltipShow = function(tooltip)
         if not tooltip or not tooltip.AddLine then return end
         tooltip:AddLine(prettyName)
      end,
   })
   local icon = LibStub("LibDBIcon-1.0", true)
   icon:Register(addonName, miniButton, mslcDB)
   minimapButtonCreated = true
end

-- initialize can be called at any event, in case player gained her first follower

local function initialize()
   -- if no covenant or no followers, skip further processing
   if 0 == C_Covenants.GetActiveCovenantID() then return false end
   local followers = C_Garrison.GetFollowers(Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower)
   if not followers then return false end
   if 0 == tablelength(followers) then return false end

   -- init all our data structures
   if not playerNameKey then
      local name, realm = UnitFullName("player")
      playerNameKey = name .. " - " .. realm
   end
   if not mslcDB then
      mslcDB = {}
   end
   if not mslcDB[playerNameKey] then
      mslcDB[playerNameKey] = {}
   end
   if not mslcDB[playerNameKey][missingKey] then
      mslcDB[playerNameKey][missingKey] = {}
   end
   if not mslcDB["CovenantCompanionsToID"] then
      mslcDB["CovenantCompanionsToID"] = {}
   end
   if not minimapButtonCreated then createMinimapButton() end
   return true -- success
end

local function logInitializeFailure()
   addon:Print("initialize returned false!")
   local followers = C_Garrison.GetFollowers(Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower)
   addon:Print("covenant " .. tostring(C_Covenants.GetActiveCovenantID()))
   if followers then
      addon:Print("follower count " .. tostring(tablelength(followers)))
   end
end

local function addMissing(companionName, source)
   if not initialize() then return end
   mslcDB[playerNameKey][missingKey][companionName] = source
end

local function displayMissing()
   if not initialize() then return end
   local count = 0
   for companion, source in pairs(mslcDB[playerNameKey][missingKey]) do
      addon:Print(companion .. ": " .. source)
      count = count + 1
   end
   if count > 0 then
      addon:Print("Type /mslc to re-display the list.")
   end
end

-- hack to let minimap button reference this
mslcDisplayMissing = displayMissing

local function findMissing()
   if not initialize() then return end
   -- build list of possible companions
   local covenant = C_Covenants.GetActiveCovenantID()
   local missing = {}
   for name, rank in pairs(Soulbinds[covenant]) do
      missing[name] = "(Soulbind " .. tostring(rank) .. ")"
   end
   for name, renown in pairs(RenownCompanions[covenant]) do
      missing[name] = "(Renown " .. tostring(renown) .. ")"
   end
   for name, layer in pairs(TorghastCompanions[covenant]) do
      missing[name] = "(Torghast layer " .. tostring(layer) .. "+)"
   end
   for name, layer in pairs(TorghastCompanions[Enum.CovenantType.None]) do
      missing[name] = "(Torghast layer " .. tostring(layer) .. "+)"
   end
   local maximumPossible = tablelength(missing)
   -- now knock out the ones we already have
   -- fetch the follower list for SL
   local companions = C_Garrison.GetFollowers(Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower)
   for _, companion in ipairs(companions) do
      missing[companion.name] = nil
   end
   -- stash it in the persistent data
   mslcDB[playerNameKey][missingKey] = missing
   -- show what's left
   displayMissing()
   local actualPossible = tablelength(missing)
   if actualPossible > 0 then
      addon:Print(tostring(actualPossible) .. "/" .. tostring(maximumPossible) .. " companions")
   end

   -- save the list of those we've seen on all characters to our persistent table
   -- for later sanity-checking of our tables above
   for _, companion in ipairs(companions) do
      mslcDB["CovenantCompanionsToID"][companion.name] = companion.garrFollowerID
   end
   -- now show any we're missing in our canned tables above
   for companion, garFollowerID in pairs(mslcDB["CovenantCompanionsToID"]) do
      if isNotInCompanionList(companion, Soulbinds) and 
         isNotInCompanionList(companion, RenownCompanions) and 
         isNotInCompanionList(companion, TorghastCompanions) then
         addon:Print("error: " .. companion .. " not in any table!")
      end
   end
end

-- see https://wowpedia.fandom.com/wiki/GARRISON_FOLLOWER_ADDED
local function OnGarrisonFollowerAdded(
   followerDbID, followerName, followerClassName, followerLevel,
   followerQuality, isUpgraded, textureKit, followerTypeID)
   if Enum.GarrisonFollowerType.FollowerType_9_0  == followerTypeID then
      addon:Print("New follower " .. followerName .. " found!")
      findMissing()
   end
end

local function eventHandler(self, event, ...)
    if "ADVENTURE_MAP_OPEN" == event then
      findMissing()
    end
    if "GARRISON_FOLLOWER_ADDED" == event then
      -- this event also fires when collecting red shirts at the BFA table, but no arg is present
      if arg then
         OnGarrisonFollowerAdded(unpack(arg))
      end
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", eventHandler)
eventFrame:RegisterEvent("ADVENTURE_MAP_OPEN")
eventFrame:RegisterEvent("GARRISON_FOLLOWER_ADDED")

SLASH_MSLC1="/mslc"
SlashCmdList["MSLC"] = function(msg)
   displayMissing()
end

function addon:OnEnable()
   if not initialize() then
      logInitializeFailure()
      -- alts with no covenant or table don't need this
      return
   end
   local version = C_AddOns.GetAddOnMetadata(addonName, "Version") -- from TOC file
   addon:Print("Version " .. version)
   findMissing()
end

function mslc_OnAddonCompartmentClick(addonName, mouseButton, button)
   findMissing()
end
