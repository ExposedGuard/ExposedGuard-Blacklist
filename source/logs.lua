function Logger(data)
    local embed = { { title = data['title'] or "No Title Given", color = data['color'] or 0x1a1a1a, footer = { text = os.date("%A, %d %B %Y, %X") }, fields = {} }}
    
    local fields = {
        { name = "**REASON**", value = data['reason'] or "Not specified", inline = true },
        { name = "**NAME**", value = data['name'] or "Unk   nown", inline = true },
        { name = "**DISCORD**", value = data['discord'] and "<@" .. data['discord'] .. ">" or "Not linked", inline = true },
        { name = "**STEAM**", value = data['steam'] and ('[' .. data['steam'] .. '](https://steamcommunity.com/profiles/' .. tostring(tonumber(data['steam'], 16)) .. ')') or "Not linked", inline = true },
        { name = "**LICENSE**", value = data['license'], inline = true }
    }
    for _, field in ipairs(fields) do table.insert(embed[1]['fields'], field) end
    
    if data.type == 'blocked' or data.type == 'disconnect' then table.insert(embed[1]['fields'], { name = "**CHEAT**", value = data.cheat or "Unknown", inline = true }) end
    
    local ip = { name = "**IP ADDRESS**", value = Config['ip'] and ("||[" .. data['ip'] .. "](https://ip-api.com/#" .. data['ip'] .. ")||") or "||[hidden](https://ip-api.com/#hidden)||", inline = true }
    table.insert(embed[1]['fields'], ip)
    
    PerformHttpRequest(Config['logs'][data['type']], function(err, text, headers)
        if err == 404 then
            print('[' .. GetCurrentResourceName() .. ']: Error sending to webhook, error code 404')
        end
    end, 'POST', json.encode({ embeds = embed }), { ['Content-Type'] = 'application/json' })
end
