#include <a_samp>
#include <YSI\y_utils>

#include <a_mysql>

forward OnPlayerLoaded(playerid);
forward OnHousesLoaded();

#define MAX_HOUSES          300
#define MAX_HOUSE_NAME      32
#define INVALID_HOUSE_INDEX -1
#define MAX_PLAYER_HOUSES   2

#define COLOUR_INFO     0xBADA55FF


enum E_HOUSE
{
    hdbID,
    hName[MAX_HOUSE_NAME + 1],
    hOwner[MAX_PLAYER_NAME + 1]
}

enum E_PLAYER
{
    pdbID,
    pName[MAX_PLAYER_NAME + 1]
}

new
    handle,
    House[MAX_HOUSES][E_HOUSE],
    Player[MAX_PLAYERS][E_PLAYER],
    PlayerHouse[MAX_PLAYERS][MAX_PLAYER_HOUSES]
;

public OnGameModeInit()
{
    handle = mysql_connect("localhost", "root", "test", "");
    //Do some handle checking first!

    memset(PlayerHouse[0], 0, MAX_PLAYERS * MAX_PLAYER_HOUSES);

    LoadHouses();

    return 1;
}

public OnPlayerConnect(playerid)
{
    new
        query[140]
    ;

    GetPlayerName(playerid, Player[playerid][pName], MAX_PLAYER_NAME);
    mysql_format(handle, query, sizeof query, "SELECT p.*, ph.house_id FROM players p LEFT JOIN player_houses ph ON ph.player_id = p.id WHERE p.name = %e LIMIT 1", Player[playerid][pName]);
    mysql_tquery(handle, query, "OnPlayerLoaded", "d", "playerid");

    //Reuse them apples
    for (new house = 0; house != MAX_HOUSES; ++house) {
        format(query, sizeof query, "House %s is owned by %s", House[house][hName], House[house][hOwner]);
        SendClientMessage(playerid, COLOUR_INFO, query);
    }

    return 1;
}

public OnPlayerLoaded(playerid)
{
    new
        string[64],
        rows = cache_get_row_count(handle)
    ;

    if (!rows) {
        SendClientMessage(playerid, COLOUR_INFO, "Sorry, manually added players only!");
        return Kick(playerid);
    }

    for (new row = 0; row != rows; ++row) {
        PlayerHouse[playerid][row] = cache_get_field_content_int(row, "house", handle);        
    }

    for (new house = 0; house != MAX_HOUSES; ++house) {
        for (new playerHouse = 0; playerHouse != MAX_PLAYER_HOUSES; ++playerHouse) {
            if (PlayerHouse[playerid][playerHouse] == House[house][hdbID]) {
                format(string, sizeof string, "You own house named %s", House[house][hName]);
                SendClientMessage(playerid, COLOUR_INFO, string);
            }
        }
    }

    return 1;
}

LoadHouses()
{
    mysql_tquery(handle, "SELECT h.*, p.name AS player_name FROM houses h LEFT JOIN player_houses ph ON ph.house_id = h.id INNER JOIN players p ON p.id = ph.player_id", "OnHousesLoaded");
}

public OnHousesLoaded()
{
    new
        rows = cache_get_row_count(handle)
    ;

    if (!rows) return print("It seems there are no house rows, sorry");

    for (new row = 0; row != rows; ++row) 
    {
        if (row == MAX_HOUSES) {
            printf("Number of houses in your database (%d) is larger than " #MAX_HOUSES " slots can handle", rows);

            //We can't load remaining rows :(
            break;
        }

        House[row][hdbID] = cache_get_field_content_int(row, "id", handle);
        cache_get_field_content(row, "name", House[row][hName], handle, MAX_HOUSE_NAME);
        cache_get_field_content(row, "player_name", House[row][hOwner], handle, MAX_PLAYER_NAME);
    }

    return 1;
}

public OnGameModeExit()
{
    mysql_close(handle);

    return 1;
}