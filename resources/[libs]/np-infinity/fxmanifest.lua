fx_version "cerulean"
games { "gta5" }

shared_scripts {
    "shared/*.*",
}

server_scripts {
    "@np-lib/server/sv_rpc.lua",
    "server/sv_config.lua",
    "server/*.*",
}

client_scripts {
    "@np-lib/client/cl_rpc.lua",
    "client/classes/*.*",
    "client/*.*",
}










