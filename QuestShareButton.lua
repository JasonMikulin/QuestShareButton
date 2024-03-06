local addonEnabled = true

local function GetQuestLogIndexByQuestID(questID)
    for i = 1, C_QuestLog.GetNumQuestLogEntries() do
        local id = C_QuestLog.GetQuestIDForLogIndex(i)
        if id == questID then
            return i
        end
    end
    return nil
end

-- Function to create and position the share button
local function CreateShareButton(questBlock)
    local button = CreateFrame("Button", nil, questBlock, "UIPanelButtonTemplate")
    button:SetText("Share")
    button:SetSize(40, 15)
    
    -- Set position
    button:SetPoint("TOPLEFT", questBlock, "TOPLEFT", -50, -15)

    local fontString = button:GetFontString()
    local font, _, style = fontString:GetFont()
    fontString:SetFont(font, 9, style)
    
    button:SetScript("OnClick", function()
        local questIndex = GetQuestLogIndexByQuestID(questBlock.id)
        if questIndex then
            C_QuestLog.SetSelectedQuest(questBlock.id)
            QuestLogPushQuest()
        end
    end)
    
    
    return button
end


local function IsQuestShareable(questID)
    if not questID then return false end  -- Safety check
    
    --print("Attempting to check shareability for questID:", questID)
    local isShareable = C_QuestLog.IsPushableQuest(questID)
    
    --if isShareable then
        --print("Quest ID", questID, "is shareable.")
   -- else
        --print("Quest ID", questID, "is NOT shareable.")
    --end
    return isShareable
end

local function UpdateShareButton(questBlock)
    if not addonEnabled then
        if questBlock.shareButton then
            questBlock.shareButton:Hide()
        end
        return
    end
    local questID = questBlock.id
    --print("Updating Share Button for questID:", questID)
    
    if IsQuestShareable(questID) then
        if not questBlock.shareButton then
            questBlock.shareButton = CreateShareButton(questBlock)
        end
        questBlock.shareButton:Show()
    elseif questBlock.shareButton then
        questBlock.shareButton:Hide()
    end
end


-- Function to iterate through quest tracker blocks and update the share buttons accordingly
local function UpdateQuestTracker()
    --print("Updating Quest Tracker...")
    
    for i = 1, ObjectiveTrackerBlocksFrame:GetNumChildren() do
        local child = select(i, ObjectiveTrackerBlocksFrame:GetChildren())
        --print("Inspecting child:", i, child:GetName() or "Unnamed", child:GetObjectType())
        
        if type(child.id) == "table" then
            for key, value in pairs(child.id) do
                print("Key:", key, "Value:", value)
            end
        end

        if child and child.HeaderText and child.HeaderText:GetText() then 
            --print("Checking quest with title:", child.HeaderText:GetText())
            UpdateShareButton(child)
        end
    end
end

-- Hook into the ObjectiveTracker_Update method to keep our buttons updated
hooksecurefunc("ObjectiveTracker_Update", UpdateQuestTracker)

-- Create an event listener for quest log updates
local frame = CreateFrame("Frame")
frame:RegisterEvent("QUEST_LOG_UPDATE")
frame:SetScript("OnEvent", UpdateQuestTracker)

local frameLogin = CreateFrame("Frame")
frameLogin:RegisterEvent("PLAYER_LOGIN")
frameLogin:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        UpdateQuestTracker()
    end
end)

--Command to disable or enable the addon
SLASH_QUESTSHAREBUTTON1 = "/qsb"

SlashCmdList["QUESTSHAREBUTTON"] = function(msg)
    addonEnabled = not addonEnabled
    if addonEnabled then
        print("QuestShareButton is now ON.")
    else
        print("QuestShareButton is now OFF.")
    end
    UpdateQuestTracker()
end
