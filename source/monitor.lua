function isWhitelisted(discordID)
    for _, id in ipairs(Config['whitelist']) do
        if id == discordID then return true end
    end
    return false
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        
        local players = {}
        for _, playerId in ipairs(GetPlayers()) do table.insert(players, { id = playerId, name = GetPlayerName(playerId), identifiers = GetPlayerIdentifiers(playerId) }) end

        for _, playerData in ipairs(players) do
            local identifier = { discord = nil, license = nil, steam = nil, ip_address = nil }
    
            for _, id in ipairs(playerData['identifiers']) do
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

            if identifier['discord'] then
                PerformHttpRequest("https://api.exposedguard.dk/leak/get/" .. identifier['discord'] , function(statusCode, responseText, headers)
                    if statusCode ~= 200 then print("[EXPOSEDGUARD] HTTP Request failed with status code: " .. statusCode) return end
                    if not responseText or responseText == "" then print("[EXPOSEDGUARD] Received empty response from API") return end
                    
                    local responseData = json.decode(responseText)
                    if not responseData then print("[EXPOSEDGUARD] Failed to decode the JSON response") return end
                
                    if not responseData['leak'] or not next(responseData['leak']) then return end
                    local leak = responseData['leak'][1]
                    
                    if leak['blacklist'] == 1 then
                        if not isWhitelisted(identifier['discord']) then
                            if playerData['id'] then
                                print(string.format("[EXPOSEDGUARD] Player %s was detected as a cheater with leak information: %s", playerData['name'] or "Unknown", leak['cheat'] or "N/A"))
                                Logger({ ['type'] = 'disconnect', ['reason'] = "Exposed",['cheat'] = leak['cheat'],['title'] = "**PLAYER DISCONNECTED**", ['name'] = GetPlayerName(playerData['id']), ['discord'] = identifier['discord'], ['steam'] = identifier['steam'], ['license'] = identifier['license'], ['ip'] = identifier['ip_address'] })
                                DropPlayer(playerData['id'], "[EXPOSEDGUARD] - You have been identified as a cheater based on leaked information and have been kicked. Please reconnect for more details.")
                            end
                        end
                    end
                end, 'GET')
            else
                print("[EXPOSEDGUARD] No Discord ID found for player: " .. playerData['name'])
            end
        end
    end
end)
