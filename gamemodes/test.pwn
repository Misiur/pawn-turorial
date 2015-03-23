#include <a_samp>

#undef MAX_PLAYERS
#define MAX_PLAYERS 10

#include <sscanf2>

#include <YSI\y_iterate>
#include <YSI\y_commands>

#define MAX_ADMIN_LEVEL 5

new
    bool:Logged[MAX_PLAYERS],
    AdminLevel[MAX_PLAYERS]
;

main() {
}

public OnPlayerConnect(playerid)
{
    Logged[playerid] = true;
    AdminLevel[playerid] = MAX_ADMIN_LEVEL / 3;

    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    Logged[playerid] = false;
    AdminLevel[playerid] = 0;

    return 1;
}

YCMD:hello_admin(playerid, params[], help)
{
    if (help) {
        return SendClientMessage(playerid, 0xBADA55, "Says hello to speficied admin");
    }

    new
        target = 0
    ;

    if (sscanf(params, "u", target)) return SendClientMessage(playerid, 0xBADA55, "You dun goof'd");
    if (target == INVALID_PLAYER_ID || !Logged[target] || !AdminLevel[target]) return SendClientMessage(playerid, 0xBADA55, "You dun goof'd");

    SendClientMessage(target, 0xBADA55, "Hello mr admin!");
    SendClientMessage(playerid, 0xBADA55, "You said hello to admins!");

    return 1;
}

YCMD:hello_admins(playerid, params[], help)
{
    if (help) {
        return SendClientMessage(playerid, 0xBADA55, "Says hello to all admins");
    }

    foreach (new player: Player) {
        if (!Logged[player] || !AdminLevel[player]) continue; 
        
        SendClientMessage(player, 0xBADA55, "Hello mr admin!");
    }

    SendClientMessage(playerid, 0xBADA55, "You said hello to admins!");

    return 1;
}