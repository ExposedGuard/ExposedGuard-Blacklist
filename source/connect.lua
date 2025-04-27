AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    deferrals.defer()
    deferrals.update("[EXPOSEDGUARD]: " .. getLocaleString('deferrals.1'))
    
    local player = source
    local identifiers = GetPlayerIdentifiers(player)
    local identifier = { discord = nil, license = nil, steam = nil, ip_address = nil }
    
    for _, id in ipairs(identifiers) do
        if id:find("discord:") then
            identifier.discord = id:gsub("discord:", "")
        elseif id:find("license:") then
            identifier.license = id:gsub("license:", "")
        elseif id:find("steam:") then
            identifier.steam = id:gsub("steam:", "")
        elseif id:find("ip:") then
            identifier.ip_address = id:gsub("ip:", "")
        end
    end
    
    if not identifier['discord'] or identifier['discord'] == "" then
        deferrals.done("[EXPOSEDGUARD] " .. getLocaleString('errors.discord')) return end
    
    deferrals.update("[EXPOSEDGUARD] " .. getLocaleString('deferrals.2'))
    print(string.format("[EXPOSEDGUARD] Player connecting: %s", GetPlayerName(player)))
    Logger({ ['type'] = "connect", ['reason'] = "Connect", ['title'] = "**PLAYER JOINED**", ['name'] = GetPlayerName(player), ['discord'] = identifier['discord'], ['steam'] = identifier['steam'], ['license'] = identifier['license'], ['ip'] = identifier['ip_address'] })
    
    PerformHttpRequest("https://api.exposedguard.dk/leak/get/" .. identifier['discord'], function(err, text, headers)
        if err ~= 200 then 
            print("[EXPOSEDGUARD] HTTP Request Failed with error code: " .. err)
            deferrals.done("[EXPOSEDGUARD]: " .. getLocaleString('errors.api')) return end
    
        if not text or text == "" then 
            print("[EXPOSEDGUARD] Empty response from API")
            deferrals.done("[EXPOSEDGUARD]: " .. getLocaleString('errors.api')) return end
        
        local data = json.decode(text)
        if not data then 
            print("[EXPOSEDGUARD]: Failed to decode JSON response") 
            deferrals.done("[EXPOSEDGUARD]: " .. getLocaleString('errors.json')) return end

        if not data['leak'] or not next(data['leak']) then deferrals.done() return end
        local leak = data['leak'][1]
        
        if leak['blacklist'] == 1 then 
            local function isWhitelisted(discordID)
                for _, id in ipairs(Config['whitelist']) do
                    if id == discordID then return true end
                end
                return false
            end

            if not isWhitelisted(identifier['discord']) then
                print(string.format("[EXPOSEDGUARD] Blocked connection: %s", GetPlayerName(player)))

                Wait(150)
                deferrals.presentCard(json.encode({
                    type = "AdaptiveCard",
                    version = "1.0",
                    body = {
                        { type = "TextBlock", text = "ExposedGuard.dk", weight = "Default", size = "Medium", wrap = true, horizontalAlignment = "Center", spacing = "Medium" },
                        { type = "TextBlock", text = "You are blacklisted by ExposedGuard", weight = "Bolder", size = "ExtraLarge", wrap = true, horizontalAlignment = "Center", spacing = "None" },
                        { type = "ActionSet", horizontalAlignment = "Center", spacing = "Medium", actions = { { type = "Action.Submit", title = "Associated Cheat: " .. leak['cheat'], isEnabled = false, data = {} } } },
                        { type = "TextBlock", text = "If you believe this is a mistake or have any questions open a ticket on our Discord server.", weight = "Bolder", color = "Warning", size = "Medium", wrap = true, horizontalAlignment = "Center", spacing = "Medium" },
                        { type = "ActionSet", horizontalAlignment = "Center", spacing = "Medium", actions = {
                            { type = "Action.OpenUrl", title = "ExposedGuard.dk", url = "https://www.exposedguard.dk", iconUrl  = 'https://cdn.discordapp.com/emojis/1334893976972558417.webp?size=80' },
                            { type = "Action.OpenUrl", title = "ExposedGuard Discord", url = "https://discord.exposedguard.dk", iconUrl  = 'https://cdn.discordapp.com/emojis/1334893976972558417.webp?size=80' },
                            { type = "Action.OpenUrl", title = "Discord", url = Config['discord'], iconUrl  = 'https://static.vecteezy.com/system/resources/previews/006/892/625/large_2x/discord-logo-icon-editorial-free-vector.jpg' }
                        }}
                    }
                }))
                
                Logger({ ['type'] = 'blocked', ['reason'] = "Blocked", ['cheat'] = leak['cheat'], ['title'] = "**BLOCKED CONNECTION**", ['name'] = name, ['discord'] = identifier['discord'], ['steam'] = identifier['steam'], ['license'] = identifier['license'], ['ip'] = identifier['ip_address'] })
                Wait(5000)
                return
            else
                deferrals.done()
            end
        else
            deferrals.done()
        end
    end, 'GET', '', { ['User-Agent'] = 'exposedguard-d44bbd-eb4-d3-ca18187-4f265e-892e9-ac91-8c-b2908-b4c0dc-request' })
end)