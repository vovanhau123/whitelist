fx_version 'cerulean'
game 'gta5'

author 'Tên tác giả'
description 'Mô tả resource của bạn'
version '1.0.0'

server_scripts {
    '@oxmysql/lib/MySQL.lua',  -- Sử dụng oxmysql thay vì mysql-async.
    'server.lua'  -- Đường dẫn đến file script server của bạn.
}

dependencies {
    'es_extended',  -- Đảm bảo rằng bạn đã thêm es_extended làm phụ thuộc nếu resource của bạn sử dụng ESX.
    'oxmysql'       -- Phụ thuộc này cần phải khớp với thư viện mà bạn đang sử dụng.
}