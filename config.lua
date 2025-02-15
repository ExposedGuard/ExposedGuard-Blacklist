Config = {
    ['ip'] = true, -- IP Address ned to show in logs (true: shows, false: hide)
    ['logs'] = {
        ['connect'] = "", -- Player Connect (Discord Webhook)
        ['disconnect'] = "", -- Player Discocnnect (Discord Webhook)
        ['blocked'] = "", -- Blocked Connection (Discord Webhook)
    },
    ["whitelist"] = { -- All exposed users do not get kicked
        "", -- Discord ID
    }
}
