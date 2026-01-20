-----------------------------------
-- SecretSpiderCoin
-----------------------------------
SecretSpiderCoin = {}
SecretSpiderCoin.coins = {}
SecretSpiderCoin.lastWhisper = nil

-----------------------------------
-- Saved Variables
-----------------------------------
local function LoadData()
    if SecretSpiderCoinDB then
        SecretSpiderCoin.coins = SecretSpiderCoinDB
    end
end

local function SaveData()
    SecretSpiderCoinDB = SecretSpiderCoin.coins
end

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
    SaveData()
end

local function RemoveCoins(name, amount)
    local newValue = GetCoins(name) - amount
    SecretSpiderCoin.coins[name] = newValue
    SaveData()
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
    
    -- First, add all players who have coins
    for name, coins in pairs(SecretSpiderCoin.coins) do
        if type(coins) == "number" and coins > 0 then
            table.insert(list, name)
        end
    end

    -- Add friends list
    for i = 1, GetNumFriends() do
        local fname = GetFriendInfo(i)
        if fname then
            local alreadyInList = false
            for j = 1, table.getn(list) do
                if list[j] == fname then
                    alreadyInList = true
                    break
                end
            end
            if not alreadyInList then
                table.insert(list, fname)
            end
        end
    end

    -- Add guild members
    if IsInGuild() then
        for i = 1, GetNumGuildMembers() do
            local gname = GetGuildRosterInfo(i)
            if gname then
                local alreadyInList = false
                for j = 1, table.getn(list) do
                    if list[j] == gname then
                        alreadyInList = true
                        break
                    end
                end
                if not alreadyInList then
                    table.insert(list, gname)
                end
            end
        end
    end

    -- Add players from raid
    if GetNumRaidMembers() > 0 then
        for i = 1, GetNumRaidMembers() do
            local name = GetRaidRosterInfo(i)
            if name then
                local alreadyInList = false
                for j = 1, table.getn(list) do
                    if list[j] == name then
                        alreadyInList = true
                        break
                    end
                end
                if not alreadyInList then
                    table.insert(list, name)
                end
            end
        end

    elseif GetNumPartyMembers() > 0 then
        -- Add yourself
        local pname = UnitName("player")
        if pname then
            local alreadyInList = false
            for j = 1, table.getn(list) do
                if list[j] == pname then
                    alreadyInList = true
                    break
                end
            end
            if not alreadyInList then
                table.insert(list, pname)
            end
        end

        -- Add party members
        for i = 1, GetNumPartyMembers() do
            local member = UnitName("party"..i)
            if member then
                local alreadyInList = false
                for j = 1, table.getn(list) do
                    if list[j] == member then
                        alreadyInList = true
                        break
                    end
                end
                if not alreadyInList then
                    table.insert(list, member)
                end
            end
        end
    end
    
    -- Sort the list alphabetically
    table.sort(list)

    return list
end

local playerListFrame = CreateFrame("Frame", "SSC_PlayerList", frame)
playerListFrame:SetWidth(200)
playerListFrame:SetHeight(200)
playerListFrame:SetPoint("TOPLEFT", 20, -80)
playerListFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
playerListFrame:Hide()

-- Scroll frame
local scrollFrame = CreateFrame("ScrollFrame", "SSC_PlayerScrollFrame", playerListFrame)
scrollFrame:SetWidth(170)
scrollFrame:SetHeight(180)
scrollFrame:SetPoint("TOPLEFT", 10, -10)

-- Scroll child (content frame)
local scrollChild = CreateFrame("Frame", "SSC_PlayerScrollChild", scrollFrame)
scrollChild:SetWidth(170)
scrollChild:SetHeight(1)
scrollFrame:SetScrollChild(scrollChild)

-- Scroll bar
local scrollBar = CreateFrame("Slider", "SSC_PlayerScrollBar", scrollFrame)
scrollBar:SetPoint("TOPRIGHT", playerListFrame, "TOPRIGHT", -5, -15)
scrollBar:SetPoint("BOTTOMRIGHT", playerListFrame, "BOTTOMRIGHT", -5, 15)
scrollBar:SetWidth(16)
scrollBar:SetBackdrop({
    bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
    edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
    tile = true, tileSize = 8, edgeSize = 8,
    insets = { left = 3, right = 3, top = 6, bottom = 6 }
})
scrollBar:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
scrollBar:SetMinMaxValues(0, 1)
scrollBar:SetValueStep(1)
scrollBar:SetValue(0)
scrollBar:SetScript("OnValueChanged", function()
    scrollFrame:SetVerticalScroll(this:GetValue())
end)

local playerButtons = {}
local allPlayerNames = {}

