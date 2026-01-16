-----------------------------------
-- SecretSpiderCoin
-----------------------------------
SecretSpiderCoin = {}
SecretSpiderCoin.coins = {}

-----------------------------------
-- Utilities
-----------------------------------
local function GetOrCreatePlayer(name)
    if not SecretSpiderCoin.coins[name] then
        SecretSpiderCoin.coins[name] = 0
    end
    return SecretSpiderCoin.coins[name]
end

local function AddCoins(name, amount)
    SecretSpiderCoin.coins[name] = GetOrCreatePlayer(name) + amount
end

local function RemoveCoins(name, amount)
    SecretSpiderCoin.coins[name] = max(0, GetOrCreatePlayer(name) - amount)
end

-----------------------------------
-- Main Window
-----------------------------------
local frame = CreateFrame("Frame", "SecretSpiderCoinFrame", UIParent)
frame:SetSize(420, 300)
frame:SetPoint("CENTER")
frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:Hide()

-- Title
frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
frame.title:SetPoint("TOP", 0, -12)
frame.title:SetText("Secret Spider Coin")

-- Close button (red X)
local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", -6, -6)

-----------------------------------
-- Dropdown: Player Selection
-----------------------------------
local selectedPlayer

local dropdown = CreateFrame("Frame", "SSCPlayerDropdown", frame, "UIDropDownMenuTemplate")
dropdown:SetPoint("TOPLEFT", 20, -50)

local function PopulatePlayers()
    local players = {}

    if IsInRaid() then
        for i = 1, GetNumRaidMembers() do
            local name = GetRaidRosterInfo(i)
            if name then table.insert(players, name) end
        end
    elseif GetNumPartyMembers() > 0 then
        table.insert(players, UnitName("player"))
        for i = 1, GetNumPartyMembers() do
            table.insert(players, UnitName("party"..i))
        end
    elseif IsInGuild() then
        for i = 1, GetNumGuildMembers() do
            local name = GetGuildRosterInfo(i)
            if name then table.insert(players, name) end
        end
    end

    return players
end

UIDropDownMenu_Initialize(dropdown, function(self)
    for _, name in ipairs(PopulatePlayers()) do
        UIDropDownMenu_AddButton({
            text = name,
            func = function()
                selectedPlayer = name
                UIDropDownMenu_SetSelectedName(dropdown, name)
            end
        })
    end
end)

UIDropDownMenu_SetWidth(dropdown, 160)
UIDropDownMenu_SetText(dropdown, "Select Player")

-----------------------------------
-- Amount EditBox
-----------------------------------
local amountBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
amountBox:SetSize(60, 20)
amountBox:SetPoint("LEFT", dropdown, "RIGHT", 20, 0)
amountBox:SetAutoFocus(false)
amountBox:SetNumeric(true)
amountBox:SetText("1")

-----------------------------------
-- Add / Remove Buttons
-----------------------------------
local statusText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
statusText:SetPoint("TOPLEFT", dropdown, "BOTTOMLEFT", 20, -20)
statusText:SetText("")

local addBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
addBtn:SetSize(80, 22)
addBtn:SetPoint("TOPLEFT", statusText, "BOTTOMLEFT", 0, -10)
addBtn:SetText("Add")

addBtn:SetScript("OnClick", function()
    if selectedPlayer then
        local amt = tonumber(amountBox:GetText()) or 0
        AddCoins(selectedPlayer, amt)
        statusText:SetText(selectedPlayer.." now has "..SecretSpiderCoin.coins[selectedPlayer].." coins (+ "..amt..")")
    end
end)

local removeBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
removeBtn:SetSize(80, 22)
removeBtn:SetPoint("LEFT", addBtn, "RIGHT", 10, 0)
removeBtn:SetText("Remove")

removeBtn:SetScript("OnClick", function()
    if selectedPlayer then
        local amt = tonumber(amountBox:GetText()) or 0
        RemoveCoins(selectedPlayer, amt)
        statusText:SetText(selectedPlayer.." now has "..SecretSpiderCoin.coins[selectedPlayer].." coins (- "..amt..")")
    end
end)

-----------------------------------
-- Chat Target Dropdown
-----------------------------------
local chatTarget = "GUILD"

local chatDrop = CreateFrame("Frame", "SSCChatDropdown", frame, "UIDropDownMenuTemplate")
chatDrop:SetPoint("TOPLEFT", addBtn, "BOTTOMLEFT", -15, -20)

UIDropDownMenu_Initialize(chatDrop, function(self)
    for _, ch in ipairs({ "GUILD", "PARTY", "RAID" }) do
        UIDropDownMenu_AddButton({
            text = ch,
            func = function()
                chatTarget = ch
                UIDropDownMenu_SetSelectedName(chatDrop, ch)
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
topBtn:SetSize(120, 22)
topBtn:SetPoint("LEFT", chatDrop, "RIGHT", 10, 0)
topBtn:SetText("Say Top 10")

topBtn:SetScript("OnClick", function()
    local list = {}
    for name, coins in pairs(SecretSpiderCoin.coins) do
        table.insert(list, {name=name, coins=coins})
    end
    table.sort(list, function(a,b) return a.coins > b.coins end)

    SendChatMessage("Top Secret Spider Coin Holders:", chatTarget)
    for i = 1, min(10, #list) do
        SendChatMessage(i..". "..list[i].name.." - "..list[i].coins, chatTarget)
    end
end)

-----------------------------------
-- Second Window: Full List
-----------------------------------
local listFrame = CreateFrame("Frame", nil, UIParent)
listFrame:SetSize(260, 300)
listFrame:SetPoint("RIGHT", frame, "LEFT", -10, 0)
listFrame:SetBackdrop(frame:GetBackdrop())
listFrame:SetMovable(true)
listFrame:EnableMouse(true)
listFrame:RegisterForDrag("LeftButton")
listFrame:SetScript("OnDragStart", listFrame.StartMoving)
listFrame:SetScript("OnDragStop", listFrame.StopMovingOrSizing)
listFrame:Hide()

local listTitle = listFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
listTitle:SetPoint("TOP", 0, -12)
listTitle:SetText("SpiderCoin Ledger")

local listText = listFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
listText:SetPoint("TOPLEFT", 15, -40)
listText:SetJustifyH("LEFT")

local function RefreshList()
    local text = ""
    for name, coins in pairs(SecretSpiderCoin.coins) do
        text = text..name..": "..coins.."\n"
    end
    listText:SetText(text)
end

local listBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
listBtn:SetSize(120, 22)
listBtn:SetPoint("TOPLEFT", chatDrop, "BOTTOMLEFT", 0, -40)
listBtn:SetText("Open Ledger")

listBtn:SetScript("OnClick", function()
    RefreshList()
    listFrame:SetShown(not listFrame:IsShown())
end)

-----------------------------------
-- Minimap Button
-----------------------------------
local mini = CreateFrame("Button", "SSCMinimapButton", Minimap)
mini:SetSize(32,32)
mini:SetFrameStrata("MEDIUM")
mini:SetPoint("TOPLEFT", Minimap, "TOPLEFT")
mini:SetNormalTexture("Interface\\Icons\\INV_Misc_Coin_01")
mini:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

mini:SetScript("OnClick", function()
    frame:SetShown(not frame:IsShown())
end)

-----------------------------------
-- Slash Command
-----------------------------------
SLASH_SECRESPIDERCOIN1 = "/ssc"
SlashCmdList["SECRESPIDERCOIN"] = function(msg)
    if msg == "show" then
        frame:Show()
    end
end
