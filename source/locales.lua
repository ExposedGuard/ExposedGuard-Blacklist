local localeData = {}

function locale() 
    local file = LoadResourceFile(GetCurrentResourceName(), ('locales/%s.json'):format(Config['locales']))
        or LoadResourceFile(GetCurrentResourceName(), ('locales/%s.json'):format("en"))

    if file then
        localeData = json.decode(file)
    else
        localeData = {}
    end
end

locale()

function getLocaleString(key)
    local keys = {}
    for part in string.gmatch(key, "[^%.]+") do
        table.insert(keys, part)
    end

    local value = localeData
    for _, k in ipairs(keys) do
        if value[k] then
            value = value[k]
        else
            return "Missing locale string for key: " .. key
        end
    end

    return value
end