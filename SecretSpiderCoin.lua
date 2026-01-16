-- ==================================================
-- Secret Spider Coin v10.0 (Turtle WoW / Vanilla)
-- Includes minimap icon and forced /ssc show fix
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
        history = {},
        minimap = { hide = false },
    }
end

-- ======================
-- Utilities
-- ======================
local function Player() return UnitName("player") end
local function IsVanillaGuildMaster()
    if not IsInGuild() then return false end
    local _, _, rankIndex = GetGuildInfo("player")
    return rankIndex == 0
end
local function IsGuildMaster() return SecretSpiderCoinDB.guildMaster == Player() end
local function IsAuthorized() return IsGuildMaster() or SecretSpiderCoinDB.distributors[Player()] end
local function Log(msg) table.insert(SecretSpiderCoinDB.history, date("%H:%M:%S ") .. msg) end

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
    if IsInGuild() then SendAddonMessage(SSC_PREFIX, msg, "GUILD") end
end
local function SendToChannel(msg, channel) SendChatMessage(msg, channel) end

-- ======================
-- Coin Logic
-- ======================
local function AddCoins(name, amount)
    local current = SecretSpiderCoinDB.balances[name] or 0
    local new = current + amount
    SecretSpiderCoinDB.balances[name] = new
    Log(Player() .. " changed " .. name .. " by " .. amount)
    Broadcast("SET|" .. name .. "|" .. new)
    local action = amount > 0 and "added" or "removed"
    print("|cff00ff00[SSC]|r " .. math.abs(amount) .. " coins " .. action .. " for " .. name .. ". New balance: " .. new)
end

-- ======================
-- Announcements
-- ======================
local function AnnounceBalance(name, channel)
    SendToChannel(name .. " has " .. (SecretSpiderCoinDB.balances[name] or 0) .. " Secret Spider Coins", channel)
