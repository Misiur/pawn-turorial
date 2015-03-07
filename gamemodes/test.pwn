#include <a_samp>
#include <a_mysql>
#include <YSI\y_iterate>

forward LoadHousesCallback();

#define MAX_HOUSES 10
#define MAX_HOUSE_NAME (32 + 1)

enum E_HOUSE
{
    hdbID,
    hName[MAX_HOUSE_NAME]
}

new
    handle,
    Iterator:Houses<MAX_HOUSES>,
    Houses[MAX_HOUSES][E_HOUSE]
;

public OnGameModeInit()
{
    handle = mysql_connect("localhost", "root", "test", "");
    //Do some handle checking first!

    LoadHouses();
}

LoadHouses()
{
    mysql_tquery(handle, "SELECT * FROM houses", "LoadHousesCallback");
}

public LoadHousesCallback()
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

        Houses[row][hdbID] = cache_get_field_content_int(row, "id", handle);
        cache_get_field_content(row, "name", Houses[row][hName], handle, MAX_HOUSE_NAME);
        Iter_Add(Houses, row);
    }

    foreach(new house : Houses) {
        printf("%d. DbID %d, name %s", house + 1, Houses[house][hdbID], Houses[house][hName]);
    }

    return 1;
}

public OnGameModeExit()
{
    mysql_close(handle);

    return 1;
}

main() {
}