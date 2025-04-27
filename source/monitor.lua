Citizen.CreateThread(function()
    local function isWhitelisted(discordID)
        for _, id in ipairs(Config['whitelist']) do
            if id == discordID then return true end
        end
        return false
    end

    while true do
        Citizen.Wait(60000)
        
        local players = GetPlayers()
        for _, playerId in ipairs(players) do
            local identifiers = GetPlayerIdentifiers(playerId)
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

            if identifier['discord'] then
                PerformHttpRequest("https://api.exposedguard.dk/leak/get/" .. identifier['discord'], function(statusCode, responseText, headers)
                    if statusCode ~= 200 then print("[EXPOSEDGUARD] HTTP Request failed with status code: " .. statusCode) return end
                    if not responseText or responseText == "" then print("[EXPOSEDGUARD] Received empty response from API") return end
                    
                    local responseData = json.decode(responseText)
                    if not responseData then print("[EXPOSEDGUARD] Failed to decode the JSON response") return end
                
                    if not responseData['leak'] or not next(responseData['leak']) then return end
                    local leak = responseData['leak'][1]
                    
                    if leak['blacklist'] == 1 then
                        if not isWhitelisted(identifier['discord']) then
                            print(string.format("[EXPOSEDGUARD] Player %s was detected as a cheater with leak information: %s", GetPlayerName(playerId) or "Unknown", leak['cheat'] or "N/A"))
                            Logger({ ['type'] = 'disconnect', ['reason'] = "Exposed",['cheat'] = leak['cheat'],['title'] = "**PLAYER DISCONNECTED**", ['name'] = GetPlayerName(playerId), ['discord'] = identifier['discord'], ['steam'] = identifier['steam'], ['license'] = identifier['license'], ['ip'] = identifier['ip_address'] })
                            DropPlayer(playerId, "[EXPOSEDGUARD] - "..getLocaleString('kick'))
                        end
                    end
                end, 'GET', '', { ['User-Agent'] = 'exposedguard-d44bbd-eb4-d3-ca18187-4f265e-892e9-ac91-8c-b2908-b4c0dc-request' })
            else
                print("[EXPOSEDGUARD] No Discord ID found for player: " .. GetPlayerName(playerId))
            end
        end
    end
end)
