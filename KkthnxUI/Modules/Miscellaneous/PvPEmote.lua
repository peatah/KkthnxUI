local K, C, L = unpack(select(2, ...))

-- Lua API
local bit_band = bit.band
local math_random = math.random
local select = select

-- Wow API
local DoEmote = DoEmote
local UnitGUID = UnitGUID
local GetAchievementInfo = GetAchievementInfo

-- GLOBALS: COMBATLOG_OBJECT_CONTROL_PLAYER

local PVPEmoteMessages = CreateFrame("Frame")
local playerid = UnitGUID("player")

local PVPEmotes = {
    "BYE", "BITE", "CACKLE", "SHOO", "SLAP", "TEASE", "TAUNT", "MOCK", "MOO",
    "CHICKEN", "COMFORT", "CUDDLE", "CURTSEY", "GIGGLE", "GROWL", "NOSEPICK",
    "CHUCKLE", "BONK", "FLEX", "GRIN", "LAUGH", "MOON", "NO", "ROAR", "ROFL",
    "MOURN", "SNIFF", "LICK", "SNICKER", "GUFFAW", "GLOAT", "PITY", "VIOLIN",
    "RASP", "RUDE", "SMIRK", "SNUB", "SOOTHE", "THANK", "TICKLE", "VETO", "YAWN",
    "SCRATCH", "SIGH", "SNARL", "TAP", "INSULT", "BARK", "BECKON", "CALM",
}

local function GetRandomEmote()
    return PVPEmotes[math_random(1, #(PVPEmotes))]
end

PVPEmoteMessages:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
PVPEmoteMessages:SetScript("OnEvent", function(self, event, ...)
    if C.Misc.PvPEmote ~= true then return end
    local _, event, _, sourceGUID, sourceName, _, _, destGUID, destName,  destFlags = ...
    if (event == "PARTY_KILL") and (sourceGUID == playerid) and (bit_band(destFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0) then
        if select(4, GetAchievementInfo(247)) then
            DoEmote(GetRandomEmote(), destName)
        else
            DoEmote("HUG", destName)
        end
    end
end)