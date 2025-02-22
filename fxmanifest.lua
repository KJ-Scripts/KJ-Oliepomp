fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'

author 'KJ Scripts'
description 'Oliepomp systeem'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

dependencies {
    'es_extended',
    'ox_lib',
    'oxmysql'
}