local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'Admin Panel',
    Center = true,
    AutoShow = true
})

local Tabs = {
    Main = Window:AddTab('ESP'),
    ['UI Settings'] = Window:AddTab('UI Settings')
}

-- Left Groupboxes
local DoorGroup = Tabs.Main:AddLeftGroupbox('Door ESP')
local EntityGroup = Tabs.Main:AddLeftGroupbox('Entity Notifier')
local ItemGroup = Tabs.Main:AddLeftGroupbox('Item ESP')

local LocalPlayer = game.Players.LocalPlayer
local DoorESPTable = {}
local EntityTable = {}
local ItemTable = {}

-- Door ESP Function
local function Esp(Parent, Adornee, Text, FillColor, OutlineColor)
    local BillboardGui = Instance.new("BillboardGui", Parent)
    local TextLabel = Instance.new("TextLabel", BillboardGui)
    local Highlight = Instance.new("Highlight", Parent)
    BillboardGui.Adornee = Adornee
    BillboardGui.AlwaysOnTop = true
    BillboardGui.Size = UDim2.fromScale(1,1)
    BillboardGui.Name = "_DoorESP_BG"
    Highlight.Name = "_DoorESP_HL"
    Highlight.Adornee = Parent
    Highlight.FillColor = FillColor
    Highlight.OutlineColor = OutlineColor
    TextLabel.Size = UDim2.fromScale(1,1)
    TextLabel.TextStrokeTransparency = 0
    TextLabel.Font = Enum.Font.SourceSans
    TextLabel.TextSize = 20
    TextLabel.TextColor3 = FillColor
    TextLabel.BackgroundTransparency = 1
    TextLabel.TextTransparency = 1
    TextLabel.Text = Text
    local runService = game:GetService("RunService")
    runService.Heartbeat:Connect(function()
        if Parent and Parent:IsDescendantOf(workspace) then
            local distance = (workspace.CurrentCamera.CFrame.Position - Adornee:GetPivot().Position).Magnitude
            TextLabel.Text = Text.."\n["..string.format(distance<=9.9 and "%.1f" or "%.0f",distance).."]"
        end
    end)
    return {highlight=Highlight,billboard=BillboardGui}
end

local function RemoveDoorESP(Parent)
    for _,obj in ipairs(Parent:GetChildren()) do
        if obj.Name=="_DoorESP_BG" or obj.Name=="_DoorESP_HL" then obj:Destroy() end
    end
end

local function AddESPToDoors()
    for _,door in ipairs(workspace:GetDescendants()) do
        if door:IsA("Model") and door.Name=="Door" and door:FindFirstChild("Lock") and door.PrimaryPart then
            local entry = Esp(door, door.PrimaryPart, "Door", Color3.new(1,1,1), Color3.new(1,1,1))
            table.insert(DoorESPTable, {door=door, objects=entry})
        end
    end
end

local function RemoveAllDoorESPs()
    for _,data in ipairs(DoorESPTable) do RemoveDoorESP(data.door) end
    DoorESPTable={}
end

DoorGroup:AddToggle('DoorESP', {Text='Enable Door ESP', Default=false}):OnChanged(function(Value)
    if Value then AddESPToDoors() else RemoveAllDoorESPs() end
end)

-- Entity Notifier Function
local function EntityNotifier(EntityModel)
    local BillboardGui = Instance.new("BillboardGui", EntityModel)
    local TextLabel = Instance.new("TextLabel", BillboardGui)
    BillboardGui.Adornee = EntityModel.PrimaryPart or EntityModel:FindFirstChildWhichIsA("BasePart")
    BillboardGui.AlwaysOnTop = true
    BillboardGui.Size = UDim2.fromScale(1,1)
    TextLabel.Size = UDim2.fromScale(1,1)
    TextLabel.Text = "Entity Detected!"
    TextLabel.TextColor3 = Color3.new(1,0,0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Font = Enum.Font.SourceSans
    TextLabel.TextScaled = true
    table.insert(EntityTable, BillboardGui)
end

EntityGroup:AddToggle('EntityNotifierToggle', {Text='Enable Entity Notifier', Default=false}):OnChanged(function(Value)
    if Value then
        workspace.ChildAdded:Connect(function(child)
            if child.Name == "Entity" then EntityNotifier(child) end
        end)
    else
        for _,gui in ipairs(EntityTable) do gui:Destroy() end
        EntityTable={}
    end
end)

-- Item ESP Function
local function ItemESP(ItemModel)
    local BillboardGui = Instance.new("BillboardGui", ItemModel)
    local TextLabel = Instance.new("TextLabel", BillboardGui)
    BillboardGui.Adornee = ItemModel.PrimaryPart or ItemModel:FindFirstChildWhichIsA("BasePart")
    BillboardGui.AlwaysOnTop = true
    BillboardGui.Size = UDim2.fromScale(1,1)
    TextLabel.Size = UDim2.fromScale(1,1)
    TextLabel.Text = "Item!"
    TextLabel.TextColor3 = Color3.new(0,1,0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Font = Enum.Font.SourceSans
    TextLabel.TextScaled = true
    table.insert(ItemTable, BillboardGui)
end

ItemGroup:AddToggle('ItemESP', {Text='Enable Item ESP', Default=false}):OnChanged(function(Value)
    if Value then
        workspace.ChildAdded:Connect(function(child)
            if child:IsA("Tool") or (child:IsA("Model") and child.Name == "Item") then
                ItemESP(child)
            end
        end)
    else
        for _,gui in ipairs(ItemTable) do gui:Destroy() end
        ItemTable={}
    end
end)

-- Hand library to managers
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetFolder('AdminPanel')
ThemeManager:SetFolder('AdminPanel')
