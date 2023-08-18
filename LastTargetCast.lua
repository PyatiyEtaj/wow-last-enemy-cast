local version = 1.1
local lib = LibStub:NewLibrary("LastEnemyCast-"..version, 1);

if not lib.frame then
    lib.frame = CreateFrame("Frame");
end

function lib:Init(self)
    if not lib.inited then lib.inited = true else return end

    lib.frame:RegisterEvent('ADDON_LOADED')
    lib.frame:SetScript('OnEvent', function(self, event, ...)
        if self[event] then
            self[event](self, ...)
        end
    end)

    function lib:Log(text)
        SELECTED_CHAT_FRAME:AddMessage(text);
    end

    function lib.frame:ADDON_LOADED(self)
        lib.frame:UnregisterEvent('ADDON_LOADED')

        lib:Log("Init LastEnemyCast v"..version);

        lib.spellFrame = CreateFrame("Frame", nil, UIParent);
        lib.spellFrame:SetWidth(100);
        lib.spellFrame:SetHeight(100);
        lib.spellFrame:SetAlpha(1);
        lib.spellFrame:SetPoint("CENTER", 0, -100);
        lib.spellFrame.text = lib.spellFrame:CreateFontString(nil, "ARTWORK");
        lib.spellFrame.text:SetFont("Fonts\\ARIALN.ttf", 13, "OUTLINE");
        lib.spellFrame.text:SetPoint("CENTER", 0, 0);
        lib.spellFrame:Hide();

        lib.frame:RegisterEvent("PLAYER_TARGET_CHANGED");
        lib.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
    end
end

function lib.frame:PLAYER_TARGET_CHANGED(self)
    if (not UnitIsFriend("player", "target")) then
        local id = UnitGUID("target");
        if id then
            lib.lastTargetId = id
            lib.spellFrame.text:SetText("");
            lib:Log("remember " .. lib.lastTargetId)
        end
    end
end

function HandleEvent(event, args)
    if not event:starts("SPELL") then return end

    if not lib.lastTargetId or not args.sourceGUID or lib.lastTargetId ~= args.sourceGUID then return end

    lib.spellFrame:Show();
    lib.spellFrame.text:SetText(event .. " / " .. args.sourceName .. " / " .. args.spellName);
end

