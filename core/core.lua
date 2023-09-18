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
    if IsInGroup() or IsInRaid() then
        -- Очищуємо список перед перевіркою
        wipe(russianPlayerNames)
        local numMembers = GetNumGroupMembers()
        for i = 1, numMembers do
            local name, _, _, _, _, _, _, _, _, _, _ = GetRaidRosterInfo(i)
            if name and ContainsRussianCharacters(name) then
                -- Зберігаємо ім'я гравця в таблиці, якщо його ще немає
                if not tContains(russianPlayerNames, name) then
                    table.insert(russianPlayerNames, name)
                end
            end
        end
    end

    -- Перевіряємо, чи є російські гравці в групі та виводимо їх імена у повідомленні
    if #russianPlayerNames > 0 then
        local playerList = table.concat(russianPlayerNames, "\n") -- Кожне ім'я в новому рядку
        -- Завантажуємо аддон Dialogs, якщо він ще не завантажений
        if not IsAddOnLoaded("RussianNameChecker_Dialogs") then
            LoadAddOn("RussianNameChecker_Dialogs")
        end
        -- Викликаємо функцію з Dialogs.lua, передаючи список імен
        WarnRussianPlayersDetected(playerList)
        GroupUtils_LeaveGroup(playerList)
    end
end

-- Функція, яка перевіряє, чи містить рядок російські букви
function ContainsRussianCharacters(text)
    -- Визначте російські букви або символи, які ви хочете перевірити
    local russianCharacters = { "а", "б", "в", "г", "д", "е", "ё", "ж", "з", "и", "й", "к", "л", "м", "н",
        "о", "п", "р", "с", "т", "у", "ф", "х", "ц", "ч", "ш", "щ", "ъ", "ы", "ь", "э", "ю", "я" }

    -- Перевірте, чи містить рядок російські букви
    for _, character in ipairs(russianCharacters) do
        if string.find(text, character) then
            return true
        end
    end

    return false
end
