local MODNAME = "RaidAssistent"
local addon = LibStub("AceAddon-3.0"):NewAddon(MODNAME, "AceEvent-3.0")
_G.RaidAssistent = addon

-- Тут ми створюємо таблицю для збереження унікальних імен російських гравців
local russianPlayerNames = {}

-- Функція, яка виводить повідомлення у чат гри
local function LogMessage(message)
    print("|cFFFF7D0A<|r|cFFFFFF00" .. MODNAME .. "|r|cFFFF7D0A>|r " .. message)
end

-- Отримуємо розміри кнопки CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck
local readyCheckButton = CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck
local _, height = readyCheckButton:GetSize()
-- Отримуємо шрифт кнопки readyCheckButton
local readyCheckFontObject = readyCheckButton:GetFontString():GetFontObject()

-- Отримуємо висоту пропусків між кнопками (визначте бажану висоту пропуску)
local spacingHeight = 0.8

-- Обчислюємо загальну висоту фрейму
local totalHeight = (height + spacingHeight) * 3 + 5.8

-- Встановлюємо висоту фрейму CompactRaidFrameManagerDisplayFrameLeaderOptions
CompactRaidFrameManagerDisplayFrameLeaderOptions:SetSize(300, totalHeight)

-- Створюємо вашу кнопку та встановлюємо її розмір відповідно до розміру тексту
local newButton = CreateFrame("Button", "RaidAssistentNewButton", CompactRaidFrameManagerDisplayFrameLeaderOptions,
    "UIPanelButtonTemplate")
newButton:SetText("Optimize Raid")
-- Встановлюємо шрифт для тексту кнопки такий, як у readyCheckButton
newButton:GetFontString():SetFontObject(readyCheckFontObject)
-- Отримуємо розміри тексту кнопки та додаємо певний заздалегідь визначений зазор (наприклад, 10 пікселів) для визначення ширини кнопки
local textWidth = newButton:GetFontString():GetStringWidth() + 20
-- Встановлюємо ширину кнопки відповідно до розміру тексту
newButton:SetWidth(textWidth)
newButton:SetHeight(height) -- Задаємо бажану висоту кнопки

-- Позиція кнопки вгорі фрейму CompactRaidFrameManagerDisplayFrameLeaderOptions
newButton:SetPoint("TOPLEFT", readyCheckButton, "BOTTOMLEFT", 0, -spacingHeight)
newButton:SetPoint("TOPRIGHT",
    readyCheckButton, "BOTTOMRIGHT", 0, -spacingHeight)

-- Функція, яка буде виконуватися при натисканні на кнопку
newButton:SetScript("OnClick", function(self)
    -- Додайте ваш код дій, які мають бути виконані при натисканні кнопки тут
    print("New Button Clicked")
end)

-- Функція OnEnable викликається при завантаженні аддона
function addon:OnEnable()
    self:RegisterEvent("GROUP_ROSTER_UPDATE", "CheckGroupMembers")
    -- Додаємо повідомлення у чат при запуску аддона
    LogMessage("Addon activated.")
end

-- Функція, яка перевіряє імена гравців у групі
function addon:CheckGroupMembers()
    if not IsInGroup() and not IsInRaid() then
        return
    end

    wipe(russianPlayerNames)
    local numMembers = GetNumGroupMembers()

    if IsInRaid() then
        MAX_GROUP_SIZE = MAX_RAID_MEMBERS
    elseif IsInGroup() then
        MAX_GROUP_SIZE = MAX_PARTY_MEMBERS
    else
        MAX_GROUP_SIZE = 1 -- Якщо гравець не в групі, то максимальний розмір групи 1 (гравець в одиночній грі)
    end

    -- Перевірка, чи numMembers не є nil
    if numMembers then
        for i = 1, numMembers do
            local name, _, _, _, _, _, _, _, _, _, _ = GetRaidRosterInfo(i)
            if name then -- Додаткова перевірка, чи name не є nil
                if ContainsRussianCharacters(name) then
                    if not tContains(russianPlayerNames, name) then
                        table.insert(russianPlayerNames, name)
                    end
                end
            end
        end

        if #russianPlayerNames > 0 then
            local playerList = table.concat(russianPlayerNames, "\n")
            -- Додаємо повідомлення у чат про гравців з кириличними іменами
            LogMessage("Players with Cyrillic names detected:\n" .. playerList)

            WarnRussianPlayersDetected(playerList)
            GroupUtils_LeaveGroup()
        else
            -- Додайте повідомлення про відсутність кириличних імен в чат
            LogMessage("Players with Cyrillic names not found in the group.")
        end
    else
        -- Обробка випадку, коли numMembers є nil
        LogMessage("Unable to determine the number of group members.")
    end
end

-- Функція для перевірки, чи символ є кирилицьким в UTF-8
function IsCyrillic(char)
    -- Отримуємо Unicode-код поточного символу з UTF-8 рядка
    local utf8Byte1 = char:byte(1)

    -- Перевіряємо діапазони для символів кирилиці в UTF-8
    if utf8Byte1 >= 0xD0 and utf8Byte1 <= 0xDF then
        return true -- Дійсний символ кирилиці (2-байтовий UTF-8 символ)
    elseif utf8Byte1 == 0xD1 then
        local utf8Byte2 = char:byte(2)
        return (utf8Byte2 >= 0x80 and utf8Byte2 <= 0x8F) -- Ще один дійсний символ кирилиці (2-байтовий UTF-8 символ)
    end

    return false
end

-- Функція, яка перевіряє, чи текст містить хоча б один символ кирилиці
function ContainsRussianCharacters(text)
    for char in text:gmatch(".") do
        -- Перевірка, чи символ є кириличним і не входить до списку ігнорованих символів
        if IsCyrillic(char) then
            return true -- Повертаємо true, якщо знайдено хоча б один символ
        end
    end

    return false
end
