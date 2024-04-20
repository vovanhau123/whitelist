fx_version 'cerulean'
game 'gta5'

author 'Iqueen Dev'
description 'Whitelist Check for ESX Framework'
version '1.0.0'

server_script 'whitelist_check.lua'

dependencies {
    'es_extended', -- Sử dụng es_extended thay cho qb-core
    'oxmysql' -- Sử dụng mysql-async hoặc bất kỳ SQL wrapper nào mà ESX yêu cầu
}