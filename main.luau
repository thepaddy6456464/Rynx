local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))() -- rayfield ui, super easy to use

local win = Rayfield:CreateWindow({
    Name = "Rynx - Doors", 
    LoadingTitle = "Rynx - Doors", 
    LoadingSubtitle = "by Pulse",
    ConfigurationSaving = {Enabled = true, FolderName = "RynxDoorsHub", FileName = "RynxDoorsConfig"}, -- saves settings so u dont have to redo
    Discord = {Enabled = true, Invite = "DgtcPQuEvG", RememberJoins = true}, -- makes it look fancy
    KeySystem = false -- no key cuz lazy
})

local tab = win:CreateTab("Main",4483362458) -- main tab, icons r just for show
local sec = tab:CreateSection("ESP Features") 

local Players = game:GetService("Players") 
local Workspace = game:GetService("Workspace") 
local LocalPlayer = Players.LocalPlayer -- me

local DoorESPs = {} 
local ItemESPs = {} 
local EntityESPs = {}

-- makes floating text lol, the actual esp thing
local function CreateESP(parent, obj, name, color)
    local bg = Instance.new("BillboardGui")
    bg.Name = "_ESP_BG"
    bg.Adornee = obj 
    bg.AlwaysOnTop = true 
    bg.Size = UDim2.fromScale(2,1) -- kinda big lol
    bg.Parent = parent 

    local txt = Instance.new("TextLabel") 
    txt.Size = UDim2.fromScale(1,1) 
    txt.BackgroundTransparency = 1 
    txt.Text = name 
    txt.Font = Enum.Font.SourceSansBold -- bold af
    txt.TextScaled = true 
    txt.TextColor3 = color 
    txt.Parent = bg
    return bg -- return the esp so we can remove later
end

-- nukes all esp in a table, cleanup
local function RemoveESP(tbl)
    for _,esp in pairs(tbl) do
        if esp and esp.Parent then esp:Destroy() end -- kill it lol
    end
end

-- add esp to doors, only works if they got primarypart
local function AddDoorESP()
    RemoveESP(DoorESPs) -- clean first
    for _,door in pairs(Workspace:GetDescendants()) do
        if door:IsA("Model") and door.Name == "Door" and door.PrimaryPart then
            table.insert(DoorESPs, CreateESP(door, door.PrimaryPart, "Door", Color3.new(1,1,1))) -- white lol
        end
    end
    -- btw this only works on existing doors, not future ones
end

-- add esp to items, green so u can see
local function AddItemESP()
    RemoveESP(ItemESPs)
    for _,item in pairs(Workspace:GetDescendants()) do
        if (item:IsA("Tool") or (item:IsA("Model") and item.Name == "Item")) and item.PrimaryPart then
            table.insert(ItemESPs, CreateESP(item, item.PrimaryPart, "Item", Color3.new(0,1,0))) -- green text
        end
    end
    -- yeah items can be tools or models lol
end

-- entities r red, spooky
local function AddEntityESP()
    RemoveESP(EntityESPs)
    for _,en in pairs(Workspace:GetDescendants()) do
        if en:IsA("Model") and en.Name == "Entity" and en.PrimaryPart then
            table.insert(EntityESPs, CreateESP(en, en.PrimaryPart, "Entity", Color3.new(1,0,0))) -- scary red
        end
    end
    -- red cuz scary af
end

-- toggle door esp
tab:CreateToggle({Name="Door ESP",CurrentValue=false,Flag="DoorESP",Callback=function(v)
    if v then
        AddDoorESP() -- make em appear
        Workspace.DescendantAdded:Connect(function(c) -- add new doors too
            if c:IsA("Model") and c.Name=="Door" and c.PrimaryPart then
                table.insert(DoorESPs, CreateESP(c,c.PrimaryPart,"Door",Color3.new(1,1,1)))
            end
        end)
    else RemoveESP(DoorESPs) end -- remove when off
end})

-- toggle item esp
tab:CreateToggle({Name="Item ESP",CurrentValue=false,Flag="ItemESP",Callback=function(v)
    if v then
        AddItemESP()
        Workspace.DescendantAdded:Connect(function(c) -- add new items too
            if (c:IsA("Tool") or (c:IsA("Model") and c.Name=="Item")) and c.PrimaryPart then
                table.insert(ItemESPs, CreateESP(c,c.PrimaryPart,"Item",Color3.new(0,1,0)))
            end
        end)
    else RemoveESP(ItemESPs) end -- clean when off
end})

-- toggle entity esp
tab:CreateToggle({Name="Entity Notifier",CurrentValue=false,Flag="EntityNotifier",Callback=function(v)
    if v then
        AddEntityESP() -- scary ones
        Workspace.DescendantAdded:Connect(function(c)
            if c:IsA("Model") and c.Name=="Entity" and c.PrimaryPart then
                table.insert(EntityESPs, CreateESP(c,c.PrimaryPart,"Entity",Color3.new(1,0,0)))
            end
        end)
    else RemoveESP(EntityESPs) end -- off = gone
end})

-- quick button to remove all esp, instant cleanup
tab:CreateButton({Name="Remove All ESP",Callback=function()
    RemoveESP(DoorESPs)
    RemoveESP(ItemESPs)
    RemoveESP(EntityESPs)
    -- clean sweep lol
end})

-- quick button to add esp now, manual
tab:CreateButton({Name="Add ESP Now",Callback=function()
    AddDoorESP()
    AddItemESP()
    AddEntityESP()
    -- manual mode for lazy ppl
end})

Rayfield:Init() -- start the ui lol
