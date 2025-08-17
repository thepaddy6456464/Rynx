-- Rayfield UI library setup
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local win = Rayfield:CreateWindow({
    Name = "Rynx - Doors",
    LoadingTitle = "Rynx - Doors",
    LoadingSubtitle = "by Pulse",
    ConfigurationSaving = {Enabled = true, FolderName = "RynxDoorsHub", FileName = "RynxDoorsConfig"},
    Discord = {Enabled = true, Invite = "yourdiscordinvite", RememberJoins = true},
    KeySystem = false
})

local tab = win:CreateTab("Main", 4483362458)
local sec = tab:CreateSection("ESP Features")

local Workspace = game:GetService("Workspace")

local espObjects = {}
local ImportantItems = {
    "Key", "Lever", "Flashlight", "Gold", "Battery", "Lockpick", "Bandage", 
    "StarJug", "StarVial", "SkeletonKey", "Crucifix", "BreakerPole", "Fuse",
    "Generator", "LibraryBook", "Anchor", "GateLever", "TimerLever", "MiscPickups"
}

-- Billboard ESP function
local function CreateESP(parent, obj, name, color)
    if not obj or not obj.PrimaryPart then return end
    
    local bg = Instance.new("BillboardGui")
    bg.Name = "_ESP_BG"
    bg.Adornee = obj.PrimaryPart
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
    
    local hl = Instance.new("Highlight")
    hl.Adornee = obj.PrimaryPart
    hl.FillColor = color
    hl.OutlineTransparency = 0.7
    hl.Parent = obj
    
    return bg, hl
end

-- Remove all ESPs
local function RemoveAllESPs()
    for _, esp in pairs(espObjects) do
        if esp and esp.Parent then esp:Destroy() end
    end
    espObjects = {}
end

-- Generic ESP toggle function
local function toggleESP(enabled, type, filterFunc, nameFunc, color)
    RemoveAllESPs()
    if enabled then
        local connections = {}
        for _, obj in pairs(Workspace:GetDescendants()) do
            local esp, highlight = CreateESP(obj, obj, nameFunc(obj), color)
            if esp and highlight then
                table.insert(espObjects, esp)
                table.insert(espObjects, highlight)
            end
        end

        connections[type] = Workspace.DescendantAdded:Connect(function(c)
            if filterFunc(c) and c.PrimaryPart then
                local esp, highlight = CreateESP(c, c, nameFunc(c), color)
                if esp and highlight then
                    table.insert(espObjects, esp)
                    table.insert(espObjects, highlight)
                end
            end
        end)
    end
end

-- Door ESP toggle
tab:CreateToggle({
    Name="Door ESP",
    CurrentValue=false,
    Flag="DoorESP",
    Callback=function(v)
        RemoveAllESPs()
        if v then
            for _, room in pairs(Workspace:GetChildren()) do
                if room:FindFirstChild("Door") then
                    local door = room.Door
                    local doorNumber = tonumber(room.Name) + 1
                    local opened = door:GetAttribute("Opened")
                    local locked = door:GetAttribute("RequiresKey")
                    local doorState = if opened then "[Opened]" elseif locked then "[Locked]" else ""
                    
                    local text = "Door " .. doorNumber .. " " .. doorState
                    
                    local esp, highlight = CreateESP(door, door, text, Color3.fromRGB(0,255,0))
                    if esp and highlight then
                        table.insert(espObjects, esp)
                        table.insert(espObjects, highlight)
                    end
                end
            end
        end
    end
})

-- Item ESP toggle
tab:CreateToggle({
    Name="Item ESP",
    CurrentValue=false,
    Flag="ItemESP",
    Callback=function(v)
        toggleESP(v, "Item", 
            function(obj)
                return (obj:IsA("Tool") or (obj:IsA("Model") and table.find(ImportantItems, obj.Name) or obj.Name:match("Key") or obj.Name:match("GoldPile")))
            end,
            function(obj) return obj.Name end,
            Color3.fromRGB(0,255,0)
        )
    end
})

-- Entity ESP toggle
tab:CreateToggle({
    Name="Entity ESP",
    CurrentValue=false,
    Flag="EntityESP",
    Callback=function(v)
        toggleESP(v, "Entity",
            function(obj) return obj:IsA("Model") and obj.Name=="Entity" end,
            function(obj) return "Entity" end,
            Color3.fromRGB(255,0,0)
        )
    end
})

-- Remove all ESPs
tab:CreateButton({
    Name="Remove All ESP",
    Callback=function()
        RemoveAllESPs()
    end
})
