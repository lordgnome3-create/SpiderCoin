-----------------------------------
-- SecretSpiderCoin
-----------------------------------
SecretSpiderCoin = {}
SecretSpiderCoin.coins = {}

-----------------------------------
-- Utility Functions
-----------------------------------
local function GetCoins(name)
    if not SecretSpiderCoin.coins[name] then
        SecretSpiderCoin.coins[name] = 0
    end
    return SecretSpiderCoin.coins[name]
end

local function AddCoins(name, amount)
    SecretSpiderCoin.coins[name] = GetCoins(name) + amount
end

local function RemoveCoins(name, amount)
    local newValue = GetCoins(name) - amount
    if newValue < 0 then newValue = 0 end
    SecretSpiderCoin.coins[name] = newValue
end

-----------------------------------
-- Main Frame
-----------------------------------
local frame = CreateFrame("Frame", "SecretSpiderCoinFrame", UIParent)
frame:SetWidth(420)
frame:SetHeight(300)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function() frame:StartMoving() end)
frame:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)
frame:Hide()


-----------------------------------
-- Title
-----------------------------------
local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -12)
title:SetText("Secret Spider Coin")

-----------------------------------
-- Close Button
-----------------------------------
local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", -5, -5)

-----------------------------------
-- Player Dropdown
-----------------------------------
local selectedPlayer = nil

local dropdown = CreateFrame("Frame", "SSC_PlayerDropdown", frame, "UIDropDownMenuTemplate")
dropdown:SetPoint("TOPLEFT", 20, -50)

local function GetPlayerList()
    local list = {}

    if GetNumRaidMembers() > 0 then
        for i = 1, GetNumRaidMembers() do
            local name = GetRaidRosterInfo(i)
            if name then
                table.insert(list, name)
            end
        end

    elseif GetNumPartyMembers() > 0 then
        table.insert(list, UnitName("player"))
        for i = 1, GetNumPartyMembers() do
            local name = UnitName("party"..i)
            if name then
                table.insert(list, name)
            end
        end

    elseif IsInGuild() then
        for i = 1, GetNumGuildMembers() do
            local name = GetGuildRosterInfo(i)
            if name then
                table.insert(list, name)
            end
        end
    end

    return list
end



UIDropDownMenu_Initialize(dropdown, function()
    local players = GetPlayerList()
    for i = 1, getn(players) do
        UIDropDownMenu_AddButton({
            text = players[i],
            func = function()
                selectedPlayer = players[i]
                UIDropDownMenu_SetSelectedName(dropdown, players[i])
            end
        })
    end
end)

UIDropDownMenu_SetWidth(dropdown, 160)
UIDropDownMenu_SetText(dropdown, "Select Player")

-----------------------------------
-- Amount Box
-----------------------------------
local amountBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
amountBox:SetWidth(60)
amountBox:SetHeight(20)
amountBox:SetPoint("LEFT", dropdown, "RIGHT", 20, 0)
amountBox:SetAutoFocus(false)
amountBox:SetNumeric(true)
amountBox:SetText("1")

-----------------------------------
-- Status Text
-----------------------------------
local statusText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
statusText:SetPoint("TOPLEFT", dropdown, "BOTTOMLEFT", 20, -20)
statusText:SetText("")

-----------------------------------
-- Add / Remove Buttons
-----------------------------------
local addBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
addBtn:SetWidth(80)
addBtn:SetHeight(22)
addBtn:SetPoint("TOPLEFT", statusText, "BOTTOMLEFT", 0, -10)
addBtn:SetText("Add")

addBtn:SetScript("OnClick", function()
    if selectedPlayer then
        local amt = tonumber(amountBox:GetText()) or 0
        AddCoins(selectedPlayer, amt)
        statusText:SetText(selectedPlayer.." has "..GetCoins(selectedPlayer).." (+ "..amt..")")
    end
end)

local removeBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
removeBtn:SetWidth(80)
removeBtn:SetHeight(22)
removeBtn:SetPoint("LEFT", addBtn, "RIGHT", 10, 0)
removeBtn:SetText("Remove")

removeBtn:SetScript("OnClick", function()
    if selectedPlayer then
        local amt = tonumber(amountBox:GetText()) or 0
        RemoveCoins(selectedPlayer, amt)
        statusText:SetText(selectedPlayer.." has "..GetCoins(selectedPlayer).." (- "..amt..")")
    end
end)

-----------------------------------
-- Chat Dropdown
-----------------------------------
local chatTarget = "GUILD"

local chatDrop = CreateFrame("Frame", "SSC_ChatDropdown", frame, "UIDropDownMenuTemplate")
chatDrop:SetPoint("TOPLEFT", addBtn, "BOTTOMLEFT", -15, -20)

UIDropDownMenu_Initialize(chatDrop, function()
    local channels = { "GUILD", "PARTY", "RAID" }
    for i = 1, getn(channels) do
        UIDropDownMenu_AddButton({
            text = channels[i],
            func = function()
                chatTarget = channels[i]
                UIDropDownMenu_SetSelectedName(chatDrop, channels[i])
            end
        })
    end
end)

UIDropDownMenu_SetWidth(chatDrop, 100)
UIDropDownMenu_SetText(chatDrop, "Chat")

-----------------------------------
-- Top 10 Button
-----------------------------------
local topBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
topBtn:SetWidth(120)
topBtn:SetHeight(22)
topBtn:SetPoint("LEFT", chatDrop, "RIGHT", 10, 0)
topBtn:SetText("Say Top 10")

topBtn:SetScript("OnClick", function()
    local list = {}
    for name, coins in pairs(SecretSpiderCoin.coins) do
        table.insert(list, {name=name, coins=coins})
    end

    table.sort(list, function(a,b) return a.coins > b.coins end)

    SendChatMessage("Top Secret Spider Coin Holders:", chatTarget)

    local maxEntries = 10
    if getn(list) < 10 then maxEntries = getn(list) end

    for i = 1, maxEntries do
        SendChatMessage(i..". "..list[i].name.." - "..list[i].coins, chatTarget)
    end
end)

-----------------------------------
-- Minimap Button
-----------------------------------
local mini = CreateFrame("Button", "SSC_MinimapButton", Minimap)
mini:SetWidth(32)
mini:SetHeight(32)
mini:SetPoint("TOPLEFT", Minimap, "TOPLEFT")
mini:SetNormalTexture("Interface\\Icons\\INV_Misc_Coin_01")
mini:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

mini:SetScript("OnClick", function()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end)

-----------------------------------
-- Slash Command
-----------------------------------
SLASH_SECRETSPIDERCOIN1 = "/ssc"
SlashCmdList["SECRETSPIDERCOIN"] = function(msg)
    if msg == "show" then
        frame:Show()
    end
end
