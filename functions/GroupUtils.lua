-- Функція для виходу з групи або рейду та видалення гравців з російськими іменами
function GroupUtils_LeaveGroup(playerList)
    if not (IsInGroup() or IsInRaid()) then
        return -- Виходимо, якщо не в групі або рейді
    end

    local isLeaderOrAssistant = UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")

    if isLeaderOrAssistant then
        GroupUtils_RemoveRussianPlayersFromList(playerList) -- Видаляємо гравців з російськими іменами
    end

    if IsInRaid() or (IsInGroup() and not isLeaderOrAssistant) then
        C_PartyInfo.LeaveParty() -- Виходимо з рейду або групи
    end
end

-- Функція для видалення гравців з російськими іменами зі списку (playerList)
function GroupUtils_RemoveRussianPlayersFromList(playerList)
    local toRemove = {} -- Створюємо пустий список для гравців, яких потрібно видалити

    for index, playerName in ipairs(playerList) do
        if ContainsRussianCharacters(playerName) then
            table.insert(toRemove, index) -- Додаємо індекси гравців з російськими іменами до списку для видалення
        end
    end

    -- Переверніть список для видалення, щоб видаляти гравців з кінця
    table.sort(toRemove, function(a, b) return a > b end)

    for _, index in ipairs(toRemove) do
        table.remove(playerList, index) -- Видаляємо гравців з російськими іменами
    end
end
