-- ==================================================
-- Secret Spider Coin v6.4 (Turtle WoW / Vanilla)
-- ==================================================

SSC_PREFIX = "SSC"

-- ======================
-- SavedVariables
-- ======================

if not SecretSpiderCoinDB then
    SecretSpiderCoinDB = {
        balances = {},
        distributors = {},
        guildMaster = nil,
        history = {}
    }
end

-- ======================
-- Utilities
-- ======================

local function Player()
    return UnitName("player")
end

local function IsVanillaGuildMaster()
    if not IsInGuild() then return false end
    local _, _, rankIndex = GetGuildInfo("player")
    return rankIndex == 0
end

local function IsGuildMaster()
    return SecretSpiderCoinDB.guildMaster == Player()
end

local function IsAuthorized()
    return IsGuildMaster() or SecretSpiderCoinDB.distributors[Player()]
end

local function Log(msg)
    table.insert(SecretSpiderCoinDB.history, date("%H:%M:%S ") .. msg)
end

-- ======================
-- Guild Master Lock
-- ======================

local function InitGuildMaster()
    if not SecretSpiderCoinDB.guildMaster and IsVanillaGuildMaster() then
        SecretSpiderCoinDB.guildMaster = Player()
        print("|cff00ff00[SSC]|r Guild Master locked to " .. Player())
    end
end

-- ======================
-- Communication
-- ======================

local function Broadcast(msg)
    if IsInGuild() then
        SendAddonMessage(SSC_PREFIX, msg, "GUILD")
    end
end

-- ======================
-- Coin Logic
-- ======================

local function AddCoins(name, amount)
    local new = (SecretSpiderCoinDB.balances[name] or 0) + amount
    SecretSpiderCoinDB.balances[name] = new
    Log(Player() .. " changed " .. name .. " by " .. amount)
    Broadcast("SET|" .. name .. "|" .. new)
    -- Feedback message
    local action = amount > 0 and "added" or "removed"
    print("|cff00ff00[SSC]|r " .. math.abs(amount) .. " coins " .. action .. " for " .. name .. ". New balance: " .. new)
end

-- ======================
-- Announcements
-- ======================

local function AnnounceBalance(name, channel)
    SendChatMessage(
        name .. " has " .. (SecretSpiderCoinDB.balances[name] or 0) .. " Secret Spider Coins",
        channel
    )
end

local function AnnounceTop10(channel)
    local list = {}
    for n, a in pairs(SecretSpiderCoinDB.balances) do
        table.insert(list, {n=n, a=a})
    end
    table.sort(list, function(x, y) return x.a > y.a end)

    SendChatMessage("Top 10 Secret Spider Coins:", channel)
    for i = 1, math.min(10, table.getn(list)) do
        SendChatMessage(i .. ". " .. list[i].n .. " - " .. list[i].a, channel)
    end
end

-- ======================
-- Group Member List (nil-safe)
-- ======================

local function GetGroupMembers()
    local members = {}

    if GetNumRaidMembers() > 0 then
        for i = 1, GetNumRaidMembers() do
            local name = UnitName("raid"..i)
            if name then
                table.insert(members, name)
            end
        end
    elseif GetNumPartyMembers() > 0 then
        local pname = Player()
        if pname then table.insert(members, pname) end
        for i = 1, GetNumPartyMembers() do
            local name = UnitName("party"..i)
            if name then
                table.insert(members, name)
            end
        end
    else
        local pname = Player()
        if pname then table.insert(members, pname) end
    end

    return members
end

-- ======================
-- Main Window
-- ======================

local SSC_Frame = CreateFrame("Frame","SSC_MainFrame",UIParent)
SSC_Frame:SetWidth(320)
SSC_Frame:SetHeight(220)
SSC_Frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
SSC_Frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
SSC_Frame:SetMovable(true)
SSC_Frame:EnableMouse(true)
SSC_Frame:RegisterForDrag("LeftButton")
SSC_Frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
SSC_Frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
SSC_Frame:Hide()

