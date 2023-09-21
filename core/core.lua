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

-- Функція, яка перевіряє, чи містить рядок кириличні символи і виводить їх у чат
function ContainsRussianCharacters(text)
    local cyrillicCount = 0
    local detectedCharacters = {} -- Таблиця для зберігання символів, які спричинили виконання умови

    for char in text:gmatch(".") do
        -- Перевірка, чи символ є кириличним і не входить до списку ігнорованих символів
        if IsCyrillic(char) then
            cyrillicCount = cyrillicCount + 1
            table.insert(detectedCharacters, char) -- Додаємо символ у таблицю
            if cyrillicCount >= 2 then
                break                              -- Виходимо з циклу, якщо вже знайдено два символи
            end
        end
    end

    if cyrillicCount >= 2 then
        local detectedString = table.concat(detectedCharacters, ", ") -- Формуємо рядок зі списком символів
        print("Detected Cyrillic characters:", detectedString)        -- Виводимо список символів у чат
        return true
    end

    return false
end

-- Функція для перевірки, чи символ є кириличним
function IsCyrillic(char)
    local utf8Char = char:byte()
    -- Створюємо таблицю символів для ігнорування
    local ignoredCharacters = {
        192, 193, 194, 195, 196, 197, 198, 199,
        200, 201, 202, 203, 204, 205, 206, 207, 208, 209,
        210, 211, 212, 213, 214, 215, 216, 217, 218, 219,
        220, 221, 222, 223, 224, 225, 226, 227, 228, 229,
        230, 231, 232, 233, 234, 235, 236, 237, 238, 239,
        240, 241, 242, 243, 244, 245, 246, 247, 248, 249,
        250, 251, 252, 253, 254, 255
    }

    return (utf8Char >= 224 and utf8Char <= 243) or
        (utf8Char >= 128 and utf8Char <= 175) and not tableContains(ignoredCharacters, utf8Char)
end

-- Функція для перевірки, чи символ входить до списку ігнорованих символів
function tableContains(table, element)
    for _, value in ipairs(table) do
        if value == element then
            return true
        end
    end
    return false
end
