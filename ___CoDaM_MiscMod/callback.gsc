CodeCallback_PlayerCommand(args)
{
    if(isDefined(level.command)) {
        if ((args[0] == "say" || args[0] == "say_team")
            && (isDefined(args[1]) && args[1][0] == level.prefix)) {
            command = "";
            for(i = 1; i < args.size; i++)
                command += getSubStr(args[i], 0) + " ";

            [[ level.command ]](command);
            return;
        }
    }
    self processClientCommand();
}