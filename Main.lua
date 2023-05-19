local addonName, addon = ...
LibStub('AceAddon-3.0'):NewAddon(addon, addonName, 'AceConsole-3.0')

local eventFrame = CreateFrame("Frame")

-- Data from https://docs.google.com/spreadsheets/d/16etPtUTrVxiNl50iNHvi-Sqs6-goOPOjf2kVp8hZeJM/edit#gid=0

-- sources

local KyrianSoulbinds = { 
   ["Pelagos"] = 1,
   ["Kleia"] = 2,
   ["Mikaniikos"] = 3,
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
   ["Te'Zan"] = 12,
   ["Master Sha'Lor"] = 17,
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
   ["Xertora"] = 1,
   ["Rattlebag"] = 1,
   ["Riyuja Shockfist"] = 1,
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
   ["Spore of Mirasmius"] = 1,
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

-- these are from garrFollowerID member of structures returned by GetFollowers()
-- we use this to sanity-check the lists above
--[[
local CovenantCompanionsToID = {
	["Talethi"] = 1307,
	["Rathan"] = 1305,
	["Kaletar"] = 1217,
	["Teliah"] = 1221,
	["Bogdan"] = 1253,
	["Hermestes"] = 1341,
	["Blisswing"] = 1277,
	["Dug Gravewell"] = 1214,
	["Nadjia the Mistblade"] = 1208,
	["Nerith Darkwing"] = 1215,
	["Emeni"] = 1263,
	["Qadarin"] = 1286,
	["Elwyn"] = 1338,
	["Rattlebag"] = 1310,
	["Sika"] = 1272,
	["Kleia"] = 1260,
	["Spore of Marasmius"] = 1326,
	["Vulca"] = 1255,
	["Lloth'wellyn"] = 1281,
	["Lassik Spinebender"] = 1333,
	["Plague Deviser Marileth"] = 1261,
	["Thela Soulsipper"] = 1213,
	["General Draven"] = 1209,
	["Deathfang"] = 1336,
	["Chachi the Artiste"] = 1345,
	["Simone"] = 1252,
	["Enceladus"] = 1335,
	["Yanlar"] = 1339,
	["Rencissa the Dynamo"] = 1302,
	["Stonehead"] = 1251,
	["Lost Sybille"] = 1254,
	["Hunt-Captain Korayn"] = 1266,
	["Khaliiq"] = 1303,
	["Kythekios"] = 1222,
	["Stonehuck"] = 1216,
	["Theotar"] = 1210,
	["Duskleaf"] = 1278,
	["Hala"] = 1267,
	["Madame Iza"] = 1346,
	["Lucia"] = 1347,
	["Secutor Mevix"] = 1300,
	["Croman"] = 1325,
	["Cromas the Mystic"] = 1342,
	["Kiaranyka"] = 1329,
	["Niya"] = 1265,
	["ELGU - 007"] = 1328,
	["Dreamweaver"] = 1264,
	["Meatball"] = 1257,
	["Sulanoom"] = 1337,
	["Molako"] = 1268,
	["Master Sha'lor"] = 1284,
	["Apolon"] = 1276,
	["Auric Spiritguide"] = 1343,
	["Rahel"] = 1250,
	["Watcher Vesperbloom"] = 1287,
	["Ella"] = 1327,
	["Bron"] = 1275,
	["Velkein"] = 1308,
	["Bonesmith Heirmir"] = 1262,
	["Lyra Hailstorm"] = 1334,
	["Disciple Kosmas"] = 1274,
	["Assembler Xertora"] = 1309,
	["Plaguey"] = 1304,
	["Te'zan"] = 1285,
	["Pelagos"] = 1259,
	["Clora"] = 1273,
	["Karynmwylyann"] = 1279,
	["Gorgelimb"] = 1306,
	["Guardian Kota"] = 1283,
	["Telethakas"] = 1223,
	["Gunn Gorgebone"] = 1301,
	["Yira'lya"] = 1282,
	["Ayeleth"] = 1220,
	["Ispiron"] = 1269,
	["Chalkyth"] = 1280,
	["Groonoomcrooek"] = 1288,
	["Pelodis"] = 1271,
	["Steadyhands"] = 1332,
}
--]]

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

local function displayMissing()
   if not MissingCharacterCompanions then
      MissingCharacterCompanions = {}
   end
   local count = 0
   for companion, source in pairs(MissingCharacterCompanions) do
      addon:Print(companion .. ": " .. source)
      count = count + 1
   end
   if count > 0 then
      addon:Print("Type /mslc to re-display the list.")
   end
end

local function eventHandler(self, event, ...)
    if event == "ADVENTURE_MAP_OPEN" then
    local arg1 = ...
      local covenant = C_Covenants.GetActiveCovenantID()
      if 0 == covenant then
         addon:Print("no covenant yet!")
         return
      end
      -- build list of possible companions
      MissingCharacterCompanions = {}
      for name, rank in pairs(Soulbinds[covenant]) do
         MissingCharacterCompanions[name] = "(Soulbind " .. tostring(rank) .. ")"
      end
      for name, renown in pairs(RenownCompanions[covenant]) do
         MissingCharacterCompanions[name] = "(Renown " .. tostring(renown) .. ")"
      end
      for name, layer in pairs(TorghastCompanions[covenant]) do
         MissingCharacterCompanions[name] = "(Torghast layer " .. tostring(layer) .. "+)"
      end
      for name, layer in pairs(TorghastCompanions[Enum.CovenantType.None]) do
         MissingCharacterCompanions[name] = "(Torghast layer " .. tostring(layer) .. "+)"
      end
      local maximumPossible = tablelength(MissingCharacterCompanions)
      -- now knock out the ones we already have
      -- fetch the follower list for SL
      local companions = C_Garrison.GetFollowers(Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower)
      for _, companion in ipairs(companions) do
         MissingCharacterCompanions[companion.name] = nil
      end
      -- show what's left
      displayMissing()
      local actualPossible = tablelength(MissingCharacterCompanions)
      if actualPossible > 0 then
         addon:Print(tostring(actualPossible) .. "/" .. tostring(maximumPossible) .. " companions")
      end

      -- save the list of those we've seen on all characters to our persistent table
      -- for later sanity-checking of our tables above
      if not CovenantCompanionsToID then
         CovenantCompanionsToID = {}
      end
      for _, companion in ipairs(companions) do
         CovenantCompanionsToID[companion.name] = companion.garrFollowerID
      end
      -- now show any we're missing in our canned tables above
      for companion, garFollowerID in pairs(CovenantCompanionsToID) do
         if isNotInCompanionList(companion, Soulbinds) and 
            isNotInCompanionList(companion, RenownCompanions) and 
            isNotInCompanionList(companion, TorghastCompanions) then
            addon:Print("error: " .. companion .. " not in any table!")
         end
      end
    end
end

eventFrame:SetScript("OnEvent", eventHandler)
eventFrame:RegisterEvent("ADVENTURE_MAP_OPEN")

SLASH_MSLC1="/mslc"
SlashCmdList["MSLC"] = function(msg)
   displayMissing()
end
