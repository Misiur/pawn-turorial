#include <YSI\y_hooks>
#include <YSI\y_utils>
#include <YSI\y_iterate>

forward OnHousesLoaded();

#define HOUSES_ENABLED

#define MAX_HOUSES          300
#define MAX_HOUSE_NAME      32
#define INVALID_HOUSE_INDEX -1
#define MAX_PLAYER_HOUSES   2

enum E_HOUSE
{
    hdbID,
    hName[MAX_HOUSE_NAME + 1],
    hOwner[MAX_PLAYER_NAME + 1]
}

new   
    House[MAX_HOUSES][E_HOUSE],
    Iterator:House<MAX_HOUSES>,
    
    PlayerHouse[MAX_PLAYERS][MAX_PLAYER_HOUSES],
    Iterator:PlayerHouse[MAX_PLAYERS]<MAX_PLAYER_HOUSES>
;

hook OnGameModeInit()
{
    Iter_Init(PlayerHouse);

    memset(PlayerHouse[0], INVALID_HOUSE_INDEX, MAX_PLAYERS * MAX_PLAYER_HOUSES);

    LoadHouses();

    return 1;
}

hook OnPlayerConnect(playerid)
{
    new
        string[64],
        ownedBy[MAX_PLAYER_NAME + 1]
    ;

    foreach(new house : House)
    {
        if (ismysqlnull(House[house][hOwner])) {
            strcpy(ownedBy, "nobody");
        } else {
            strcpy(ownedBy, House[house][hOwner]);
        }

        format(string, sizeof string, "House %s is owned by %s", House[house][hName], ownedBy);
        SendClientMessage(playerid, COLOUR_INFO, string);
    }

    return 1;
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
        Iter_Add(House, row);
    }

    return 1;
}

stock LoadHouses()
{
    mysql_tquery(handle, "SELECT h.*, p.name AS player_name FROM houses h LEFT JOIN player_houses ph ON ph.house_id = h.id LEFT JOIN players p ON p.id = ph.player_id", "OnHousesLoaded");
}

AddPlayerHouse(playerid, index, house) {
    PlayerHouse[playerid][index] = house;
}

stock LoadPlayerHouses(playerid)
{
    new 
        string[64]
    ;

    for(new playerHouse = 0; playerHouse != MAX_PLAYER_HOUSES; ++playerHouse)
    {
        foreach(new house : House)
        {
            if (PlayerHouse[playerid][playerHouse] == House[house][hdbID]) {
                PlayerHouse[playerid][playerHouse] = house;
                Iter_Add(PlayerHouse[playerid], playerHouse);

                break;
            }
        }
    }

    foreach(new house : PlayerHouse[playerid])
    {
        format(string, sizeof string, "You own house named %s", House[house][hName]);
        SendClientMessage(playerid, COLOUR_INFO, string);
    }
}