ESX = nil
-- Biến lưu trữ kết quả truy vấn trước
local lastDiscordIDs = {}

-- Lấy object của ESX khi server đã sẵn sàng
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(200)
    end
end)

local function isPlayerWhitelisted(discordID, cb)
    exports.oxmysql:execute('SELECT COUNT(1) FROM users WHERE discord_id = ?', { discordID }, function(result)
        if result[1] and result[1]['COUNT(1)'] > 0 then
            print("Discord ID " .. discordID .. " đã được whitelist.")
            cb(true)
        else
            print("Discord ID " .. discordID .. " không được whitelist.")
            cb(false)
        end
    end)
end

-- Thread kiểm tra cập nhật dữ liệu mỗi 3 giây
Citizen.CreateThread(function()
    while true do
        exports.oxmysql:execute('SELECT discord_id FROM users', {}, function(results)
            if results then
                local currentDiscordIDs = {}
                for _, row in ipairs(results) do
                    table.insert(currentDiscordIDs, row.discord_id)
                end

                -- So sánh danh sách discord_id mới với danh sách cũ
                if not lastDiscordIDs or not compareTables(lastDiscordIDs, currentDiscordIDs) then
                    print('Có sự thay đổi trong danh sách người chơi.')
                    -- Có thể thêm mã để log ra sự thay đổi cụ thể nếu cần
                    --...
                end
                
                lastDiscordIDs = currentDiscordIDs
            end
        end)
        Citizen.Wait(3000) -- Đợi 3 giây trước khi lặp lại
    end
end)

-- Sự kiện khi người chơi kết nối
AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    local discordID = nil
    local identifier = xPlayer.identifier

    for _, id in ipairs(GetPlayerIdentifiers(playerId)) do
        if string.sub(id, 1, string.len("discord:")) == "discord:" then
            discordID = id
            break
        end
    end

    print('Identifiers for player ' .. xPlayer.name .. ':')
    for _, id in ipairs(GetPlayerIdentifiers(playerId)) do
        print(id)
    end

    if discordID then
        isPlayerWhitelisted(discordID, function(isWhitelisted)
            if not isWhitelisted then
                DropPlayer(playerId, "Bạn không có trong danh sách trắng của server này.")
            end
        end)
    else
        DropPlayer(playerId, "Discord ID không thể xác định.")
    end
end)