-- Title
local title = SSC_Frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", SSC_Frame, "TOP", 0, -15)
title:SetText("Secret Spider Coin")

-- Close Button [X]
local closeBtn = CreateFrame("Button", "SSC_CloseButton", SSC_Frame, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", SSC_Frame, "TOPRIGHT", -5, -5)
closeBtn:SetScript("OnClick", function() SSC_Frame:Hide() end)

-- ======================
-- Dropdown
-- ======================

SSC_Frame.selected = Player()

local dropdown = CreateFrame("Frame","SSC_Dropdown",SSC_Frame,"UIDropDownMenuTemplate")
dropdown:SetPoint("TOP", SSC_Frame, "TOP", 0, -45)

local function RefreshDropdown()
    UIDropDownMenu_Initialize(dropdown, function()
        local members = GetGroupMembers()
        for _, name in ipairs(members) do
            local info = {}
            info.text = name
            info.func = function()
                SSC_Frame.selected = name
                UIDropDownMenu_SetText(name, dropdown)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetWidth(160, dropdown)
    UIDropDownMenu_SetText(SSC_Frame.selected, dropdown) -- show selected
end

-- ======================
-- Amount Box
-- ======================

local amountBox = CreateFrame("EditBox", nil, SSC_Frame, "InputBoxTemplate")
amountBox:SetPoint("TOP", SSC_Frame, "TOP", 0, -85)
amountBox:SetWidth(80)
amountBox:SetHeight(20)
amountBox:SetAutoFocus(false)

local amountLabel = SSC_Frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
amountLabel:SetPoint("BOTTOM", amountBox, "TOP", 0, 5)
amountLabel:SetText("Amount")

-- ======================
-- Buttons
-- ======================

local function MakeButton(text, x, y, handler)
    local b = CreateFrame("Button", nil, SSC_Frame, "UIPanelButtonTemplate")
    b:SetText(text)
    b:SetWidth(110)
    b:SetHeight(24)
    b:SetPoint("TOP", SSC_Frame, "TOP", x, y)
    b:SetScript("OnClick", handler)
end

MakeButton("Add Coins", -70, -130, function()
    if not IsAuthorized() then return end
    local amt = tonumber(amountBox:GetText())
    if amt then AddCoins(SSC_Frame.selected, amt) end
end)

MakeButton("Remove Coins", 70, -130, function()
    if not IsAuthorized() then return end
    local amt = tonumber(amountBox:GetText())
    if amt then AddCoins(SSC_Frame.selected, -amt) end
end)

MakeButton("Announce (Guild)", -70, -165, function()
    AnnounceBalance(SSC_Frame.selected, "GUILD")
end)

MakeButton("Top 10 (Guild)", 70, -165, function()
    AnnounceTop10("GUILD")
end)

-- ======================
-- Slash Command
-- ======================

SLASH_SSC1 = "/ssc"
SlashCmdList["SSC"] = function(msg)
    msg = string.lower(msg)
    if msg == "show" then
        RefreshDropdown()
        SSC_Frame:Show()
    elseif msg == "close" then
        SSC_Frame:Hide()
    elseif msg == "history" then
        for _, v in ipairs(SecretSpiderCoinDB.history) do
            print(v)
        end
    else
        print("|cff00ff00[SSC]|r Use /ssc show or /ssc close")
    end
end

-- ======================
-- Events
-- ======================

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("CHAT_MSG_ADDON")

f:SetScript("OnEvent", function(_, event, arg1, arg2)
    if event=="ADDON_LOADED" and arg1=="SecretSpiderCoin" then
        InitGuildMaster()
        RegisterAddonMessagePrefix(SSC_PREFIX)
        print("|cff00ff00Secret Spider Coin loaded. Use /ssc show|r")
    end

    if event=="CHAT_MSG_ADDON" and arg1==SSC_PREFIX then
        local cmd,name,amt = strsplit("|",arg2)
        if cmd=="SET" then
            SecretSpiderCoinDB.balances[name] = tonumber(amt)
        end
    end
end)