local function UpdatePlayerList()
    -- Clear old buttons
    for i = 1, table.getn(playerButtons) do
        playerButtons[i]:Hide()
    end
    
    allPlayerNames = GetPlayerList()
    local numPlayers = table.getn(allPlayerNames)
    
    -- Adjust scroll child height
    local contentHeight = numPlayers * 20
    if contentHeight < 180 then contentHeight = 180 end
    scrollChild:SetHeight(contentHeight)
    
    -- Update scroll bar
    local maxScroll = contentHeight - 180
    if maxScroll < 0 then maxScroll = 0 end
    scrollBar:SetMinMaxValues(0, maxScroll)
    scrollBar:SetValue(0)
    
    -- Create or update buttons
    for i = 1, numPlayers do
        if not playerButtons[i] then
            local btn = CreateFrame("Button", "SSC_PlayerBtn"..i, scrollChild)
            btn:SetWidth(160)
            btn:SetHeight(20)
            btn:SetPoint("TOPLEFT", 5, -((i-1)*20))
            
            local btnText = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            btnText:SetPoint("LEFT", 5, 0)
            btn.text = btnText
            
            btn:SetScript("OnClick", function()
                selectedPlayer = this.text:GetText()
                playerText:SetText(selectedPlayer)
                playerListFrame:Hide()
            end)
            
            playerButtons[i] = btn
        else
            playerButtons[i]:SetPoint("TOPLEFT", 5, -((i-1)*20))
        end
        
        playerButtons[i].text:SetText(allPlayerNames[i])
        playerButtons[i]:Show()
    end
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
        UpdatePlayerList()
        playerListFrame:Show()
    end
end)

-----------------------------------
-- Amount Box
-----------------------------------
local amountLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
amountLabel:SetPoint("TOPLEFT", 20, -410)
amountLabel:SetText("Amount:")

local amountBox = CreateFrame("EditBox", "SSC_AmountBox", frame, "InputBoxTemplate")
amountBox:SetWidth(60)
amountBox:SetHeight(20)
amountBox:SetPoint("LEFT", amountLabel, "RIGHT", 10, 0)
amountBox:SetAutoFocus(false)
amountBox:SetNumeric(true)
amountBox:SetText("1")

-----------------------------------
-- Top Holders List
-----------------------------------
local topLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
topLabel:SetPoint("TOPLEFT", 240, -50)
topLabel:SetText("Top Holders")

local topFrame = CreateFrame("Frame", "SSC_TopFrame", frame)
topFrame:SetWidth(160)
topFrame:SetHeight(320)
topFrame:SetPoint("TOPLEFT", 240, -75)
topFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})

-- Scroll frame for top holders
local topScrollFrame = CreateFrame("ScrollFrame", "SSC_TopScrollFrame", topFrame)
topScrollFrame:SetWidth(130)
topScrollFrame:SetHeight(300)
topScrollFrame:SetPoint("TOPLEFT", 8, -8)

-- Scroll child for top holders
local topScrollChild = CreateFrame("Frame", "SSC_TopScrollChild", topScrollFrame)
topScrollChild:SetWidth(130)
topScrollChild:SetHeight(1)
topScrollFrame:SetScrollChild(topScrollChild)

-- Scroll bar for top holders
local topScrollBar = CreateFrame("Slider", "SSC_TopScrollBar", topScrollFrame)
topScrollBar:SetPoint("TOPRIGHT", topFrame, "TOPRIGHT", -5, -15)
topScrollBar:SetPoint("BOTTOMRIGHT", topFrame, "BOTTOMRIGHT", -5, 15)
topScrollBar:SetWidth(16)
topScrollBar:SetBackdrop({
    bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
    edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
    tile = true, tileSize = 8, edgeSize = 8,
    insets = { left = 3, right = 3, top = 6, bottom = 6 }
})
topScrollBar:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
topScrollBar:SetMinMaxValues(0, 1)
topScrollBar:SetValueStep(1)
topScrollBar:SetValue(0)
topScrollBar:SetScript("OnValueChanged", function()
    topScrollFrame:SetVerticalScroll(this:GetValue())
end)

local topLines = {}

local function UpdateTop15()
    local list = {}
    for name, coins in pairs(SecretSpiderCoin.coins) do
        if type(coins) == "number" then
            table.insert(list, {name=name, coins=coins})
        end
    end
    
    table.sort(list, function(a,b) 
        if type(a.coins) == "number" and type(b.coins) == "number" then
            return a.coins > b.coins
        end
        return false
    end)
    
    local numHolders = table.getn(list)
    
    -- Adjust scroll child height
    local contentHeight = numHolders * 20
    if contentHeight < 300 then contentHeight = 300 end
    topScrollChild:SetHeight(contentHeight)
    
    -- Update scroll bar
    local maxScroll = contentHeight - 300
    if maxScroll < 0 then maxScroll = 0 end
    topScrollBar:SetMinMaxValues(0, maxScroll)
    topScrollBar:SetValue(0)
    
    -- Clear old lines
    for i = 1, table.getn(topLines) do
        topLines[i]:Hide()
    end
    
    -- Create or update lines
    for i = 1, numHolders do
        if not topLines[i] then
            local line = topScrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            line:SetPoint("TOPLEFT", 5, -((i-1)*20))
            line:SetJustifyH("LEFT")
            topLines[i] = line
        else
            topLines[i]:SetPoint("TOPLEFT", 5, -((i-1)*20))
        end
        
        topLines[i]:SetText(i..". "..list[i].name.." - "..list[i].coins)
        topLines[i]:Show()
    end
