

----------------------------------- -- SecretSpiderCoin ----------------------------------- SecretSpiderCoin = {} SecretSpiderCoin.coins = {} ----------------------------------- -- Utility Functions ----------------------------------- local function GetCoins(name) if not SecretSpiderC

pasted

Fix the lua code, I receive a 713:attempt to index local 'frame' (a number value) when running the code. It is for turtle wow. Here is the code:

9:51 AM
The error occurs because CreateFrame is being called incorrectly. In Turtle WoW (which is based on WoW 1.12), the CreateFrame function returns multiple values when creating certain frame types, and you need to handle this properly.

The main issue is with the dropdown menus. The UIDropDownMenuTemplate creates multiple frames, and you need to use the correct API.

Here's the fixed code:

SecretSpiderCoin.lua (Fixed)
Code 
The main fixes I made:

Changed dropdown creation: Instead of CreateFrame("Frame", ..., "UIDropDownMenuTemplate"), I used CreateFrame("Button", ...) and let the UIDropDownMenu_Initialize function handle the setup.
Fixed UIDropDownMenu_AddButton: In vanilla WoW, you need to pass a table (info table) to UIDropDownMenu_AddButton, not directly pass the properties.
Fixed UIDropDownMenu_SetWidth parameter order: Changed from UIDropDownMenu_SetWidth(dropdown, 160) to UIDropDownMenu_SetWidth(160, dropdown) - the width comes first in vanilla WoW.
Fixed UIDropDownMenu_SetText parameter order: Changed to UIDropDownMenu_SetText("text", dropdown) format.
Changed getn() to table.getn(): This is the correct Lua 5.0 syntax used in vanilla WoW.
These changes should resolve the error and make the addon work properly in Turtle WoW!

it now gives the error lud:713: attempt to index a nil value. please fix

9:52 AM
The error suggests that one of the frames is nil. This is likely because the UIDropDownMenu functions in Turtle WoW need the frame to be created differently. Let me fix this by using a more compatible approach:

SecretSpiderCoin.lua (Fixed)
Code ∙ Version 2 
The key changes I made:

Added UIDropDownMenu_CreateInfo(): This creates the proper info table that UIDropDownMenu needs in vanilla WoW.
Used this.value: In vanilla WoW, inside the dropdown callback functions, this refers to the button that was clicked, and we access its value.
Added UIDropDownMenu_SetSelectedValue: This properly updates the dropdown selection.
Added UIDropDownMenu_SetButtonWidth: This ensures the dropdown button has the correct width.
Set initial chat dropdown value: Added UIDropDownMenu_SetSelectedValue(chatDrop, "GUILD") to set the initial selection.
Named all frames: Added unique names to all CreateFrame calls to avoid potential conflicts.
Removed extra parentheses: Cleaned up unnecessary parentheses around function calls like GetRaidRosterInfo(i).
This should now work properly in Turtle WoW without the nil value error!

It gives the exact same error, no change

9:55 AM
Let me try a different approach. The issue is that UIDropDownMenu_CreateInfo() might not exist in Turtle WoW. Let's use a simpler method that's more compatible:

SecretSpiderCoin.lua (Fixed)
Code ∙ Version 3 
The key changes:

Changed the initialization function signature: Added (self, level) parameters to the UIDropDownMenu_Initialize callback
Pass level to AddButton: Changed UIDropDownMenu_AddButton(info) to UIDropDownMenu_AddButton(info, level)
Fixed the parameter order: UIDropDownMenu_SetWidth(dropdown, 160) instead of UIDropDownMenu_SetWidth(160, dropdown)
Simplified info table creation: Just using local info = {} instead of trying to call a CreateInfo function
This should work with the vanilla WoW API that Turtle WoW uses. The dropdowns should now initialize properly!

It now gives 713: attempt to index local "frame' (a number value) again

9:56 AM
The issue is that UIDropDownMenu_SetWidth and similar functions have the wrong parameter order. In vanilla WoW, these functions expect the width/value first, then the frame. Let me fix this:

SecretSpiderCoin.lua (Fixed)
Code ∙ Version 4 
SecretSpiderCoin.lua (Fixed)
Code ∙ Version 5 
I've fixed the parameter order for both UIDropDownMenu_SetWidth calls. In vanilla WoW, the width parameter comes first, then the frame. This should resolve the "attempt to index local 'frame' (a number value)" error!

And back to attempt to index a nil value

