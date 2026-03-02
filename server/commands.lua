lib.addCommand('freezetime', {
    help = 'Freeze Time',
    restricted = 'group.admin'
}, function(source, args, raw)
    SYNC:FreezeTime()
end)

lib.addCommand('freezeweather', {
    help = 'Freeze the Weather',
    restricted = 'group.admin'
}, function(source, args, raw)
    SYNC:FreezeWeather()
end)


lib.addCommand('weather', {
    help = 'Set Weather',
    params = {
        {
            name = 'type',
            type = 'string',
            help = 'EXTRASUNNY, CLEAR, NEUTRAL, SMOG, FOGGY, OVERCAST, CLOUDS, CLEARING, RAIN, THUNDER, SNOW, BLIZZARD, SNOWLIGHT, XMAS, HALLOWEEN',
        },
    },
    restricted = 'group.admin'
}, function(source, args, raw)
    for _, v in pairs(AvailableWeatherTypes) do
        if args.type:upper() == v then
            SYNC.Set:Weather(args.type)
        end
    end
end)

lib.addCommand('time', {
    help = 'Set Time',
    params = {
        {
            name = 'type',
            type = 'string',
            help = 'MORNING, NOON, EVENING, NIGHT',
        },
    },
    restricted = 'group.admin'
}, function(source, args, raw)
    SYNC.Set:TimeType(args.type, 0)
end)

lib.addCommand('clock', {
    help = 'Set Specific Hour',
    params = {
        {
            name = 'hour',
            type = 'number',
            help = '0 - 23',
        },
    },
    restricted = 'group.admin'
}, function(source, args, raw)
    SYNC.Set:Time(tonumber(args.hour), 0)
end)

lib.addCommand('blackout', {
    help = 'Toggle Blackout',
    restricted = 'group.admin'
}, function(source, args, raw)
    SYNC.Set:Blackout()
end)