end

-- Call UpdateTop15 initially
UpdateTop15()

-----------------------------------
-- Status Text
-----------------------------------
local statusText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
statusText:SetPoint("TOPLEFT", 20, -440)
statusText:SetText("")

-----------------------------------
-- Add / Remove Buttons
-----------------------------------
local addBtn = CreateFrame("Button", "SSC_AddBtn", frame, "UIPanelButtonTemplate")
addBtn:SetWidth(80)
addBtn:SetHeight(22)
addBtn:SetPoint("TOPLEFT", 20, -460)
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
local chatChannels = { "GUILD", "PARTY", "RAID", "SAY", "WHISPER" }

chatBtn:SetScript("OnClick", function()
    chatIndex = chatIndex + 1
    if chatIndex > table.getn(chatChannels) then
        chatIndex = 1
    end
    chatTarget = chatChannels[chatIndex]
    chatText:SetText(chatTarget)
    DEFAULT_CHAT_FRAME:AddMessage("Chat channel changed to: "..chatTarget)
end)

-----------------------------------
-- Add/Announce & Remove/Announce Buttons
-----------------------------------
local addAnnounceBtn = CreateFrame("Button", "SSC_AddAnnounceBtn", frame, "UIPanelButtonTemplate")
addAnnounceBtn:SetWidth(100)
addAnnounceBtn:SetHeight(22)
addAnnounceBtn:SetPoint("TOPLEFT", addBtn, "BOTTOMLEFT", 0, -5)
addAnnounceBtn:SetText("Add/Announce")

addAnnounceBtn:SetScript("OnClick", function()
    if selectedPlayer then
        local amt = tonumber(amountBox:GetText()) or 0
        AddCoins(selectedPlayer, amt)
        local newTotal = GetCoins(selectedPlayer)
        statusText:SetText(selectedPlayer.." has "..newTotal.." (+ "..amt..")")
        UpdateTop15()
        
        -- Announce to chat
        local message = selectedPlayer.." has gained "..amt.." Secret Spider Coin ("..newTotal.." total)"
        local currentChat = chatText:GetText()
        
        if currentChat == "WHISPER" then
            if SecretSpiderCoin.lastWhisper and SecretSpiderCoin.lastWhisper ~= "" then
                SendChatMessage(message, "WHISPER", nil, SecretSpiderCoin.lastWhisper)
            else
                statusText:SetText("No whisper target set")
            end
        else
            SendChatMessage(message, currentChat)
        end
    else
        statusText:SetText("Please select a player first")
    end
end)

local removeAnnounceBtn = CreateFrame("Button", "SSC_RemoveAnnounceBtn", frame, "UIPanelButtonTemplate")
removeAnnounceBtn:SetWidth(100)
removeAnnounceBtn:SetHeight(22)
removeAnnounceBtn:SetPoint("LEFT", addAnnounceBtn, "RIGHT", 10, 0)
removeAnnounceBtn:SetText("Remove/Announce")

removeAnnounceBtn:SetScript("OnClick", function()
    if selectedPlayer then
        local amt = tonumber(amountBox:GetText()) or 0
        RemoveCoins(selectedPlayer, amt)
        local newTotal = GetCoins(selectedPlayer)
        statusText:SetText(selectedPlayer.." has "..newTotal.." (- "..amt..")")
        UpdateTop15()
        
        -- Announce to chat
        local message = selectedPlayer.." has lost "..amt.." Secret Spider Coin ("..newTotal.." total)"
        local currentChat = chatText:GetText()
        
        if currentChat == "WHISPER" then
            if SecretSpiderCoin.lastWhisper and SecretSpiderCoin.lastWhisper ~= "" then
                SendChatMessage(message, "WHISPER", nil, SecretSpiderCoin.lastWhisper)
            else
                statusText:SetText("No whisper target set")
            end
        else
            SendChatMessage(message, currentChat)
        end
    else
        statusText:SetText("Please select a player first")
    end
end)

