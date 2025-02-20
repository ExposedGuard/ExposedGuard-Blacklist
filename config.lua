Config = {
    ['discord'] = 'https://discord.exposedguard.dk/', -- Discord Invite Link (Invite link to the Discord server)
    ['locales'] = 'da', -- Language of the script (can be changed in the locales file)
    ['ip'] = true, -- IP Address ned to show in logs (true: shows, false: hide)
    ['logs'] = {
        ['connect'] = "https://discord.com/api/webhooks/1337202490759839784/fhEkHn8xNi7RreJi0ha4wTkxvNxYd5OQ-n3GjON1wvLNpCS0YisHGrChts6k6BUW8xea", -- Player Connect (Discord Webhook)
        ['disconnect'] = "https://discord.com/api/webhooks/1337202581377781760/r4NuO_Fp46fCS7l0lK8prrrXEaiqR3ONg_CCHWPh3TgHfegZtIx2OlztrjVgb-2wksMG", -- Player Discocnnect (Discord Webhook)
        ['blocked'] = "https://discord.com/api/webhooks/1337202526595977257/AvppP5w87_9n8My-beXikWnfOh3dM0KsKh0KLPZFG-P4s0iASnXUbDuwO7b554odHdMs", -- Blocked Connection (Discord Webhook)
    },
    ["whitelist"] = { -- All exposed users do not get kicked
        "", -- Discord ID
    }
}