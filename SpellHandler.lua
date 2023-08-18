local spellInfo = {
    subscribe = "SPELL_CAST_START",
    name = "SpellHandler",
    spell = {
        name = "",
        castTime = 0
    }
}

function spellInfo:Handle(event, args)
    if not Lib.lastTargetId or
        not args.sourceGUID or
        Lib.lastTargetId ~= args.sourceGUID
        or (Lib.lastTargetId == args.sourceGUID and Lib.lastTargetId == args.destGUID)
    then
        return
    end

    spellInfo.isOff = false;
    spellInfo.spell.castTime = ({ GetSpellInfo(args.spellId) })[7] / 1000;
    spellInfo.spell.name = event .. " / " .. args.sourceName .. " / " .. args.spellName;
end

function spellInfo:OnUpdate(elapsed)
    if spellInfo.isOff == true then return end

    if spellInfo.spell.castTime < 0.01 then
        Lib.spellFrame.text:SetText("");
        spellInfo.isOff = true
        return
    end

    spellInfo.spell.castTime = spellInfo.spell.castTime - elapsed;
    Lib.spellFrame.text:SetText(spellInfo.spell.name .. " / " .. string.format("%.1f", spellInfo.spell.castTime));
end

if Lib:Register(spellInfo) then
    print("successful register " .. spellInfo.name)
end