-----------------------------------
-- Top 10 Button
-----------------------------------
local topBtn = CreateFrame("Button", "SSC_TopBtn", frame, "UIPanelButtonTemplate")
topBtn:SetWidth(120)
topBtn:SetHeight(22)
topBtn:SetPoint("TOP", -65, -520)
topBtn:SetText("Say Top 10")

topBtn:SetScript("OnClick", function()
    local list = {}
    for name, coins in pairs(SecretSpiderCoin.coins) do
        if type(coins) == "number" then
            table.insert(list, {name=name, coins=coins})
        end
    end

    table.sort(list, function(a,b) 
        if type(a.coins) == "number" and type(b.coins) == "number" then
            return a.coins > b.coins
        end
        return false
    end)

    local maxEntries = 10
    if table.getn(list) < 10 then maxEntries = table.getn(list) end

    if chatTarget == "WHISPER" then
        if SecretSpiderCoin.lastWhisper and SecretSpiderCoin.lastWhisper ~= "" then
            SendChatMessage("Top Secret Spider Coin Holders:", "WHISPER", nil, SecretSpiderCoin.lastWhisper)
            for i = 1, maxEntries do
                SendChatMessage(i..". "..list[i].name.." - "..list[i].coins, "WHISPER", nil, SecretSpiderCoin.lastWhisper)
            end
        else
            statusText:SetText("No whisper target set. Type a name in chat.")
        end
    else
        SendChatMessage("Top Secret Spider Coin Holders:", chatTarget)
        for i = 1, maxEntries do
            SendChatMessage(i..". "..list[i].name.." - "..list[i].coins, chatTarget)
        end
    end
end)

-----------------------------------
-- Say Player Balance Button
-----------------------------------
local balanceBtn = CreateFrame("Button", "SSC_BalanceBtn", frame, "UIPanelButtonTemplate")
balanceBtn:SetWidth(120)
balanceBtn:SetHeight(22)
balanceBtn:SetPoint("TOP", 65, -520)
balanceBtn:SetText("Say Balance")

balanceBtn:SetScript("OnClick", function()
    if selectedPlayer then
        local currentCoins = GetCoins(selectedPlayer)
        local message = selectedPlayer.." has "..currentCoins.." Secret Spider Coin"
        local currentChat = chatText:GetText()
        
        if currentChat == "WHISPER" then
            if SecretSpiderCoin.lastWhisper and SecretSpiderCoin.lastWhisper ~= "" then
                SendChatMessage(message, "WHISPER", nil, SecretSpiderCoin.lastWhisper)
            else
                statusText:SetText("No whisper target set")
            end
        else
            SendChatMessage(message, currentChat)
        end
    else
        statusText:SetText("Please select a player first")
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

mini:SetScript("OnEnter", function()
    GameTooltip:SetOwner(this, "ANCHOR_LEFT")
    GameTooltip:SetText("SecretSpiderCoin", 1, 1, 1)
    GameTooltip:AddLine("The only accepted coin of the village springdu", nil, nil, nil, 1)
    GameTooltip:Show()
end)

mini:SetScript("OnLeave", function()
    GameTooltip:Hide()
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

-----------------------------------
-- Event Handler for Loading Data
-----------------------------------
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGOUT")
eventFrame:RegisterEvent("PLAYER_LEAVING_WORLD")
eventFrame:RegisterEvent("PLAYER_QUITING")
eventFrame:RegisterEvent("CHAT_MSG_WHISPER")
eventFrame:RegisterEvent("CHAT_MSG_WHISPER_INFORM")
eventFrame:RegisterEvent("CHAT_MSG_ADDON")

eventFrame:SetScript("OnEvent", function()
    if event == "ADDON_LOADED" and arg1 == "SecretSpiderCoin" then
        LoadData()
        UpdateTop15()
    elseif event == "PLAYER_LOGOUT" or event == "PLAYER_LEAVING_WORLD" or event == "PLAYER_QUITING" then
        SaveData()
    elseif event == "CHAT_MSG_WHISPER" then
        -- Incoming whisper
        SecretSpiderCoin.lastWhisper = arg2
    elseif event == "CHAT_MSG_WHISPER_INFORM" then
        -- Outgoing whisper
        SecretSpiderCoin.lastWhisper = arg2
    elseif event == "CHAT_MSG_ADDON" then
        -- Handle addon communication
        local prefix = arg1
        local message = arg2
        local channel = arg3
        local sender = arg4
        
        if prefix == "SSC_REQUEST" and message == "GETDATA" then
            -- Someone is requesting our coin data
            local response = ""
            for name, coins in pairs(SecretSpiderCoin.coins) do
                if type(coins) == "number" then
                    if response ~= "" then
                        response = response..";"
                    end
                    response = response..name..":"..coins
                end
            end
            
            -- Send response back
            if response ~= "" then
                SendAddonMessage("SSC_RESPONSE", response, channel)
            end
        end
    end
end)
