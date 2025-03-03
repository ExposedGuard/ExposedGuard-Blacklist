eg = eg or {}

function eg.checkForUpdates()
    local function strsplit(delimiter, text)
        local list = {}
        local pos = 1
        if string.find("", delimiter, 1) then
            error("delimiter matches empty string!")
        end
        while true do
            local first, last = string.find(text, delimiter, pos)
            if first then
                table.insert(list, string.sub(text, pos, first - 1))
                pos = last + 1
            else
                table.insert(list, string.sub(text, pos))
                break
            end
        end
        return list
    end

    local resource = GetInvokingResource() or GetCurrentResourceName()
    local currentVersion = GetResourceMetadata(resource, 'version', 0)

    if currentVersion then
        currentVersion = currentVersion:match('%d+%.%d+%.%d+')
    end

    if not currentVersion then return print("^1Unable to determine current resource version for '" .. resource .. "' ^0") end

    SetTimeout(1000, function()
        PerformHttpRequest('https://api.github.com/repos/ExposedGuard/ExposedGuard-Blacklist/releases/latest', function(status, response)
            if status ~= 200 then return end

            response = json.decode(response)
            if response.prerelease then return end

            local latestVersion = response.tag_name:match('%d+%.%d+%.%d+')
            if not latestVersion or latestVersion == currentVersion then return end

            local cv = strsplit('%.', currentVersion)
            local lv = strsplit('%.', latestVersion)

            for i = 1, #cv do
                local current, latest = tonumber(cv[i]), tonumber(lv[i])

                if current ~= latest then
                    if current < latest then
                        return print('^3An update is available for ' .. resource .. ' (current version: ' .. currentVersion .. ')\r\n' .. response.html_url .. '^0')
                    else break end
                end
            end
        end, 'GET')
    end)
end

eg.checkForUpdates()