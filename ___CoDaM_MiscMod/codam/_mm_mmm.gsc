/*
 * Misc Mod Misc Mod Misc (mm_mmm)
 */

// 22-10-2021: new namefix() function
namefix(playername)
{
    if(!isDefined(playername))
        return "";

    allowedchars = " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!'#[]<>/&()=?+`^~*-_.,;|$@:{}"; // " " (space) moved first as it is more frequent -- "�" removed, unknown what this char is?
    cleanedname = "";

    for(i = 0; i < playername.size; i++) {
        for(z = 0; z < allowedchars.size; z++) {
            if(playername[i] == allowedchars[z]) {
                cleanedname += playername[i];
                break;
            }
        }
    }

    return cleanedname;
}

array_shuffle(arr)
{
    if(!isDefined(arr))
        return undefined;

    for(i = 0; i < arr.size; i++) {
        _tmp = arr[i]; // Store the current array element in a variable
        rN = randomInt(arr.size); // Generate a random number
        arr[i] = arr[rN]; // Replace the current with the random
        arr[rN] = _tmp; // Replace the random with the current
    }

    return arr;
}

in_array(arr, needle)
{
    if(!isDefined(arr) || !isDefined(needle))
        return undefined;

    for(i = 0; i < arr.size; i++)
        if(arr[i] == needle)
            return true;

    return false;
}

array_join(arrTo, arrFrom)
{
    if(!isDefined(arrTo) || !isDefined(arrFrom))
        return undefined;

    for(i = 0; i < arrFrom.size; i++)
        arrTo[arrTo.size] = arrFrom[i];

    return arrTo;
}

array_remove(arr, str, r) // NEED URGENT OPTIMIZE - If set to true, it will remove previous element aswell.
{
    if(!isDefined(arr) || !isDefined(str))
        return undefined;

    if(!isDefined(r))
        r = false;

    x = 0;
    _tmpa = [];
    for(i = 0; i < arr.size; i++) {
        if(arr[i] != str) {
            _tmpa[x] = arr[i];
            x++;
        } else {
            if(r) {
                _tmpa[x - 1] = undefined;
                x--;
            }
        }
    }

    _tmp = _tmpa;

    if(r) {
        y = 0;
        _tmpb = [];
        for(i = 0; i < _tmpa.size; i++) {
            if(isDefined(_tmpa[i])) {
                _tmpb[y] = _tmpa[i];
                y++;
            }
        }

        _tmp = _tmpb;
    }

    return _tmp;
}

strip(s)
{
    if(s == "")
        return "";

    s2 = "";
    s3 = "";

    i = 0;
    while(i < s.size && s[i] == " ")
        i++;

    if(i == s.size)
        return "";

    for(; i < s.size; i++)
        s2 += s[i];

    i = (s2.size - 1);
    while(s2[i] == " " && i > 0)
        i--;

    for(j = 0; j <= i; j++)
        s3 += s2[j];

    return s3;
}

strTok(text, separator) // new attemt to fix double, tripple delimiter, etc
{
    token = 0;
    tokens = [];

    for(i = 0; i < text.size; i++) {
        if(text[i] != separator) {
            if(!isDefined(tokens[token]))
                tokens[token] = "";

            tokens[token] += text[i];
        } else {
            if(isDefined(tokens[token]))
                token++;
        }
    }

    return tokens;
}

strTru(str, len, ind)
{
    if(!isDefined(ind))
        ind = " >";

    len = len + ind.size;
    if(str.size <= len)
        return str;

    len = len - ind.size;

    new = "";
    for(i = 0; i < len; i++)
        new = new + str[i];

    return new + ind;
}

isBoltWeapon(sWeapon)
{
    switch(sWeapon) {
        case "enfield_mp":
        //case "fg42_mp":
        //case "fg42_semi_mp":
        case "kar98k_mp":
        case "kar98k_sniper_mp":
        case "mosin_nagant_mp":
        case "mosin_nagant_sniper_mp":
        case "springfield_mp":
        return true;
    }

    return false;
}

// Spawn an object and attach a sound to it, POWERSERVER
PlaySoundAtLocation(sound, location, iTime)
{
    org = spawn("script_model", location);
    wait 0.05;
    org show();
    org playSound(sound);
    wait iTime;
    org delete();
    return;
}

compassdb(id)
{
    if(!isDefined(level.compassdb)) {
        level.compassdb = [];
        for(i = 0; i <= 15; i++) // 16 objects
            level.compassdb[i] = -1;
    }

    if(!isDefined(id)) { // generate an ID
        for(i = 2; i < level.compassdb.size; i++) { // bomb zones
            if(level.compassdb[i] == -1) {
                level.compassdb[i] = i;
                return i;
            }
        }
    } else if(id >= 0) { // delete ID
        level.compassdb[id] = -1;
    } else if(id == -1) { // clear "database"
        for(i = 0; i <= 15; i++) // 16 objects
            level.compassdb[i] = -1;
    }

    return -1; // -1 on no ID available
}

