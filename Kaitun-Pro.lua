-- [[ SETTINGS ]]
getgenv().Config = {
    AutoFarm = false,
    FastAttack = true,
    AttackMode = "Ultra", -- Normal, Fast, Ultra
    AttackSpeed = 0.05, -- Siêu nhanh cho Ultra
    Distance = 7,
    Weapon = "Melee"
}

-- [[ 1. HỆ THỐNG ANTI-BAN CAO CẤP ]]
local function BypassSystem()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldNamecall = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" and (tostring(self):find("Check") or tostring(self):find("Admin")) then
            return nil
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end
BypassSystem()

-- [[ 2. MODULE FAST ATTACK (HỦY ANIMATION) ]]
local function DoFastAttack()
    local player = game.Players.LocalPlayer
    local combat = player.Character:FindFirstChildOfClass("Tool")
    
    if combat then
        -- Hủy bỏ độ trễ của động tác vung tay
        if getgenv().Config.AttackMode == "Ultra" then
            game:GetService("ReplicatedStorage").Remotes.Validator:FireServer(math.random(1, 100))
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Attack", "1")
        elseif getgenv().Config.AttackMode == "Fast" then
            game:GetService("ReplicatedStorage").Remotes.Validator:FireServer(math.random(1, 100))
            wait(0.05)
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Attack", "1")
        end
        
        -- Mô phỏng hit-box liên tục
        local VirtualUser = game:GetService("VirtualUser")
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(1280, 672))
    end
end

-- [[ 3. AUTO EQUIP & FARM LOOP ]]
spawn(function()
    while wait() do
        if getgenv().Config.AutoFarm then
            pcall(function()
                -- Tự cầm vũ khí
                local player = game.Players.LocalPlayer
                if not player.Character:FindFirstChildOfClass("Tool") then
                    for _, v in pairs(player.Backpack:GetChildren()) do
                        if v.ToolTip == getgenv().Config.Weapon or v:IsA("Tool") then
                            player.Character.Humanoid:EquipTool(v)
                        end
                    end
                end

                -- Tìm và bay tới quái (Fix lỗi bay)
                for _, v in pairs(workspace.Enemies:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        -- Giữ vị trí ổn định
                        player.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, getgenv().Config.Distance, 0)
                        
                        -- Chạy Fast Attack
                        if getgenv().Config.FastAttack then
                            DoFastAttack()
                        end
                        
                        -- Gom quái (Bring Mob)
                        v.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
                        v.HumanoidRootPart.CanCollide = false
                        wait(getgenv().Config.AttackSpeed)
                    end
                end
            end)
        end
    end
end)

-- [[ 4. GIAO DIỆN RAYFIELD ]]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "⚡ GEMINI SPEED: FAST ATTACK EDITION",
   LoadingTitle = "Đang nạp Module Fast Attack...",
   ConfigurationSaving = {Enabled = true, FolderName = "GeminiSpeed"}
})

local FarmTab = Window:CreateTab("Kaitun & Farm", 4483362458)

FarmTab:CreateToggle({
   Name = "Bật Auto Farm & Fast Attack",
   CurrentValue = false,
   Callback = function(Value) getgenv().Config.AutoFarm = Value end,
})

FarmTab:CreateDropdown({
   Name = "Chế độ Fast Attack",
   Options = {"Normal", "Fast", "Ultra"},
   CurrentOption = "Ultra",
   Callback = function(Option) getgenv().Config.AttackMode = Option end,
})

FarmTab:CreateSlider({
   Name = "Khoảng cách Farm (Distance)",
   Range = {5, 15},
   Increment = 1,
   CurrentValue = 7,
   Callback = function(Value) getgenv().Config.Distance = Value end,
})

Rayfield:Notify({
   Title = "Fast Attack Ready!",
   Content = "Chế độ Ultra có thể gây lag nhẹ cho Server, hãy cẩn thận.",
   Duration = 5
})
