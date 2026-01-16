-- ==================================================
-- Secret Spider Coin v4.0 (Turtle WoW / Vanilla)
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

local function SetCoins(name, amount)
    SecretSpiderCoinDB.balances[name] = amount
end

local function AddCoins(name, amount)
    local new = (SecretSpiderCoinDB.balances[name] or 0) + amount
    SecretSpiderCoinDB.balances[name] = new
    Log(Player() .. " changed " .. name .. " by " .. amount)
    Broadcast("SET|" .. name .. "|" .. new)
end

-- ======================
-- Announcements
-- ======================

local function AnnounceBalance(name, channel)
    SendChatMessage(
        name .. " has " ..
        (SecretSpiderCoinDB.balances[name] or 0) ..
        " Secret Spider Coins",
        channel
    )
end

local function AnnounceTop10(channel)
    local list = {}
    for n,a in pairs(SecretSpiderCoinDB.balances) do
        table.insert(list,{n=n,a=a})
    end
    table.sort(list,function(x,y) return x.a>y.a end)

    SendChatMessage("Top 10 Secret Spider Coins:",channel)
    for i=1, math.min(10,getn(list)) do
        SendChatMessage(i..". "..list[i].n.." - "..list[i].a,channel)
    end
end

-- ======================
-- Group Member List
-- ======================

local function GetGroupMembers()
    local members = {}

    if GetNumRaidMembers() > 0 then
        for i=1, GetNumRaidMembers() do
            table.insert(members, UnitName("raid"..i))
        end
    elseif GetNumPartyMembers() > 0 then
        table.insert(members, Player())
        for i=1, GetNumPartyMembers() do
            table.insert(members, UnitName("party"..i))
        end
    else
        table.insert(members, Player())
    end

    return members
end

-- ======================
-- Main Window
-- ======================

local SSC_Frame = CreateFrame("Frame","SSC_MainFrame",UIParent)
SSC_Frame:SetWidth(300)
SSC_Frame:SetHeight(200)
SSC_Frame:SetPoint("CENTER")
SSC_Frame:SetBackdrop({
    bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
    tile=true, tileSize=32, edgeSize=32,
    insets={left=11,right=12,top=12,bottom=11}
})
SSC_Frame:Hide()
SSC_Frame:SetMovable(true)
SSC_Frame:EnableMouse(true)
SSC_Frame:RegisterForDrag("LeftButton")
SSC_Frame:SetScript("OnDragStart", function() this:StartMoving() end)
SSC_Frame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)

SSC_Frame.title = SSC_Frame:CreateFontString(nil,"OVERLAY","GameFontNormal")
SSC_Frame.title:SetPoint("TOP",0,-15)
SSC_Frame.title:SetText("Secret Spider Coin")

-- Dropdown
SSC_Frame.selected = Player()

SSC_Frame.drop = CreateFrame("Frame","SSC_Dropdown",SSC_Frame,"UIDropDownMenuTemplate")
SSC_Frame.drop:SetPoint("TOP",-10,-40)

local function DropInit()
    local info = {}
    for _,name in ipairs(GetGroupMembers()) do
        info.text = name
        info.func = function()
            SSC_Frame.selected = name
            UIDropDownMenu_SetText(name, SSC_Frame.drop)
        end
        UIDropDownMenu_AddButton(info)
    end
end

UIDropDownMenu_Initialize(SSC_Frame.drop, DropInit)
UIDropDownMenu_SetWidth(150, SSC_Frame.drop)
UIDropDownMenu_SetText(Player(), SSC_Frame.drop)

-- Amount box
SSC_Frame.amount = CreateFrame("EditBox",nil,SSC_Frame,"InputBoxTemplate")
