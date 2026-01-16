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
frame:SetHeight(550)
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
-- Player Selection (Simple Text + Buttons)
-----------------------------------
local selectedPlayer = nil

local playerLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
playerLabel:SetPoint("TOPLEFT", 20, -50)
playerLabel:SetText("Player:")

local playerText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
playerText:SetPoint("LEFT", playerLabel, "RIGHT", 10, 0)
playerText:SetText("None Selected")

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
        local pname = UnitName("player")
        if pname then
            table.insert(list, pname)
        end

        for i = 1, GetNumPartyMembers() do
            local member = UnitName("party"..i)
            if member then
                table.insert(list, member)
            end
        end

    elseif IsInGuild() then
        for i = 1, GetNumGuildMembers() do
            local gname = GetGuildRosterInfo(i)
            if gname then
                table.insert(list, gname)
            end
        end
    end

    return list
end

local playerListFrame = CreateFrame("Frame", "SSC_PlayerList", frame)
playerListFrame:SetWidth(200)
playerListFrame:SetHeight(150)
playerListFrame:SetPoint("TOPLEFT", 20, -80)
playerListFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
playerListFrame:Hide()

local playerButtons = {}
for i = 1, 10 do
    local btn = CreateFrame("Button", "SSC_PlayerBtn"..i, playerListFrame)
    btn:SetWidth(180)
    btn:SetHeight(20)
    btn:SetPoint("TOPLEFT", 10, -10 - (i-1)*20)
    
    local btnText = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    btnText:SetPoint("LEFT", 5, 0)
    btn.text = btnText
    
    btn:SetScript("OnClick", function()
        selectedPlayer = this.text:GetText()
        playerText:SetText(selectedPlayer)
        playerListFrame:Hide()
    end)
    
    btn:Hide()
    playerButtons[i] = btn
end

local selectPlayerBtn = CreateFrame("Button", "SSC_SelectPlayer", frame, "UIPanelButtonTemplate")
selectPlayerBtn:SetWidth(100)
selectPlayerBtn:SetHeight(22)
selectPlayerBtn:SetPoint("LEFT", playerText, "RIGHT", 10, 0)
selectPlayerBtn:SetText("Select")

selectPlayerBtn:SetScript("OnClick", function()
    if playerListFrame:IsShown() then
        playerListFrame:Hide()
    else
        local players = GetPlayerList()
        for i = 1, 10 do
            if i <= table.getn(players) then
                playerButtons[i].text:SetText(players[i])
                playerButtons[i]:Show()
            else
                playerButtons[i]:Hide()
            end
        end
        playerListFrame:Show()
    end
end)

-----------------------------------
-- Amount Box
-----------------------------------
local amountLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
amountLabel:SetPoint("TOPLEFT", 20, -240)
amountLabel:SetText("Amount:")

local amountBox = CreateFrame("EditBox", "SSC_AmountBox", frame, "InputBoxTemplate")
amountBox:SetWidth(60)
amountBox:SetHeight(20)
amountBox:SetPoint("LEFT", amountLabel, "RIGHT", 10, 0)
amountBox:SetAutoFocus(false)
amountBox:SetNumeric(true)
amountBox:SetText("1")

-----------------------------------
-- Top 15 List
-----------------------------------
local top15Label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
top15Label:SetPoint("TOPLEFT", 240, -50)
top15Label:SetText("Top 15 Players")

local top15Frame = CreateFrame("Frame", "SSC_Top15Frame", frame)
top15Frame:SetWidth(160)
top15Frame:SetHeight(320)
top15Frame:SetPoint("TOPLEFT", 240, -75)
top15Frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})

local top15Lines = {}
for i = 1, 15 do
    local line = top15Frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    line:SetPoint("TOPLEFT", 8, -8 - (i-1)*20)
    line:SetText("")
    line:SetJustifyH("LEFT")
    top15Lines[i] = line
end

