fx_version "cerulean"
games { "gta5" }

shared_scripts {
    "shared/*",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "@np-lib/server/sv_rpc.lua",
    "@np-lib/server/sv_character.lua",
    "server/*",
}

client_scripts {
    "@np-lib/client/cl_rpc.lua",
    "client/*",
}