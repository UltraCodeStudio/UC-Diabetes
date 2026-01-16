fx_version 'cerulean'
game 'gta5'

description 'Diabetes Script for FiveM'
version '1.0'
author 'Ultra Code'

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua',
}

client_scripts {
    'client/main.lua',
    'client/playerClass.lua',
}

server_scripts {
    'server/**.lua',
    '@oxmysql/lib/MySQL.lua',
}

dependencies {
    'ox_lib',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'


