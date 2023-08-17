local lib = LibStub:NewLibrary("LastEnemyCast-1.0", 1);

if not lib.frame then
    lib.frame = CreateFrame("Frame");
end

lib.frame:RegisterEvent('ADDON_LOADED')
lib.frame:SetScript('OnEvent', function(self, event, ...)
    if self[event] then
        self[event](self, ...)
    end
end)

function lib:Log( text )
	SELECTED_CHAT_FRAME:AddMessage( text );
end

function lib.frame:ADDON_LOADED(self)
    lib.frame:UnregisterEvent('ADDON_LOADED')

    lib:Log("Init LastEnemyCast v1.0");

    lib.spellFrame = CreateFrame("Frame",nil,UIParent);
    lib.spellFrame:SetWidth(100);
    lib.spellFrame:SetHeight(100);
    lib.spellFrame:SetAlpha(1);
    lib.spellFrame:SetPoint("CENTER",0,-100);
    lib.spellFrame.text = lib.spellFrame:CreateFontString(nil,"ARTWORK");
    lib.spellFrame.text:SetFont("Fonts\\ARIALN.ttf", 13, "OUTLINE");
    lib.spellFrame.text:SetPoint("CENTER",0,0);
    lib.spellFrame:Hide();

    lib.frame:RegisterEvent("PLAYER_TARGET_CHANGED");
    lib.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
end


function lib.frame:PLAYER_TARGET_CHANGED(self)
    if (not UnitIsFriend("player", "target")) then
       lib.lastTargetId = UnitGUID("target");
       lib.spellFrame.text:SetText("");
    end
end


function lib.frame:COMBAT_LOG_EVENT_UNFILTERED( self, event, ... )
    CombatLogSetCurrentEntry(0, true);
    local args = {CombatLogGetCurrentEntry()};

    local subevent = args[2];
    local targetId = args[3];
    local targetName = args[4];
    local possbleCastName = args[10];

    if (not possbleCastName) then
        possbleCastName = "";
    end

    if (lib.lastTargetId and targetId == lib.lastTargetId and subevent:starts("SPELL")) then
        lib.spellFrame:Show();
        lib.spellFrame.text:SetText(subevent .. " / " .. targetName .. " / "..possbleCastName);
    end
end

function string.starts(String,Start)
    return string.sub(String,1,string.len(Start))==Start;
end