local function UpdateTop15()
    local list = {}
    for name, coins in pairs(SecretSpiderCoin.coins) do
        table.insert(list, {name=name, coins=coins})
    end
    
    table.sort(list, function(a,b) return a.coins > b.coins end)
    
    for i = 1, 15 do
        if i <= table.getn(list) then
            top15Lines[i]:SetText(i..". "..list[i].name.." - "..list[i].coins)
        else
            top15Lines[i]:SetText("")
        end
    end
end

-- Call UpdateTop15 initially
UpdateTop15()

-----------------------------------
-- Status Text
-----------------------------------
local statusText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
statusText:SetPoint("TOPLEFT", 20, -270)
statusText:SetText("")

-----------------------------------
-- Add / Remove Buttons
-----------------------------------
local addBtn = CreateFrame("Button", "SSC_AddBtn", frame, "UIPanelButtonTemplate")
addBtn:SetWidth(80)
addBtn:SetHeight(22)
addBtn:SetPoint("TOPLEFT", 20, -290)
addBtn:SetText("Add")

addBtn:SetScript("OnClick", function()
    if selectedPlayer then
        local amt = tonumber(amountBox:GetText()) or 0
        AddCoins(selectedPlayer, amt)
        statusText:SetText(selectedPlayer.." has "..GetCoins(selectedPlayer).." (+ "..amt..")")
        UpdateTop15()
    else
        statusText:SetText("Please select a player first")
    end
end)

local removeBtn = CreateFrame("Button", "SSC_RemoveBtn", frame, "UIPanelButtonTemplate")
removeBtn:SetWidth(80)
removeBtn:SetHeight(22)
removeBtn:SetPoint("LEFT", addBtn, "RIGHT", 10, 0)
removeBtn:SetText("Remove")

removeBtn:SetScript("OnClick", function()
    if selectedPlayer then
        local amt = tonumber(amountBox:GetText()) or 0
        RemoveCoins(selectedPlayer, amt)
        statusText:SetText(selectedPlayer.." has "..GetCoins(selectedPlayer).." (- "..amt..")")
        UpdateTop15()
    else
        statusText:SetText("Please select a player first")
    end
end)

-----------------------------------
-- Chat Target Selection
-----------------------------------
local chatTarget = "GUILD"

local chatLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
chatLabel:SetPoint("LEFT", removeBtn, "RIGHT", 20, 0)
chatLabel:SetText("Chat:")

local chatText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
chatText:SetPoint("LEFT", chatLabel, "RIGHT", 5, 0)
chatText:SetText("GUILD")

local chatBtn = CreateFrame("Button", "SSC_ChatBtn", frame, "UIPanelButtonTemplate")
chatBtn:SetWidth(70)
chatBtn:SetHeight(22)
chatBtn:SetPoint("LEFT", chatText, "RIGHT", 5, 0)
chatBtn:SetText("Change")

local chatIndex = 1
local chatChannels = { "GUILD", "PARTY", "RAID" }

chatBtn:SetScript("OnClick", function()
    chatIndex = chatIndex + 1
    if chatIndex > table.getn(chatChannels) then
        chatIndex = 1
    end
    chatTarget = chatChannels[chatIndex]
    chatText:SetText(chatTarget)
end)

-----------------------------------
-- Top 10 Button
-----------------------------------
local topBtn = CreateFrame("Button", "SSC_TopBtn", frame, "UIPanelButtonTemplate")
topBtn:SetWidth(120)
topBtn:SetHeight(22)
topBtn:SetPoint("TOP", 0, -520)
topBtn:SetText("Say Top 10")

topBtn:SetScript("OnClick", function()
    local list = {}
    for name, coins in pairs(SecretSpiderCoin.coins) do
        table.insert(list, {name=name, coins=coins})
    end

    table.sort(list, function(a,b) return a.coins > b.coins end)

    SendChatMessage("Top Secret Spider Coin Holders:", chatTarget)

    local maxEntries = 10
    if table.getn(list) < 10 then maxEntries = table.getn(list) end

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
mini:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -10, 10)
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