weaponremoval() // from Cheese
{
    deletePlacedEntity("mpweapon_m1carbine");
    deletePlacedEntity("mpweapon_m1garand");
    deletePlacedEntity("mpweapon_thompson");
    deletePlacedEntity("mpweapon_bar");
    deletePlacedEntity("mpweapon_springfield");
    deletePlacedEntity("mpweapon_enfield");
    deletePlacedEntity("mpweapon_sten");
    deletePlacedEntity("mpweapon_bren");
    deletePlacedEntity("mpweapon_mosinnagant");
    deletePlacedEntity("mpweapon_ppsh");
    deletePlacedEntity("mpweapon_mosinnagantsniper");
    deletePlacedEntity("mpweapon_kar98k");
    deletePlacedEntity("mpweapon_mp40");
    deletePlacedEntity("mpweapon_mp44");
    deletePlacedEntity("mpweapon_kar98k_scoped");
    deletePlacedEntity("mpweapon_fg42");
    deletePlacedEntity("mpweapon_panzerfaust");
    deletePlacedEntity("mpweapon_stielhandgranate");
    deletePlacedEntity("mpweapon_fraggrenade");
    deletePlacedEntity("mpweapon_mk1britishfrag");
    deletePlacedEntity("mpweapon_russiangrenade");
    deletePlacedEntity("mpweapon_colt");
    deletePlacedEntity("mpweapon_luger");

    deletePlacedEntity("item_ammo_stielhandgranate_closed");
    deletePlacedEntity("item_ammo_stielhandgranate_open");
    deletePlacedEntity("item_health");
    deletePlacedEntity("item_health_large");
    deletePlacedEntity("item_health_small");

    deletePlacedEntity("misc_mg42");
    deletePlacedEntity("misc_turret");
}

monotone(str, loop)
{
    if(!isDefined(str))
        return "";

    _str = "";
    for(i = 0; i < str.size; i++) {
        if(str[i] == "^" &&
            ((i + 1) < str.size &&
                (validate_number(str[i + 1]))
            )) {
            i++;
            continue;
        }

        _str += str[i];
    }

    if(!isDefined(loop))
        _str = monotone(_str, true);

    return _str;
}

getPlayersByName(n1)
{
    a = [];
    p = getOnlinePlayers();
    for(i = 0; i < p.size; i++) {
        n2 = monotone(p[i].name);
        n2 = strip(n2);
        if(n2.size >= n1.size) {
            if(pmatch(tolower(n2), tolower(n1)))
                a[a.size] = p[i];
        }
    }

    return a;
}

pmatch(s, p)
{
    if(p.size > s.size)
        return false;

    o = 0;
    while(o <= (s.size - p.size)) {
        for(i = 0; i < p.size; i++)
            if(p[i] != s[i + o])
                break;

        if(i == p.size)
            return true;

        o++;
    }

    return false;
}

validate_number(input, isfloat)
{
    if(!isDefined(input))
        return false;

    input += ""; // convert to str

    if(!isDefined(isfloat))
        isfloat = false;

    hasdot = false;
    for(i = 0; i < input.size; i++) {
        switch(input[i]) {
            case "0": case "1": case "2":
            case "3": case "4": case "5":
            case "6": case "7": case "8":
            case "9":
            break;
            case ".": // 0.1..., no need for .1 etc yet... but could be validated by removing i == 0
                if(!isfloat || i == 0 || (i + 1) == input.size || hasdot)
                    return false;

                hasdot = true;
            break;
            case "-": // allow "negative" numbers
                if(i == 0 && input.size > 1) //if(i == 0 && input.size > 1 && input[i] == "-")
                    break;
            default:
                return false;
        }
    }

    return true;
}

getOnlinePlayers() // get all online players, apparently getEntArray doesn't list 999/connecting players
{
    p = [];

    maxclients = GetCvarInt("sv_maxClients");
    if(maxclients < 0 || maxclients > 64)
        return p;

    for(i = 0; i < maxclients; i++) {
        player = GetEntByNum(i);
        if(isDefined(player))
            p[p.size] = player;
    }

    return p;
}

deletePlacedEntity(sEntityType)
{
    eEntities = getEntArray(sEntityType, "classname");
    for(i = 0; i < eEntities.size; i++)
        eEntities[i] delete();
}


_newspawn(spawnpoint, recursive)
{
    recursive = isDefined(recursive);
    if(!recursive)
        newspawn = [];

    for(i = 0; i < 360; i += 36) {
        angle = (0, i, 0);

        trace = bulletTrace(spawnpoint.origin, spawnpoint.origin + maps\mp\_utility::vectorscale(anglesToForward(angle), 48), true, self);
        if(trace["fraction"] == 1 && !positionWouldTelefrag(trace["position"]) && _canspawnat(trace["position"])) {
            newspawnpoint = spawnStruct();
            newspawnpoint.origin = trace["position"];
            newspawnpoint.angles = angle;
            return newspawnpoint;
        }

        if(!recursive) {
            newspawnpoint = spawnStruct();
            newspawnpoint.origin = trace["position"];
            newspawnpoint.angles = angle;
            newspawn[newspawn.size] = newspawnpoint;
        }

        wait 0.05;
    }

    if(!recursive) {
        for(j = 0; j < newspawn.size; j++) {
            newspawnpoint = self _newspawn(newspawn[j], true);
            if(isDefined(newspawnpoint))
                return newspawnpoint;
        }

        return spawnpoint; // giving up, push anyways
    }

    return undefined;
}

