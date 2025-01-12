fx_version "cerulean"
game "gta5"

author "Cocodrulo"
version "0.0.1"
description "A siple Fuel System for FiveM"

ui_page "html/index.html"

shared_scripts {
    "Config.lua"
}

client_scripts {
    "client/exports.lua",
    "client/main.lua"
}

server_scripts {
    "server/main.lua"
}

files {
    "html/index.html",
    "html/app.js",
    "html/style.css"
}

provide 'LegacyFuel'