9:57 AM
Let me try a completely different approach. The issue is with how we're calling the UIDropDownMenu functions. Let me check if these functions even exist or if we need to use them differently:

SecretSpiderCoin.lua (Fixed)
Code ∙ Version 6 
I've completely removed the UIDropDownMenu system and replaced it with a simpler custom solution using buttons. This avoids all the compatibility issues with the dropdown API:

Key changes:

Player selection: Now uses a simple button that opens a list of clickable player names
Chat channel selection: Uses a "Change" button that cycles through GUILD → PARTY → RAID
No more dropdowns: Everything uses standard CreateFrame buttons which are much more reliable in vanilla WoW
This approach is much more straightforward and should work without any nil value errors!

It now gives lua:128: attempt to call method 'SetNormalFontObject' (a nil value)

9:59 AM
The SetNormalFontObject method doesn't exist in vanilla WoW. Let me fix that by using a FontString instead:

SecretSpiderCoin.lua (Fixed)
Code ∙ Version 7 
SecretSpiderCoin.lua (Fixed)
Code ∙ Version 8 
I've fixed the issue by:

Removed SetNormalFontObject and SetText methods which don't exist on plain buttons in vanilla WoW
Created FontString children for each button to display the text
Updated references to use btn.text:SetText() and btn.text:GetText() instead
This should now work properly in Turtle WoW!

Great! It now seems to work correctly so far. Let's add a list of the top 15 players in the window below where you select the player's name.

10:02 AM
SecretSpiderCoin.lua (Fixed)
Code ∙ Version 9 
SecretSpiderCoin.lua (Fixed)
Code ∙ Version 10 
SecretSpiderCoin.lua (Fixed)
Code ∙ Version 11 
SecretSpiderCoin.lua (Fixed)
Code ∙ Version 12 
SecretSpiderCoin.lua (Fixed)
Code ∙ Version 13 
Perfect! I've added a Top 15 players list to the right side of the window. Here's what I changed:

Increased frame height from 350 to 550 to accommodate the new list
Added a Top 15 list display on the right side with a framed background showing the top 15 players and their coin counts
Created an UpdateTop15() function that sorts and displays the current rankings
Auto-updates the list whenever you add or remove coins from a player
Moved the "Say Top 10" button down to avoid overlapping with the new list
The list will automatically update in real-time as you modify player coin amounts!

It does show a list, but the addon resets the information after logout. Let's change it to save the information it stores so that after logging out and back in, the top 15 list still shows changes from the last login

10:05 AM
SecretSpiderCoin.lua (Fixed)
Code ∙ Version 14 
SecretSpiderCoin.lua (Fixed)
Code ∙ Version 15 
SecretSpiderCoin.lua (Fixed)
Code ∙ Version 16 
Now I need to create a .toc file that tells WoW to save the variables. You'll need to create a new file called SecretSpiderCoin.toc in the same folder as your Lua file:

toc
## Interface: 11200
## Title: Secret Spider Coin
## Notes: Track Secret Spider Coins for players
## Author: YourName
## Version: 1.0
## SavedVariables: SecretSpiderCoinDB

SecretSpiderCoin.lua
What I changed:

Added LoadData() and SaveData() functions to handle loading and saving coin data
Modified AddCoins() and RemoveCoins() to automatically save after each change
Added an event handler that:
Loads saved data when the addon loads (ADDON_LOADED)
Saves data when you log out (PLAYER_LOGOUT)
Updates the Top 15 list after loading
Added SavedVariables to the .toc file which tells WoW to persist SecretSpiderCoinDB between sessions
Now your coin data will persist across logouts and the Top 15 list will show your historical data!

There is now a lua:229: attempt to compare two table values error

10:07 AM
The error is because we're trying to sort table values. Let me fix the sorting function:

SecretSpiderCoin.lua (Fixed)
Code ∙ Version 17 
SecretSpiderCoin.lua (Fixed)
Code ∙ Version 18 
I've fixed the sorting issue by:

Adding type checks to ensure we only insert entries with numeric coin values
Safe comparison in the sort function that checks both values are numbers before comparing
Applied the same fix to both the UpdateTop15() function and the "Say Top 10" button
This prevents the error when the saved data might contain unexpected table values. The addon should now work correctly with saved data!

/ss

10:08 AM
I think you meant to type /ssc to show the addon window! The slash command is /ssc show based on the code.

If you're getting an error or it's not working, let me know what happens when you try /ssc show and I can help troubleshoot!