_canspawnat(position)
{
    position = position + (-16, -16, 0);
    for(x = 0; x < 32; x++) {
        for(y = 0; y < 32; y++) {
            trace = bulletTrace(position + (x, y, 0), position + (x, y, 72), true, self);
            if(trace["fraction"] != 1)
                return false;
        }
    }

    return true;
}

freezePlayer(time)
{
    object = spawn("script_origin", self.origin);
    self linkTo(object);

    while(time != 0) {
        wait 1;
        time--;
    }

    self unlink();
    object delete();
}

_tmpHudsForFunEvent()
{
    wait 0.5;
    if(!isDefined(level.tmpHudsForFunEvent)) {
        level.tmpHudsForFunEvent = newHudElem();
        level.tmpHudsForFunEvent.archived = false;
        level.tmpHudsForFunEvent.x = 320;
        level.tmpHudsForFunEvent.y = 40;
        level.tmpHudsForFunEvent.alignX = "center";
        level.tmpHudsForFunEvent.alignY = "middle";
        level.tmpHudsForFunEvent.sort = 9500;
        level.tmpHudsForFunEvent.fontScale = 3.0;
        level.tmpHudsForFunEvent.color = (1, 0.2, 0);
        level.tmpHudsForFunEvent setText(&"Please wait...");

        players = getEntArray("player", "classname");
        for(i = 0; i < players.size; i++) {
            players[i].sessionstate = "spectator";
            players[i].spectatorclient = -1;

            resettimeout();

            players[i] setClientCvar("g_scriptMainMenu", "");
            players[i] closeMenu();
        }
    } else
        level.tmpHudsForFunEvent destroy();
}

vectorScale(vec, scale)
{
    vec = (vec[0] * scale, vec[1] * scale, vec[2] * scale);
    return vec;
}

isPrimaryWeapon(sWeapon)
{
    if(!isDefined(sWeapon)) return false;
    switch(sWeapon) {
        // rifles
        case "mosin_nagant_mp":
        case "kar98k_mp":
        case "enfield_mp":
        // snipers
        case "mosin_nagant_sniper_mp":
        case "kar98k_sniper_mp":
        case "springfield_mp":
        // semi auto
        case "m1carbine_mp":
        case "m1garand_mp":
        // full auto
        case "ppsh_mp":
        case "thompson_mp":
        case "mp40_mp":
        case "sten_mp":
        // heavy
        case "mp44_mp":
        case "bar_mp":
        case "bren_mp":
        // extra
        case "fg42_mp":
        case "panzerfaust_mp":
            return true;
    }

    return false;
}

isSecondaryWeapon(sWeapon)
{
    if(!isDefined(sWeapon)) return false;
    switch(sWeapon) {
        case "colt_mp":
        case "luger_mp":
            return true;
    }

    return false;
}

isGrenade(sWeapon)
{
    if(!isDefined(sWeapon)) return false;
    switch(sWeapon) {
        // german
        case "stielhandgranate_mp":
        // russian
        case "rgd-33russianfrag_mp":
        // british
        case "mk1britishfrag_mp":
        // american
        case "fraggrenade_mp":
            return true;
    }

    return false;
}

mmlog(msg)
{
    printconsole(msg + "\n");
    logPrint(msg + "\n");
}

message_player(msg, player)
{
    if(!isDefined(player))
        player = self;

    player sendservercommand("i \"^7^7" + level.nameprefix + ": ^7" + msg + "\""); // ^7^7 fixes spaces problem
}

message(msg)
{
    sendservercommand("i \"^7^7" + level.nameprefix + ": ^7" + msg + "\""); // ^7^7 fixes spaces problem
}

playerByNum(num)
{
    if(validate_number(num)) {
        if(((int)num >= 0 || (int)num <= 64)) {
            player = GetEntByNum(num);
            if(isPlayer(player))
                return player;
        }
    }

    return undefined;
}

aAn(word, upper)
{
    if(word.size < 1)
        return "";

    upper = (bool)isDefined(upper);
    switch(word[0]) {
        case "a": case "e": case "i": case "o": case "u":
        case "A": case "E": case "I": case "O": case "U":
            if(upper)
                return "An";
            return "an";
    }

    if(upper)
        return "A";
    return "a";
}

numdigits(num)
{
    return (num + "").size;
}

pow(base, exponent) { // https://github.com/thecheeseman/1.1libraries/blob/db526226c3ec3a4dd2112ff0e937b73e3c606a56/code/math.gsc#L110-L124
    _res = 1;

    if(exponent == 0)
        return _res;

    _neg = exponent < 0;

    if(_neg)
        exponent *= -1;

    for(i = 0; i < exponent; i++)
        _res *= base;

    if(_neg)
        return 1 / _res;

    return _res;
}