CodeCallback_PlayerCommand(str) // add to callback.gsc
{
    if(isDefined(level.command))
    {
        [[ level.command ]](str);
        return;
    }
    self processClientCommand();
}