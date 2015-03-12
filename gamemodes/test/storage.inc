#include <YSI\y_hooks>

#define STORAGE_ENABLED

new 
    handle
;

hook OnGameModeInit()
{
    handle = mysql_connect("localhost", "root", "test", "");
    //Do some handle checking first!

    return 1;
}


hook OnGameModeExit()
{
    mysql_close(handle);

    return 1;
}