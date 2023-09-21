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

-- Функція, яка перевіряє, чи містить рядок хоча б один символ кирилиці
function ContainsRussianCharacters(text)
    for char in text:gmatch(".") do
        -- Перевірка, чи символ є кириличним і не входить до списку ігнорованих символів
        if IsCyrillic(char) then
            return true -- Повертаємо true, якщо знайдено хоча б один символ
        end
    end

    return false
end

-- Функція для перевірки, чи символ є кириличним
function IsCyrillic(char)
    local utf8Char = char:byte()
    return (utf8Char >= 224 and utf8Char <= 243) or
        (utf8Char >= 128 and utf8Char <= 175) and not (utf8Char >= 192 and utf8Char <= 255)
end
