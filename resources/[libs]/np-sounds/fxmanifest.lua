fx_version "cerulean"
games { "gta5" }

ui_page "html/index.html"

files {
    "html/index.html",
    "html/sounds/*.ogg",
}

shared_scripts {
    "shared/*",
}

server_scripts {
    "@np-lib/server/sv_infinity.lua",
    "server/*",
}

client_scripts {
    "@np-lib/client/cl_infinity.lua",
    "client/*",
}