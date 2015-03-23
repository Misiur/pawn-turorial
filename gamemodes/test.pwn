#include <a_samp>

#undef MAX_PLAYERS
#define MAX_PLAYERS 10

#define IsAdmin(%0) Group_GetPlayer(Admins[0], %0)

#include <sscanf2>

#include <YSI\y_iterate>
#include <YSI\y_groups>
#include <YSI\y_commands>

#define MAX_ADMIN_LEVEL 5

new
    Group:Users,
    Group:Admins[MAX_ADMIN_LEVEL]
;

static const
    adminRanks[MAX_ADMIN_LEVEL][32] = {
        "Admin level 1",
        "Admin level 2",
        "Admin level 3",
        "Admin level 4",
        "Admin level 5"
    }
;

main() {
}

CreateGroups()
{
    Users = Group_Create("Logged in players");

    for (new i = MAX_ADMIN_LEVEL - 1; i >= 0; --i) {
        Admins[i] = Group_Create(adminRanks[i]);

        if (i == MAX_ADMIN_LEVEL - 1) continue;

        Group_AddChild(Admins[i + 1], Admins[i]);
    }

    //Only logged in users can be admins!
    Group_AddChild(Users, Admins[0]);
}

ToggleDefaultGroups(playerid, bool:mode = true)
{
    Group_SetPlayer(Admins[MAX_ADMIN_LEVEL / 3], playerid, mode);
}

public OnGameModeInit()
{
    CreateGroups();
    
    AddPlayerClass(0, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);

    return 1;
}

public OnPlayerConnect(playerid)
{
    ToggleDefaultGroups(playerid);

    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    ToggleDefaultGroups(playerid, false);

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

    if (sscanf(params, "k<admin>", target) || target == INVALID_PLAYER_ID) return SendClientMessage(playerid, 0xBADA55, "You dun goof'd");

    SendClientMessage(target, 0xBADA55, "Hello mr admin!");
    SendClientMessage(playerid, 0xBADA55, "You said hello to admins!");

    return 1;
}

YCMD:hello_admins(playerid, params[], help)
{
    if (help) {
        return SendClientMessage(playerid, 0xBADA55, "Says hello to all admins");
    }

    foreach (new player: GroupMember[Admins[0]]) {
        SendClientMessage(player, 0xBADA55, "Hello mr admin!");
    }

    SendClientMessage(playerid, 0xBADA55, "You said hello to admins!");

    return 1;
}

SSCANF:admin(string[])
{
    new
        id = strval(string),
        bool:isAdmin = IsAdmin(id)
    ;

    return isAdmin ? id : INVALID_PLAYER_ID;
}