end
local function AnnounceTop10(channel)
    local list = {}
    for n, a in pairs(SecretSpiderCoinDB.balances) do table.insert(list, {n=n, a=a}) end
    table.sort(list, function(x, y) return x.a > y.a end)
    SendToChannel("Top 10 Secret Spider Coins:", channel)
    for i = 1, math.min(10, #list) do
        SendToChannel(i .. ". " .. list[i].n .. " - " .. list[i].a, channel)
    end
end

-- ======================
-- Group Members
-- ======================
local function GetGroupMembers()
    local members = {}
    if GetNumRaidMembers() > 0 then
        for i = 1, GetNumRaidMembers() do
            local name = UnitName("raid"..i)
            if name then table.insert(members, name) end
        end
    elseif GetNumPartyMembers() > 0 then
        table.insert(members, Player())
        for i = 1, GetNumPartyMembers() do
            local name = UnitName("party"..i)
            if name then table.insert(members, name) end
        end
    else
        table.insert(members, Player())
    end
    return members
end

-- ======================
-- Main Frame
-- ======================
local SSC_Frame, dropdown, selectedBox, amountBox, channelDropdown
local function CreateSSCFrame()
    if SSC_Frame then return end -- already created

    SSC_Frame = CreateFrame("Frame","SSC_MainFrame",UIParent)
    SSC_Frame:SetWidth(420)
    SSC_Frame:SetHeight(280)
    SSC_Frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    SSC_Frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    SSC_Frame:EnableMouse(true)
    SSC_Frame:SetMovable(true)
    SSC_Frame:SetUserPlaced(true)
    SSC_Frame:RegisterForDrag("LeftButton")
    SSC_Frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    SSC_Frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    SSC_Frame:Hide()

    -- Title
    local title = SSC_Frame:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
    title:SetPoint("TOP",SSC_Frame,"TOP",0,-15)
    title:SetText("Secret Spider Coin")

    -- Close [X]
    local closeBtn = CreateFrame("Button", nil, SSC_Frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", SSC_Frame, "TOPRIGHT", -5, -5)
    closeBtn:SetScript("OnClick", function() SSC_Frame:Hide() end)

    -- Dropdown
    SSC_Frame.selected = Player()
    dropdown = CreateFrame("Frame","SSC_Dropdown",SSC_Frame,"UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", SSC_Frame, "TOPLEFT", 20, -45)
    selectedBox = SSC_Frame:CreateFontString(nil,"OVERLAY","GameFontNormal")
    selectedBox:SetPoint("LEFT", dropdown, "RIGHT", 20, 0)
    selectedBox:SetText("Selected: "..SSC_Frame.selected)

    -- Amount Box
    amountBox = CreateFrame("EditBox", nil, SSC_Frame, "InputBoxTemplate")
    amountBox:SetPoint("TOPLEFT", dropdown, "BOTTOMLEFT", 0, -25)
    amountBox:SetWidth(80)
    amountBox:SetHeight(20)
    amountBox:SetAutoFocus(false)
    local amountLabel = SSC_Frame:CreateFontString(nil,"OVERLAY","GameFontNormal")
    amountLabel:SetPoint("BOTTOM", amountBox, "TOP", 0, 5)
    amountLabel:SetText("Amount")

    -- Channel Dropdown
    channelDropdown = CreateFrame("Frame","SSC_ChannelDropdown",SSC_Frame,"UIDropDownMenuTemplate")
    channelDropdown:SetPoint("LEFT", amountBox, "RIGHT", 20, 0)
    SSC_Frame.channel = "GUILD"

    -- Buttons
    local function MakeButton(text, x, y, handler)
        local b = CreateFrame("Button", nil, SSC_Frame, "UIPanelButtonTemplate")
        b:SetText(text)
        b:SetWidth(110)
        b:SetHeight(24)
        b:SetPoint("TOP", SSC_Frame, "TOP", x, y)
        b:SetScript("OnClick", handler)
    end

    MakeButton("Add Coins", -90, -130, function()
        if not IsAuthorized() then return end
        local amt = tonumber(amountBox:GetText())
        if amt then AddCoins(SSC_Frame.selected, amt) end
    end)

    MakeButton("Remove Coins", 90, -130, function()
        if not IsAuthorized() then return end
        local amt = tonumber(amountBox:GetText())
        if amt then AddCoins(SSC_Frame.selected, -amt) end
    end)

    MakeButton("Announce Balance", -90, -165, function()
        AnnounceBalance(SSC_Frame.selected, SSC_Frame.channel)
    end)

    MakeButton("Top 10", 90, -165, function()
        AnnounceTop10(SSC_Frame.channel)
    end)
end

-- ======================
-- Refresh Dropdowns
-- ======================
local function RefreshDropdown()
    if not SSC_Frame then return end
    UIDropDownMenu_Initialize(dropdown, function(self, level)
        local members = GetGroupMembers()
        for i,name in ipairs(members) do
            local info = {}
            info.text = name
            info.value = name
            info.func = function()
                SSC_Frame.selected = name
                UIDropDownMenu_SetSelectedID(dropdown,i)
                UIDropDownMenu_SetText(name,dropdown)
                selectedBox:SetText("Selected: "..name)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetWidth(160,dropdown)
    UIDropDownMenu_SetText(SSC_Frame.selected,dropdown)
    selectedBox:SetText("Selected: "..SSC_Frame.selected)
end

local function RefreshChannelDropdown()
    local channels = {"GUILD","PARTY","RAID","SAY"}
    UIDropDownMenu_Initialize(channelDropdown,function(self,level)
        for i,ch in ipairs(channels) do
            local info={}
            info.text = ch
            info.value = ch
            info.func = function()
                SSC_Frame.channel = ch
                UIDropDownMenu_SetText(ch,channelDropdown)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetWidth(100,channelDropdown)
    UIDropDownMenu_SetText(SSC_Frame.channel,channelDropdown)
end

-- ======================
-- Force Open Function
-- ======================
local function OpenSSCFrame()
    if not SSC_Frame then CreateSSCFrame() end
    RefreshDropdown()
    RefreshChannelDropdown()
    SSC_Frame:Show()
end

-- ======================
-- Minimap Icon
-- ======================
local LDBIcon = CreateFrame("Button", "SSC_MinimapButton", Minimap)
LDBIcon:SetSize(30,30)
LDBIcon:SetPoint("TOPLEFT", Minimap, "TOPLEFT")
LDBIcon:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
local iconTexture = LDBIcon:CreateTexture(nil,"BACKGROUND")
iconTexture:SetAllPoints()
iconTexture:SetTexture("Interface\\Icons\\INV_Misc_Coin_01")
LDBIcon:SetScript("OnClick", function() OpenSSCFrame() end)
LDBIcon:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
    GameTooltip:SetText("Secret Spider Coin")
    GameTooltip:AddLine("Click to open menu")
    GameTooltip:Show()
end)
LDBIcon:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- ======================
-- Events
-- ======================
local f=CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("CHAT_MSG_ADDON")
f:SetScript("OnEvent", function(_,event,arg1,arg2)
    if event=="ADDON_LOADED" and arg1=="SecretSpiderCoin" then
        InitGuildMaster()
        RegisterAddonMessagePrefix(SSC_PREFIX)
        if not SSC_Frame then CreateSSCFrame() end

        -- Slash Command fixed
        SLASH_SSC1="/ssc"
        SlashCmdList["SSC"]=function(msg)
            msg=string.lower(msg)
            if msg=="show" then OpenSSCFrame()
            elseif msg=="close" then SSC_Frame:Hide()
            elseif msg=="history" then
                for _,v in ipairs(SecretSpiderCoinDB.history) do print(v) end
            else
                print("|cff00ff00[SSC]|r Use /ssc show or /ssc close")
            end
        end

        print("|cff00ff00Secret Spider Coin loaded. Use /ssc show|r")
    end

    if event=="CHAT_MSG_ADDON" and arg1==SSC_PREFIX then
        local cmd,name,amt=strsplit("|",arg2)
        if cmd=="SET" then SecretSpiderCoinDB.balances[name]=tonumber(amt) end
    end
end)
