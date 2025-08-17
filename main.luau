-- Rayfield UI library setup
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Workspace = game:GetService("Workspace")

-- Create the main window for the UI
local Window = Rayfield:CreateWindow({
    Name = "Rynx - Doors",
    LoadingTitle = "Rynx Doors",
    LoadingSubtitle = "Made by Pulse",
    ConfigurationSaving = {Enabled = true, FolderName = "RynxDoors", FileName = "Config"},
    KeySystem = false
})

-- Create the main tab and section for the toggles
local Tab = Window:CreateTab("Main", 4483362458)
local Section = Tab:CreateSection("ESP Features")

-- Tables to hold the ESP objects for each type
local DoorESPs = {}
local ItemESPs = {}
local EntityESPs = {}

-- Table of important items to detect for Item ESP
local ImportantItems = {
    "Key", "Lever", "Flashlight", "Gold", "Battery", "Lockpick", "Bandage", 
    "StarJug", "StarVial", "SkeletonKey", "Crucifix", "BreakerPole", "Fuse",
    "Generator", "LibraryBook", "Anchor", "GateLever", "TimerLever", "MiscPickups"
}

-- CreateESP function to handle both BillboardGui and Highlight
-- It returns both objects so they can be stored and cleaned up later.
local function CreateESP(parent, obj, name, color)
    -- Ensure the object and its primary part exist before creating ESP
    if not obj or not obj.PrimaryPart then
        return nil, nil
    end

    -- Create and set up the BillboardGui for the text label
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "TextESP"
    billboardGui.Adornee = obj.PrimaryPart
    billboardGui.AlwaysOnTop = true
    billboardGui.Size = UDim2.fromScale(2, 1)
    billboardGui.Parent = parent

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.fromScale(1, 1)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = name
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextScaled = true
    textLabel.TextColor3 = color
    textLabel.Parent = billboardGui

    -- Create and set up the Highlight object
    local highlight = Instance.new("Highlight")
    highlight.Name = "VisualESP"
    highlight.Adornee = obj.PrimaryPart
    highlight.FillColor = color
    highlight.OutlineTransparency = 0.7
    highlight.Parent = parent

    return billboardGui, highlight
end

-- Function to remove and destroy all ESPs from a given table
local function RemoveESPs(espTable)
    for _, esp in ipairs(espTable) do
        if esp and esp.Parent then
            esp:Destroy()
        end
    end
    -- Clear the table after destroying all objects
    table.clear(espTable)
end

-- Function to handle the initial creation and real-time updating of ESPs
local function StartESP(espTable, filterFunc, nameFunc, color)
    -- Remove any existing ESPs before creating new ones
    RemoveESPs(espTable)
    
    -- Iterate through all existing objects in the workspace to create ESPs
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if filterFunc(obj) then
            local billboard, highlight = CreateESP(obj, obj, nameFunc(obj), color)
            if billboard and highlight then
                table.insert(espTable, billboard)
                table.insert(espTable, highlight)
            end
        end
    end

    -- Connect to DescendantAdded to handle new objects appearing in real-time
    local connection = Workspace.DescendantAdded:Connect(function(descendant)
        if filterFunc(descendant) then
            local billboard, highlight = CreateESP(descendant, descendant, nameFunc(descendant), color)
            if billboard and highlight then
                table.insert(espTable, billboard)
                table.insert(espTable, highlight)
            end
        end
    end)
    
    -- Store the connection so we can disconnect it later
    table.insert(espTable, connection)
end

-- Door ESP Toggle
Section:CreateToggle({
    Name = "Door ESP",
    CurrentValue = false,
    Flag = "DoorESP",
    Callback = function(value)
        if value then
            StartESP(DoorESPs,
                -- Filter function: checks if it's a model named "Door"
                function(obj) return obj:IsA("Model") and obj.Name == "Door" end,
                -- Name function: gets the door number and state (Opened/Locked)
                function(obj)
                    local doorNumber = tonumber(obj.Name:match("%d+")) or "Unknown"
                    local opened = obj:GetAttribute("Opened")
                    local locked = obj:GetAttribute("RequiresKey")
                    local doorState = if opened then "[Opened]" elseif locked then "[Locked]" else ""
                    return "Door " .. doorNumber .. " " .. doorState
                end,
                Color3.fromRGB(0, 255, 0) -- Green color
            )
        else
            RemoveESPs(DoorESPs)
        end
    end
})

-- Item ESP Toggle
Section:CreateToggle({
    Name = "Item ESP",
    CurrentValue = false,
    Flag = "ItemESP",
    Callback = function(value)
        if value then
            StartESP(ItemESPs,
                -- Filter function: checks if it's a model with an important item name
                function(obj) return obj:IsA("Model") and table.find(ImportantItems, obj.Name) end,
                -- Name function: returns the item's name
                function(obj) return obj.Name end,
                Color3.fromRGB(0, 255, 0) -- Green color
            )
        else
            RemoveESPs(ItemESPs)
        end
    end
})

-- Entity ESP Toggle
Section:CreateToggle({
    Name = "Entity ESP",
    CurrentValue = false,
    Flag = "EntityESP",
    Callback = function(value)
        if value then
            StartESP(EntityESPs,
                -- Filter function: checks if it's a model named "Entity"
                function(obj) return obj:IsA("Model") and obj.Name == "Entity" end,
                -- Name function: returns a generic name "Entity"
                function(obj) return "Entity" end,
                Color3.fromRGB(255, 0, 0) -- Red color
            )
        else
            RemoveESPs(EntityESPs)
        end
    end
})

-- Remove All ESP Button
Section:CreateButton({
    Name = "Remove All ESP",
    Callback = function()
        RemoveESPs(DoorESPs)
        RemoveESPs(ItemESPs)
        RemoveESPs(EntityESPs)
    end
})
