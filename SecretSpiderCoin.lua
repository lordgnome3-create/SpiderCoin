-- =====================================
-- Secret Spider Coin - Turtle WoW (1.12.1)
-- =====================================

-- Initialize SavedVariables
if not SecretSpiderCoinDB then
    SecretSpiderCoinDB = {
        balances = {},
        distributors = {}
    }
end

-- =====================================
-- Utility Functions
-- =====================================

local function PlayerName()
    return UnitName("player")
end

-- Vanilla-safe Guild Master check
local function IsGuildMaster()
    if not IsInGuild() then return false end
    local name, rank, rankIndex = GetGuildInfo("player")
    return rankIndex == 0
end

local function IsDistributor()
    return IsGuildMaster() or SecretSpiderCoinDB.distributors[PlayerName()]
end

local function AddCoins(player, amount)
    SecretSpiderCoinDB.balances[player] =
        (SecretSpiderCoinDB.balances[player] or 0) + amount
end

local function GetBalance(player)
    return SecretSpiderCoinDB.balances[player] or 0
end

-- =====================================
-- Popup Menu
-- =====================================

StaticPopupDialogs["SECRETSPIDER_COIN_MENU"] = {
    text = "Secret Spider Coin Menu",
    button1 = "OK",
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
    OnAccept = function()
        print("|cff00ff00Secret Spider Coin Commands:|r")
        print("/ssc menu")
        print("/ssc give <player> <amount>")
        print("/ssc balance [player]")
        print("/ssc authorize <player>  (Guild Master)")
        print("/ssc revoke <player>     (Guild Master)")
    end
}

-- =====================================
-- Slash Commands
-- =====================================

SLASH_SECRETSPIDERCOIN1 = "/ssc"
SlashCmdList["SECRETSPIDERCOIN"] = function(msg)
    local args = {}
    for word in string.gfind(msg, "%S+") do
        table.insert(args, word)
    end

    local cmd = args[1]

    -- Open menu
    if cmd == "menu" or cmd == nil then
        StaticPopup_Show("SECRETSPIDER_COIN_MENU")
        return
    end

    -- Give coins
    if cmd == "give" then
        if not IsDistributor() then
            print("|cffff0000You are not authorized to give Secret Spider Coins.|r")
            return
        end

        local target = args[2]
        local amount = tonumber(args[3])

        if not target or not amount or amount <= 0 then
            print("Usage: /ssc give <player> <amount>")
            return
        end

        AddCoins(target, amount)
        print("|cff00ff00Gave|r", amount, "Secret Spider Coins to", target)
        return
    end

    -- Check balance
    if cmd == "balance" then
        local target = args[2] or PlayerName()
        print(target .. " has " .. GetBalance(target) .. " Secret Spider Coins")
        return
    end

    -- Authorize distributor
    if cmd == "authorize" then
        if not IsGuildMaster() then
            print("|cffff0000Only the Guild Master can authorize distributors.|r")
            return
        end

        local target = args[2]
        if not target then
            print("Usage: /ssc authorize <player>")
            return
        end

        SecretSpiderCoinDB.distributors[target] = true
        print(target .. " is now authorized to give Secret Spider Coins")
        return
    end

    -- Revoke distributor
    if cmd == "revoke" then
        if not IsGuildMaster() then
            print("|cffff0000Only the Guild Master can revoke distributors.|r")
            return
        end

        local target = args[2]
        SecretSpiderCoinDB.distributors[target] = nil
        print(target .. " is no longer authorized")
        return
    end

    -- Help
    print("|cff00ff00Secret Spider Coin Commands:|r")
    print("/ssc menu")
    print("/ssc give <player> <amount>")
    print("/ssc balance [player]")
    print("/ssc authorize <player>")
    print("/ssc revoke <player>")
end

-- =====================================
-- Load Event
-- =====================================

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function()
    print("|cff00ff00Secret Spider Coin loaded for Turtle WoW.|r")
end)
