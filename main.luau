local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local win = Rayfield:CreateWindow({
    Name = "Rynx - Doors",
    LoadingTitle = "Rynx - Doors",
    LoadingSubtitle = "by Pulse",
    ConfigurationSaving = {Enabled = true, FolderName = "RynxDoorsHub", FileName = "RynxDoorsConfig"},
    Discord = {Enabled = true, Invite = "DgtcPQuEvG", RememberJoins = true},
    KeySystem = false
})

local tab = win:CreateTab("Main",4483362458)
local sec = tab:CreateSection("ESP Features")

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local DoorESPs = {}
local ItemESPs = {}
local EntityESPs = {}

-- Function to add a BillboardGui label to objects
local function CreateESP(parent, obj, name, color)
    local bg = Instance.new("BillboardGui")
    bg.Name = "_ESP_BG"
    bg.Adornee = obj
    bg.AlwaysOnTop = true
    bg.Size = UDim2.fromScale(2,1)
    bg.Parent = parent

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.fromScale(1,1)
    txt.BackgroundTransparency = 1
    txt.Text = name
    txt.Font = Enum.Font.SourceSansBold
    txt.TextScaled = true
    txt.TextColor3 = color
    txt.Parent = bg

    return bg
end

-- Function to add a glowing highlight
local function CreateHighlight(obj, color)
    local hl = Instance.new("Highlight")
    hl.Adornee = obj
    hl.FillColor = color
    hl.OutlineTransparency = 0.7
    hl.Parent = obj
    return hl
end

-- Remove ESPs and highlights
local function RemoveESP(tbl)
    for _,esp in pairs(tbl) do
        if esp and esp.Parent then esp:Destroy() end
    end
end

-- Doors
local function AddDoorESP()
    RemoveESP(DoorESPs)
    for _,door in pairs(Workspace:GetDescendants()) do
        if door:IsA("Model") and door.Name == "Door" and door.PrimaryPart then
            table.insert(DoorESPs, CreateESP(door, door.PrimaryPart, "Door", Color3.new(1,1,1)))
            table.insert(DoorESPs, CreateHighlight(door.PrimaryPart, Color3.new(0,1,1))) -- Highlight door
        end
    end
end

-- Items (keys, levers, flashlights, gold, etc.)
local ImportantItems = {"Key","Lever","Flashlight","Gold","Battery"} -- Add more if needed
local function AddItemESP()
    RemoveESP(ItemESPs)
    for _,item in pairs(Workspace:GetDescendants()) do
        if (item:IsA("Tool") or (item:IsA("Model") and table.find(ImportantItems,item.Name))) and item.PrimaryPart then
            table.insert(ItemESPs, CreateESP(item, item.PrimaryPart, item.Name, Color3.new(0,1,0)))
            table.insert(ItemESPs, CreateHighlight(item.PrimaryPart, Color3.new(0,1,0))) -- Highlight items
        end
    end
end

-- Entities
local function AddEntityESP()
    RemoveESP(EntityESPs)
    for _,en in pairs(Workspace:GetDescendants()) do
        if en:IsA("Model") and en.Name=="Entity" and en.PrimaryPart then
            table.insert(EntityESPs, CreateESP(en, en.PrimaryPart, "Entity", Color3.new(1,0,0)))
            table.insert(EntityESPs, CreateHighlight(en.PrimaryPart, Color3.new(1,0,0))) -- Highlight entities
        end
    end
end

-- Door ESP toggle
tab:CreateToggle({Name="Door ESP",CurrentValue=false,Flag="DoorESP",Callback=function(v)
    if v then
        AddDoorESP()
        Workspace.DescendantAdded:Connect(function(c)
            if c:IsA("Model") and c.Name=="Door" and c.PrimaryPart then
                table.insert(DoorESPs, CreateESP(c,c.PrimaryPart,"Door",Color3.new(1,1,1)))
                table.insert(DoorESPs, CreateHighlight(c.PrimaryPart, Color3.new(0,1,1)))
            end
        end)
    else RemoveESP(DoorESPs) end
end})

-- Item ESP toggle
tab:CreateToggle({Name="Item ESP",CurrentValue=false,Flag="ItemESP",Callback=function(v)
    if v then
        AddItemESP()
        Workspace.DescendantAdded:Connect(function(c)
            if (c:IsA("Tool") or (c:IsA("Model") and table.find(ImportantItems,c.Name))) and c.PrimaryPart then
                table.insert(ItemESPs, CreateESP(c,c.PrimaryPart,c.Name,Color3.new(0,1,0)))
                table.insert(ItemESPs, CreateHighlight(c.PrimaryPart, Color3.new(0,1,0)))
            end
        end)
    else RemoveESP(ItemESPs) end
end})

-- Entity ESP toggle
tab:CreateToggle({Name="Entity Notifier",CurrentValue=false,Flag="EntityNotifier",Callback=function(v)
    if v then
        AddEntityESP()
        Workspace.DescendantAdded:Connect(function(c)
            if c:IsA("Model") and c.Name=="Entity" and c.PrimaryPart then
                table.insert(EntityESPs, CreateESP(c,c.PrimaryPart,"Entity",Color3.new(1,0,0)))
                table.insert(EntityESPs, CreateHighlight(c.PrimaryPart, Color3.new(1,0,0)))
            end
        end)
    else RemoveESP(EntityESPs) end
end})

-- Remove all ESPs
tab:CreateButton({Name="Remove All ESP",Callback=function()
    RemoveESP(DoorESPs)
    RemoveESP(ItemESPs)
    RemoveESP(EntityESPs)
end})
