local MODNAME = "RussianNameChecker"
local addon = LibStub("AceAddon-3.0"):NewAddon(MODNAME, "AceEvent-3.0")
_G.RussianNameChecker = addon

-- Тут ми створюємо таблицю для збереження унікальних імен російських гравців
local russianPlayerNames = {}

-- Функція OnEnable викликається при завантаженні аддона
function addon:OnEnable()
    self:RegisterEvent("GROUP_ROSTER_UPDATE", "CheckGroupMembers")
end

-- Функція, яка перевіряє імена гравців у групі
function addon:CheckGroupMembers()
    if not IsInGroup() and not IsInRaid() then
        return
    end

    wipe(russianPlayerNames)
    local numMembers = GetNumGroupMembers()
    for i = 1, numMembers do
        local name, _, _, _, _, _, _, _, _, _, _ = GetRaidRosterInfo(i)
        if name and ContainsRussianCharacters(name) then
            if not tContains(russianPlayerNames, name) then
                table.insert(russianPlayerNames, name)
            end
        end
    end

    if #russianPlayerNames > 0 then
        local playerList = table.concat(russianPlayerNames, "\n")
        if not IsAddOnLoaded("RussianNameChecker_Dialogs") then
            LoadAddOn("RussianNameChecker_Dialogs")
        end
        WarnRussianPlayersDetected(playerList)
        GroupUtils_LeaveGroup(playerList)
    end
end

-- Функція, яка перевіряє, чи містить рядок російські букви
function ContainsRussianCharacters(text)
    return string.match(text, "[а-яА-ЯёЁ]")
end