That now works. The list of 15 players overlaps the add, remove, chat change and amount fields. Let's move those further down on the menu

10:09 AM
SecretSpiderCoin.lua (Fixed)
Code ∙ Version 19 
SecretSpiderCoin.lua (Fixed)
Code ∙ Version 20 
SecretSpiderCoin.lua (Fixed)
Code ∙ Version 21 
Perfect! I've moved all the controls down so they don't overlap with the Top 15 list:

Amount box: Moved from -240 to -410
Status text: Moved from -270 to -440
Add/Remove buttons: Moved from -290 to -460
Chat controls and Top 10 button: Automatically moved down since they're positioned relative to the other elements
The layout should now be clean with the Top 15 list on the right side and all controls nicely spaced below the player selection area!

That worked great! Let's rewrite the entire code keeping everything the same except it is now longer SecretSpiderCoin. It is SpringduCoin, so anything about SpiderCoin can be changed

10:13 AM
SecretSpiderCoin.lua (Fixed)
Code ∙ Version 22 
Perfect! I've rewritten the entire code with all references changed from SecretSpiderCoin to SpringduCoin. Here's what changed:

Main changes:

SecretSpiderCoin → SpringduCoin
SecretSpiderCoinDB → SpringduCoinDB
SSC_ prefixes → SDC_ prefixes (for frame names)
Title text: "Secret Spider Coin" → "Springdu Coin"
Chat message: "Top Secret Spider Coin Holders:" → "Top Springdu Coin Holders:"
Slash command: /ssc → /sdc
Command name: SECRETSPIDERCOIN → SPRINGDUCOIN
Don't forget to also update your .toc file:

toc
## Interface: 11200
## Title: Springdu Coin
## Notes: Track Springdu Coins for players
## Author: YourName
## Version: 1.0
## SavedVariables: SpringduCoinDB

SpringduCoin.lua
Now you can use /sdc show to open the addon!

Everything seems to work great, except if you fully exit the game it doesn't save the added/removed coins in memory. That needs to change, the information my stay after fully exiting the game

1:40 PM
The issue is that PLAYER_LOGOUT doesn't always fire reliably in vanilla WoW. Let me add additional save triggers to ensure data is saved more frequently:

SecretSpiderCoin.lua (Fixed)
Code ∙ Version 23 
I've added multiple save events to catch different exit scenarios. However, since the data is already being saved every time you add or remove coins (in the AddCoins() and RemoveCoins() functions), the data should persist.

To verify the .toc file is correct, make sure it looks exactly like this:

toc
## Interface: 11200
## Title: Springdu Coin
## Notes: Track Springdu Coins for players
## Author: YourName
## Version: 1.0
## SavedVariables: SpringduCoinDB

SpringduCoin.lua
Also ensure:

The addon folder is named SpringduCoin in your Interface\AddOns\ directory
Both SpringduCoin.toc and SpringduCoin.lua are in that folder
The saved variables file will be created at WTF\Account\YOURACCOUNTNAME\SavedVariables\SpringduCoin.lua
The data saves every time you click Add or Remove, so it should persist even if you force-close the game. Can you verify if the SpringduCoin.lua file appears in your SavedVariables folder after adding coins?

Rewrite the code for SprinduCoin. Not Springducoin

1:50 PM
SprinduCoin.lua
Code ∙ Version 24 
Perfect! I've rewritten the code for SprinduCoin (without the extra 'g'). Here are all the changes:

Main changes:

SpringduCoin → SprinduCoin
SpringduCoinDB → SprinduCoinDB
SDC_ prefixes → SC_ prefixes (for frame names)
Title text: "Springdu Coin" → "Sprindu Coin"
Chat message: "Top Springdu Coin Holders:" → "Top Sprindu Coin Holders:"
Slash command: /sdc → /sc
Command name: SPRINGDUCOIN → SPRINDUCOIN
Your .toc file should be:

toc
## Interface: 11200
## Title: Sprindu Coin
## Notes: Track Sprindu Coins for players
## Author: YourName
## Version: 1.0
## SavedVariables: SprinduCoinDB

SprinduCoin.lua
File structure:

Folder name: SprinduCoin
Files: SprinduCoin.toc and SprinduCoin.lua
Now you can use /sc show to open the addon!

Great, that saved the information after exiting the game. Now rewrite the same script, but for SecretSpiderCoin

1:57 PM
SecretSpiderCoin.lua
Code ∙ Version 25 
Perfect! I've rewritten the code for SecretSpiderCoin. Here are all the changes:

Main changes:

SprinduCoin → SecretSpiderCoin
SprinduCoinDB → SecretSpiderCoinDB
SC_ prefixes → SSC_ prefixes (for frame names)
Title text: "Sprindu Coin" → "Secret Spider Coin"
Chat message: "Top Sprindu Coin Holders:" → "Top Secret Spider Coin Holders:"
Slash command: /sc → /ssc
Command name: SPRINDUCOIN → SECRETSPIDERCOIN
Your .toc file should be:

toc
## Interface: 11200
## Title: Secret Spider Coin
## Notes: Track Secret Spider Coins for players
## Author: YourName
## Version: 1.0
## SavedVariables: SecretSpiderCoinDB

SecretSpiderCoin.lua
File structure:

Folder name: SecretSpiderCoin
Files: SecretSpiderCoin.toc and SecretSpiderCoin.lua
Now you can use /ssc show to open the addon! The data will persist after exiting the game.

Great, will this chat be saved?

1:59 PM
Yes, this chat will be saved! You can find it in your chat history. If you're using Claude.ai, you can access your past conversations by:

Clicking on the menu in the top-left corner
Looking through your conversation history
All of our conversation, including the code artifacts I created for your WoW addons (SprinduCoin and SecretSpiderCoin), will be available for you to reference later.

If you need to come back and make more changes to the addons or have questions about how they work, you can always return to this conversation!

This works well. Can we add  anyone that has any amount of coin to the dropdown?

7:53 PM
SecretSpiderCoin.lua (Fixed)
Code ∙ Version 26 
Perfect! I've updated the GetPlayerList() function to:

First add all players who have any coins (anyone with a coin balance greater than 0)
Then add players from raid/party/guild (without duplicates)
Sort the list alphabetically for easier browsing
Now when you click the "Select" button, the dropdown will show:

All players who have received coins (even if they're not currently online or in your group)
All current raid/party/guild members
Everything sorted alphabetically with no duplicates
This makes it easy to manage coins for players who might not be online at the moment!

How difficult would it be to add the player's guild list and friend list to the dropdown select menu?

10:53 AM
It's not difficult at all! Let me add both the friends list and guild members to the dropdown:

SecretSpiderCoin.lua (Fixed)
Code ∙ Version 27 
Perfect! I've updated the dropdown to include both friends and guild members. The function now pulls from:

Players with coins - Anyone who has ever received coins
Friends list - All your friends (using GetNumFriends() and GetFriendInfo())
Guild members - Everyone in your guild
Raid members - Current raid members
Party members - Current party members (if not in a raid)
All names are deduplicated and sorted alphabetically, so you'll have a comprehensive list of everyone you might want to give coins to! This makes it much easier to manage coins for guildmates and friends even when they're not in your immediate party.

The list only shows 10 entries, can the list be changed to be infinite and have a scroll bar?

11:01 AM
Let me add a scrollable list that can show all entries:

SecretSpiderCoin.lua (Fixed)
Code ∙ Version 28 
SecretSpiderCoin.lua (Fixed)
Code ∙ Version 29 
Perfect! I've updated the player list to:

Show unlimited entries - The list now dynamically creates buttons for all players
Added a scroll bar - You can scroll through the entire list using the scroll bar on the right
Made it taller - Increased from 150 to 200 pixels to show more entries at once
Dynamic content - The list automatically adjusts its height based on how many players there are
Now you can scroll through your entire friends list, guild roster, and everyone who has coins. The scroll bar will appear on the right side of the player selection dropdown!



Want to be notified when Claude responds?



Claude is AI and can make mistakes. Please double-check responses.
-----------------------------------
-- SecretSpiderCoin
-----------------------------------
SecretSpiderCoin = {}
SecretSpiderCoin.coins = {}

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
    if newValue < 0 then newValue = 0 end
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

-----------------------------------
-- Event Handler for Loading Data
-----------------------------------
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGOUT")
eventFrame:RegisterEvent("PLAYER_LEAVING_WORLD")
eventFrame:RegisterEvent("PLAYER_QUITING")
eventFrame:SetScript("OnEvent", function()
    if event == "ADDON_LOADED" and arg1 == "SecretSpiderCoin" then
        LoadData()
        UpdateTop15()
    elseif event == "PLAYER_LOGOUT" or event == "PLAYER_LEAVING_WORLD" or event == "PLAYER_QUITING" then
        SaveData()
    end
end)
