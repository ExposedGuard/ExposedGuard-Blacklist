AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    deferrals.defer()
    deferrals.update("[EXPOSEDGUARD]: Verifying your Discord ID. Please wait...")
    
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
        deferrals.done("[EXPOSEDGUARD] A valid Discord identifier is required to join this server. Please ensure Discord is running and try again.") return end
    
    deferrals.update("[EXPOSEDGUARD] Checking your account in our system. This may take a moment...")
    print(string.format("[EXPOSEDGUARD] Player connecting: %s", GetPlayerName(player)))
    Logger({ ['type'] = "connect", ['reason'] = "Connect", ['title'] = "**PLAYER JOINED**", ['name'] = GetPlayerName(player), ['discord'] = identifier['discord'], ['steam'] = identifier['steam'], ['ip'] = identifier['ip_address'] })

    
    PerformHttpRequest("https://api.exposedguard.dk/leak/get/" .. identifier['discord'], function(err, text, headers)
        if err ~= 200 then print("[EXPOSEDGUARD] HTTP Request Failed with error code: " .. err)
            deferrals.done("[EXPOSEDGUARD]: We are currently unable to verify your account. Please try again later.") return end
    
        if not text or text == "" then print("[EXPOSEDGUARD] Empty response from API")
            deferrals.done("[EXPOSEDGUARD]: We are currently unable to verify your account. Please try again later.") return end
        
        local data = json.decode(text)
        if not data then print("[EXPOSEDGUARD]: Failed to decode JSON response") 
            deferrals.done("[EXPOSEDGUARD]: An error occurred while processing your request. Please try again later.") return end

        if not data['leak'] or not next(data['leak']) then deferrals.done() return end
        local leak = data['leak'][1]
        
        if leak['blacklistet'] == 1 then 
            print(string.format("[EXPOSEDGUARD] Blocked connection: %s", GetPlayerName(player)))
            deferrals.done(string.format(
                "\n\n[EXPOSEDGUARD] Access Denied\n\nYour account has been flagged for prohibited activities.\nDetected Issue: %s\n\nIf you believe this is an error, please contact support for assistance.\nDiscord: https://discord.exposedguard.dk/", 
                leak.cheat or "Unknown"
            ))
            Logger({ ['type'] = 'blocked', ['reason'] = "Blocked", ['cheat'] = leak['cheat'], ['title'] = "**BLOCKED CONNECTION**", ['name'] = name, ['discord'] = identifier['discord'], ['steam'] = identifier['steam'], ['ip'] = identifier['ip_address'] })
            return
        else
            deferrals.done()
        end
    end, 'GET')
end)