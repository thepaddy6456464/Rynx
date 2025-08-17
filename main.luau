-- Rayfield UIeeee
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Rynx - Doors",
    LoadingTitle = "Rynx Doors",
    LoadingSubtitle = "Made by Pulse",
    ConfigurationSaving = {Enabled = true, FolderName = "RynxDoors", FileName = "Config"},
    KeySystem = false
})

-- Create Main tab
local MainTab = Window:CreateTab("Main") -- EVERYTHING must be inside this tab

-- Toggle Variables
local Toggles = {}

-- ESP Colors
local Options = {
    DoorEspColor = Color3.fromRGB(0,255,0),
    ItemEspColor = Color3.fromRGB(0,255,0),
    EntityEspColor = Color3.fromRGB(255,0,0)
}

-- Temporary tables to track ESP
local ESPTable = {
    Door = {},
    Item = {},
    Entity = {}
}

-- Generic function to create highlight ESP
local function CreateESP(args)
    if not args.Object then return end
    local highlight = Instance.new("Highlight")
    highlight.Adornee = args.Object.PrimaryPart or args.Object
    highlight.FillColor = args.Color or Color3.new(0,1,0)
    highlight.OutlineColor = args.Color or Color3.new(0,1,0)
    highlight.Parent = args.Object

    -- Billboard text
    local bg = Instance.new("BillboardGui")
    bg.Adornee = args.Object.PrimaryPart or args.Object
    bg.Size = UDim2.fromScale(2,1)
    bg.AlwaysOnTop = true
    bg.Parent = args.Object
    local txt = Instance.new("TextLabel")
    txt.Text = args.Text or "ESP"
    txt.Font = Enum.Font.SourceSansBold
    txt.TextScaled = true
    txt.TextColor3 = args.Color or Color3.new(0,1,0)
    txt.BackgroundTransparency = 1
    txt.Size = UDim2.fromScale(1,1)
    txt.Parent = bg

    table.insert(ESPTable[args.Type], highlight)
    table.insert(ESPTable[args.Type], bg)
end

-- Door ESP
local function DoorESP(room)
    local door = room:FindFirstChild("Door")
    if door then
        local doorNumber = tonumber(room.Name) or 0
        local opened = room:GetAttribute("Opened")
        local locked = room:GetAttribute("RequiresKey")
        local doorState = if opened then "[Opened]" elseif locked then "[Locked]" else ""
        CreateESP({
            Type = "Door",
            Object = door,
            Text = "Door "..doorNumber.." "..doorState,
            Color = Options.DoorEspColor
        })
    end
end

-- Item ESP
local ImportantItems = {"Key","Lever","Flashlight","Gold","Battery","ElectricalKey","TimerLever","Fuse"}
local function ItemESP(item)
    if not item or not item.PrimaryPart then return end
    if not table.find(ImportantItems, item.Name) then return end
    local text = item.Name
    if item.Name == "Gold" then
        text = "Gold ["..(item:GetAttribute("GoldValue") or 0).."]"
    elseif item.Name == "TimerLever" then
        text = "Timer Lever [+ "..(item:FindFirstChild("TakeTimer") and item.TakeTimer.TextLabel.Text or "0").."]"
    elseif item.Name == "ElectricalKey" then
        text = "Electrical Key"
    end
    CreateESP({
        Type = "Item",
        Object = item,
        Text = text,
        Color = Options.ItemEspColor
    })
end

-- Entity ESP
local function EntityESP(entity)
    if not entity or not entity.PrimaryPart then return end
    CreateESP({
        Type = "Entity",
        Object = entity,
        Text = entity.Name,
        Color = Options.EntityEspColor
    })
end

-- Add toggles inside MainTab
Toggles.DoorESP = MainTab:CreateToggle({
    Name = "Door ESP",
    CurrentValue = false,
    Flag = "DoorESP",
    Callback = function(value)
        for _,room in pairs(workspace:GetChildren()) do
            if value then
                DoorESP(room)
            else
                for _,esp in pairs(ESPTable.Door) do
                    if esp then esp:Destroy() end
                end
                ESPTable.Door = {}
            end
        end
    end
})

Toggles.ItemESP = MainTab:CreateToggle({
    Name = "Item ESP",
    CurrentValue = false,
    Flag = "ItemESP",
    Callback = function(value)
        for _,item in pairs(workspace:GetDescendants()) do
            if value then
                ItemESP(item)
            else
                for _,esp in pairs(ESPTable.Item) do
                    if esp then esp:Destroy() end
                end
                ESPTable.Item = {}
            end
        end
    end
})

Toggles.EntityESP = MainTab:CreateToggle({
    Name = "Entity ESP",
    CurrentValue = false,
    Flag = "EntityESP",
    Callback = function(value)
        for _,entity in pairs(workspace:GetDescendants()) do
            if entity:IsA("Model") and value then
                EntityESP(entity)
            else
                for _,esp in pairs(ESPTable.Entity) do
                    if esp then esp:Destroy() end
                end
                ESPTable.Entity = {}
            end
        end
    end
})

-- Auto update ESP for new items/entities
workspace.DescendantAdded:Connect(function(desc)
    if Toggles.ItemESP.CurrentValue and table.find(ImportantItems, desc.Name) then
        ItemESP(desc)
    end
    if Toggles.EntityESP.CurrentValue and desc:IsA("Model") then
        EntityESP(desc)
    end
end)
