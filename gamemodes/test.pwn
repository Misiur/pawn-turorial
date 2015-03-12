#include <a_samp>
#include <a_mysql>

forward OnPlayerLoaded(playerid);
forward OnHousesLoaded();

#define MAX_HOUSES      300
#define MAX_HOUSE_NAME  32
#define COLOUR_INFO     0xBADA55FF

enum E_HOUSE
{
    hdbID,
    hOwner[MAX_PLAYER_NAME + 1],
    hName[MAX_HOUSE_NAME],
    hOwned
}

enum E_PLAYER
{
    pdbID,
    pName[MAX_PLAYER_NAME + 1],
    pHouse1,
    pHouse2
}

new
    handle,
    House[MAX_HOUSES][E_HOUSE],
    Player[MAX_PLAYERS][E_PLAYER]
;

public OnGameModeInit()
{
    handle = mysql_connect("localhost", "root", "test", "");
    //Do some handle checking first!

    LoadHouses();

    return 1;
}

public OnPlayerConnect(playerid)
{
    new
        query[128]
    ;

    GetPlayerName(playerid, Player[playerid][pName], MAX_PLAYER_NAME);
    mysql_format(handle, query, sizeof query, "SELECT * FROM playerid WHERE name = %e", Player[playerid][pName]);
    mysql_tquery(handle, query, "OnPlayerLoaded", "d", "playerid");

    return 1;
}

public OnPlayerLoaded(playerid)
{
    new
        string[64]
    ;

    if (!cache_get_row_count(handle)) {
        SendClientMessage(playerid, COLOUR_INFO, "Sorry, manually added players only!");
        return Kick(playerid);
    }

    Player[playerid][pHouse1] = cache_get_field_content_int(0, "house1", handle);
    Player[playerid][pHouse2] = cache_get_field_content_int(0, "house2", handle);

    for (new house = 0; house != MAX_HOUSES; ++house) {
        if (House[house][hOwned]) {
            if (Player[playerid][pHouse1] == house) {
                format(string, sizeof string, "You own house named %s", House[house][hName]);
                SendClientMessage(playerid, COLOUR_INFO, string);
            }
        }
    }

    return 1;
}

LoadHouses()
{    
    new
        query[128]
    ;

    mysql_format(handle, query, sizeof query, "SELECT * FROM houses");
    mysql_tquery(handle, query, "OnHousesLoaded");
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
        House[row][hOwned] = cache_get_field_content_int(row, "owned", handle);
    }

    return 1;
}

public OnGameModeExit()
{
    mysql_close(handle);

    return 1;
}