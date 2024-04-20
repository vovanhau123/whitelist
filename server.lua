ESX = exports['es_extended']:getSharedObject()
local cachedWhitelist = {}

function fetchWhitelist(cb)
    exports.oxmysql:execute('SELECT identifier FROM whitelist', {}, function(results)
        if results then
            local whitelistIdentifiers = {}
            for _, row in ipairs(results) do
                table.insert(whitelistIdentifiers, row.identifier)
            end
            if cb then cb(whitelistIdentifiers) end
        else
            print("Không thể lấy danh sách whitelist từ cơ sở dữ liệu.")
        end
    end)
end

function updateWhitelistCache()
    fetchWhitelist(function(newWhitelist)
        cachedWhitelist = newWhitelist
    end)
end

function isIdentifierWhitelisted(identifier)
    for _, whitelistedIdentifier in ipairs(cachedWhitelist) do
        if whitelistedIdentifier == identifier then
            return true
        end
    end
    return false
end

Citizen.CreateThread(function()
    updateWhitelistCache()
    while true do
        Citizen.Wait(3000) -- Khoảng thời gian cập nhật lại whitelist, ví dụ: 300000 ms là 5 phút
        updateWhitelistCache()
    end
end)

AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    deferrals.defer()
    local identifiers = GetPlayerIdentifiers(source)
    local discordIdentifier = nil
    for _, id in ipairs(identifiers) do
        -- Đây là dạng mẫu cho Discord identifier, bạn cần thay thế nếu dạng của bạn khác
        if string.match(id, 'discord:') then
            discordIdentifier = id
            break
        end
    end
    if discordIdentifier then
        if isIdentifierWhitelisted(discordIdentifier) then
            print(discordIdentifier .. " đã được xác nhận trong whitelist.")
            deferrals.done()
        else
            print(discordIdentifier .. " không có trong whitelist.")
            deferrals.done("Bạn không có trong danh sách trắng của server này.")
        end
    else
        print("Không thể xác định Discord ID của người chơi kết nối: " .. playerName)
        deferrals.done("Main Identifier không thể xác định.")
    end
end)