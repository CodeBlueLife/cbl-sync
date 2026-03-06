fx_version 'cerulean'
game 'gta5'

name 'cbl-sync'
author 'Venoxity Development'
description 'Dynamic time and weather sync for FiveM with admin controls and zone-specific handling.'
version '1.0.1'
license 'GPL-3.0-or-later'
repository 'https://github.com/CodeBlueLife/cbl-sync.git'

shared_script '@ox_lib/init.lua'

client_scripts {
    'client/**/*.lua',
}

server_scripts {
    'server/**/*.lua',
}
