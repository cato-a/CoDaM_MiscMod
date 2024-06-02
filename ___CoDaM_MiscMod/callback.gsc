CodeCallback_PlayerCommand(args)
{
    if(isDefined(level.command)) {
        if(args[0] == "say" || args[0] == "say_team") {
            if(!isDefined(args[1])) {
                return;
            }

            command = "";
            for(i = 1; i < args.size; i++) {
                command += args[i];
                if(i < args.size - 1) {
                    command += " ";
                }
            }
            
            cmd = codam\_mm_mmm::strip(args[1]);
            if(cmd[0] == level.prefix) {
                [[ level.command ]](command);

                return;
            }

            if(codam\_mm_commands::command_mute(command)) {
                return;
            }
        }
    }

    self processClientCommand();
}