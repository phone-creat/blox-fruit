-- [[ CONFIGURATION ]]
getgenv().Config = {
    AutoFarm = false,
    FastAttack = true,
    AttackSpeed = 0.01, -- Siêu nhanh
    Distance = 7, -- Khoảng cách đứng trên đầu quái
    Weapon = "Melee" -- Tự cầm đấm/kiếm
}

-- [[ 1. HỆ THỐNG CHỐNG XOAY VÒNG & ANTI-BAN ]]
local function InitFix()
    local player = game.Players.LocalPlayer
    -- Tắt tự động quay của Roblox để tránh xoay vòng vòng
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.AutoRotate = not getgenv().Config.AutoFarm
    end
    
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldNamecall = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        if getnamecallmethod() == "FireServer" and tostring(self):find("Check") then
            return nil
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end

-- [[ 2. HÀM ĐÁNH SIÊU NHANH (FIX KHÔNG ĐÁNH) ]]
local function FastAttackM1()
    pcall(function()
        local player = game.Players.LocalPlayer
        local tool = player.Character:FindFirstChildOfClass("Tool")
        
        -- Nếu chưa cầm vũ khí thì tự cầm
        if not tool then
            for _, v in pairs(player.Backpack:GetChildren()) do
                if v:IsA("Tool") then
                    player.Character.Humanoid:EquipTool(v)
                    break
                end
            end
        end

        -- Thực hiện lệnh đánh trực tiếp vào Server
        local CombatRes = game:GetService("ReplicatedStorage").Remotes.CommF_
        CombatRes:InvokeServer("Attack", "1")
        game:GetService("ReplicatedStorage").Remotes.Validator:FireServer(math.random(1, 100))
        
        -- Click ảo để kích hoạt animation
        local VirtualUser = game:GetService("VirtualUser")
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(1280, 672))
    end)
end

-- [[ 3. VÒNG LẶP FARM CHÍNH (FIX LỖI XOAY) ]]
spawn(function()
    while wait() do
        if getgenv().Config.AutoFarm then
            pcall(function()
                local player = game.Players.LocalPlayer
                local character = player.Character
                local target = nil

                -- Tìm quái gần nhất
                for _, v in pairs(workspace.Enemies:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        target = v
                        break
                    end
                end

                if target then
                    -- Tắt AutoRotate khi đang farm
                    character.Humanoid.AutoRotate = false
                    
                    -- FIX XOAY: Giữ nhân vật đứng im tại một vị trí cố định trên quái
                    -- Angles(math.rad(-90), 0, 0) ép nhân vật nhìn thẳng xuống
                    character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, getgenv().Config.Distance, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                    
                    -- Chống rung lắc (BodyVelocity)
                    if not character.HumanoidRootPart:FindFirstChild("BodyVelocity") then
                        local bv = Instance.new("BodyVelocity", character.HumanoidRootPart)
                        bv.Velocity = Vector3.new(0,0,0)
                        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                    end

                    -- Thực hiện đánh
                    FastAttackM1()

                    -- Gom quái (Bring Mob)
                    target.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                    target.HumanoidRootPart.CanCollide = false
                else
                    -- Nếu không có quái, bật lại AutoRotate và xóa BodyVelocity
                    character.Humanoid.AutoRotate = true
                    if character.HumanoidRootPart:FindFirstChild("BodyVelocity") then
                        character.HumanoidRootPart.BodyVelocity:Destroy()
                    end
                end
            end)
        end
    end
end)

-- [[ 4. GIAO DIỆN RAYFIELD ]]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "🦈 FIX V5: ANTI-ROTATE & FAST ATTACK",
   LoadingTitle = "Đang áp dụng bản fix lỗi xoay...",
})

local MainTab = Window:CreateTab("Kaitun Pro", 4483362458)

MainTab:CreateToggle({
   Name = "Bật Auto Farm (Đã Fix Xoay)",
   CurrentValue = false,
   Callback = function(Value) 
      getgenv().Config.AutoFarm = Value 
      InitFix() -- Cập nhật trạng thái xoay
   end,
})

MainTab:CreateSlider({
   Name = "Khoảng cách (Distance)",
   Range = {5, 12},
   Increment = 1,
   CurrentValue = 7,
   Callback = function(Value) getgenv().Config.Distance = Value end,
})

Rayfield:Notify({Title = "Đã Fix Lỗi!", Content = "Nhân vật sẽ không còn xoay vòng vòng.", Duration = 5
    })
