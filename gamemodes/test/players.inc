#include <YSI\y_hooks>

#define PLAYERS_ENABLED

forward OnPlayerLoaded(playerid);

enum E_PLAYER
{
    pdbID,
    pName[MAX_PLAYER_NAME + 1]
}

new
    Player[MAX_PLAYERS][E_PLAYER]
;

hook OnPlayerConnect(playerid)
{
    new
        query[140]
    ;

    GetPlayerName(playerid, Player[playerid][pName], MAX_PLAYER_NAME);
    mysql_format(handle, query, sizeof query, "SELECT p.*, ph.house_id AS house FROM players p LEFT JOIN player_houses ph ON ph.player_id = p.id WHERE p.name = '%e' LIMIT 1", Player[playerid][pName]);
    mysql_tquery(handle, query, "OnPlayerLoaded", "d", playerid);

    return 1;
}

public OnPlayerLoaded(playerid)
{
    new
        rows = cache_get_row_count(handle)
    ;

    if (!rows) {
        SendClientMessage(playerid, COLOUR_INFO, "Sorry, manually added players only!");
        return Kick(playerid);
    }

    #if defined HOUSES_ENABLED
    for (new row = 0; row != rows; ++row) {
        AddPlayerHouse(playerid, row, cache_get_field_content_int(row, "house", handle));    
    }

    LoadPlayerHouses(playerid);
    #endif

    return 1;
}