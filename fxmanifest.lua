fx_version 'cerulean'
game 'gta5'

author 'Tom Ronnie'
description 'Surrender plugin - supports actions such as raising hands, kneeling, lying down, etc.'
version '1.0.3'

repository 'https://github.com/RonnieTom/TRC-Surrender-Plugin'

client_scripts {
    'config.lua',
    'lang.lua',
    'client.lua'
}

server_scripts {
    'server.lua'
}

ui_page 'html/ui.html'

files {
    'html/ui.html'
} 