function lib.frame:COMBAT_LOG_EVENT_UNFILTERED(timestamp, event, sourceGUID, sourceName, sourceFlags, destGUID, destName,
                                               destFlags, ...)
    local args = {}
    args.timestamp = timestamp
    args.event = event
    args.sourceGUID = sourceGUID
    args.sourceName = sourceName
    args.sourceFlags = sourceFlags
    args.destGUID = destGUID
    args.destName = destName
    args.destFlags = destFlags
    -- taken from Blizzard_CombatLog.lua
    if event == "SWING_DAMAGE" then
        args.amount, args.overkill, args.school, args.resisted, args.blocked, args.absorbed, args.critical, args.glancing, args.crushing =
            select(1, ...)
    elseif event == "SWING_MISSED" then
        args.spellName = ACTION_SWING
        args.missType = select(1, ...)
    elseif event:sub(1, 5) == "RANGE" then
        args.spellId, args.spellName, args.spellSchool = select(1, ...)
        if event == "RANGE_DAMAGE" then
            args.amount, args.overkill, args.school, args.resisted, args.blocked, args.absorbed, args.critical, args.glancing, args.crushing =
                select(4, ...)
        elseif event == "RANGE_MISSED" then
            args.missType = select(4, ...)
        end
    elseif event:sub(1, 5) == "SPELL" then
        args.spellId, args.spellName, args.spellSchool = select(1, ...)
        if event == "SPELL_DAMAGE" then
            args.amount, args.overkill, args.school, args.resisted, args.blocked, args.absorbed, args.critical, args.glancing, args.crushing =
                select(4, ...)
        elseif event == "SPELL_MISSED" then
            args.missType, args.amountMissed = select(4, ...)
        elseif event == "SPELL_HEAL" then
            args.amount, args.overheal, args.absorbed, args.critical = select(4, ...)
            args.school = args.spellSchool
        elseif event == "SPELL_ENERGIZE" then
            args.valueType = 2
            args.amount, args.powerType = select(4, ...)
        elseif event:sub(1, 14) == "SPELL_PERIODIC" then
            if event == "SPELL_PERIODIC_MISSED" then
                args.missType = select(4, ...)
            elseif event == "SPELL_PERIODIC_DAMAGE" then
                args.amount, args.overkill, args.school, args.resisted, args.blocked, args.absorbed, args.critical, args.glancing, args.crushing =
                    select(4, ...)
            elseif event == "SPELL_PERIODIC_HEAL" then
                args.amount, args.overheal, args.absorbed, args.critical = select(4, ...)
                args.school = args.spellSchool
            elseif event == "SPELL_PERIODIC_DRAIN" then
                args.amount, args.powerType, args.extraAmount = select(4, ...)
                args.valueType = 2
            elseif event == "SPELL_PERIODIC_LEECH" then
                args.amount, args.powerType, args.extraAmount = select(4, ...)
                args.valueType = 2
            elseif event == "SPELL_PERIODIC_ENERGIZE" then
                args.amount, args.powerType = select(4, ...)
                args.valueType = 2
            end
        elseif event == "SPELL_DRAIN" then
            args.amount, args.powerType, args.extraAmount = select(4, ...)
            args.valueType = 2
        elseif event == "SPELL_LEECH" then
            args.amount, args.powerType, args.extraAmount = select(4, ...)
            args.valueType = 2
        elseif event == "SPELL_INTERRUPT" then
            args.extraSpellId, args.extraSpellName, args.extraSpellSchool = select(4, ...)
        elseif event == "SPELL_EXTRA_ATTACKS" then
            args.amount = select(4, ...)
        elseif event == "SPELL_DISPEL_FAILED" then
            args.extraSpellId, args.extraSpellName, args.extraSpellSchool = select(4, ...)
        elseif event == "SPELL_AURA_DISPELLED" then
            args.extraSpellId, args.extraSpellName, args.extraSpellSchool = select(4, ...)
            args.auraType = select(7, ...)
        elseif event == "SPELL_AURA_STOLEN" then
            args.extraSpellId, args.extraSpellName, args.extraSpellSchool = select(4, ...)
            args.auraType = select(7, ...)
        elseif event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REMOVED" then
            args.auraType = select(4, ...)
            args.sourceName = args.destName
            args.sourceGUID = args.destGUID
            args.sourceFlags = args.destFlags
        elseif event == "SPELL_AURA_APPLIED_DOSE" or event == "SPELL_AURA_REMOVED_DOSE" then
            args.auraType, args.amount = select(4, ...)
            args.sourceName = args.destName
            args.sourceGUID = args.destGUID
            args.sourceFlags = args.destFlags
        elseif event == "SPELL_CAST_FAILED" then
            args.missType = select(4, ...)
        end
    elseif event == "DAMAGE_SHIELD" then
        args.spellId, args.spellName, args.spellSchool = select(1, ...)
        args.amount, args.school, args.resisted, args.blocked, args.absorbed, args.critical, args.glancing, args.crushing =
            select(4, ...)
    elseif event == "DAMAGE_SHIELD_MISSED" then
        args.spellId, args.spellName, args.spellSchool = select(1, ...)
        args.missType = select(4, ...)
    elseif event == "ENCHANT_APPLIED" then
        args.spellName = select(1, ...)
        args.itemId, args.itemName = select(2, ...)
    elseif event == "ENCHANT_REMOVED" then
        args.spellName = select(1, ...)
        args.itemId, args.itemName = select(2, ...)
    elseif event == "UNIT_DIED" or event == "UNIT_DESTROYED" then
        args.sourceName = args.destName
        args.sourceGUID = args.destGUID
        args.sourceFlags = args.destFlags
    elseif event == "ENVIRONMENTAL_DAMAGE" then
        args.environmentalType = select(1, ...)
        args.amount, args.overkill, args.school, args.resisted, args.blocked, args.absorbed, args.critical, args.glancing, args.crushing =
            select(2, ...)
        args.spellName = _G["ACTION_" .. event .. "_" .. args.environmentalType]
        args.spellSchool = args.school
    elseif event == "DAMAGE_SPLIT" then
        args.spellId, args.spellName, args.spellSchool = select(1, ...)
        args.amount, args.school, args.resisted, args.blocked, args.absorbed, args.critical, args.glancing, args.crushing =
            select(4, ...)
    end
    return HandleEvent(event, args)
end

function string.starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start;
end

lib:Init()
