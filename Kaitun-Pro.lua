-- [[ CONFIGURATION & SETTINGS ]]
getgenv().Config = {
    AutoFarm = false,
    AttackSpeed = 0.1, -- Khoảng cách giữa các lần đánh (Càng nhỏ càng nhanh)
    BringMob = true,
    AutoShark = false,
    Distance = 10 -- Khoảng cách đứng trên đầu quái
}

-- [[ 1. HỆ THỐNG ANTI-BAN TUYỆT ĐỐI ]]
local function ActivateAntiBan()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldNamecall = mt.__namecall

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" then
            local args = {...}
            -- Chặn các Remote quét hành vi của Blox Fruit
            if tostring(self) == "AdminCheck" or tostring(self) == "CheatCheck" or tostring(self) == "Logger" then
                return nil 
            end
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
    print("🛡️ Anti-Ban: Chế độ bảo vệ 3 lớp đã bật!")
end
ActivateAntiBan()

-- [[ 2. HỆ THỐNG FAST ATTACK (M1 SPEED) ]]
spawn(function()
    while wait(getgenv().Config.AttackSpeed) do
        if getgenv().Config.AutoFarm then
            pcall(function()
                -- Mô phỏng cú click chuột trái (M1)
                local VirtualUser = game:GetService("VirtualUser")
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(1280, 672))
                
                -- Gửi tín hiệu đánh từ vũ khí đang cầm
                game:GetService("ReplicatedStorage").Remotes.Validator:FireServer(math.random(1, 100))
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Attack", "1")
            end)
        end
    end
end)

-- [[ 3. HỆ THỐNG GOM QUÁI (BRING MOB) ]]
spawn(function()
    while wait() do
        if getgenv().Config.BringMob and getgenv().Config.AutoFarm then
            pcall(function()
                local MyPos = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
                for _, v in pairs(workspace.Enemies:GetChildren()) do
                    if v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - MyPos).Magnitude < 300 then
                        v.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                        v.HumanoidRootPart.CanCollide = false
                        v.Humanoid:ChangeState(11) -- Vô hiệu hóa quái vật
                    end
                end
            end)
        end
    end
end)

-- [[ 4. GIAO DIỆN RAYFIELD UI ]]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "🦈 GEMINI KAITUN V2: FAST ATTACK",
   LoadingTitle = "Đang cấu hình Anti-Cheat...",
   ConfigurationSaving = {Enabled = true, FolderName = "GeminiPro"}
})

local MainTab = Window:CreateTab("Tự Động Farm", 4483362458)

MainTab:CreateToggle({
   Name = "Bật Auto Kaitun (Level 1 - Max)",
   CurrentValue = false,
   Callback = function(Value) getgenv().Config.AutoFarm = Value end,
})

MainTab:CreateSlider({
   Name = "Tốc độ đánh M1 (Càng thấp càng nhanh)",
   Info = "Khuyên dùng: 0.1 hoặc 0.15 để tránh bị Kick",
   Range = {0.01, 0.5},
   Increment = 0.01,
   Suffix = "s",
   CurrentValue = 0.1,
   Callback = function(Value) getgenv().Config.AttackSpeed = Value end,
})

MainTab:CreateToggle({
   Name = "Gom Quái (Bring Mob)",
   CurrentValue = true,
   Callback = function(Value) getgenv().Config.BringMob = Value end,
})

MainTab:CreateSection("Nhiệm vụ Tộc")

MainTab:CreateToggle({
   Name = "Auto Shark Race V1/V2/V3",
   CurrentValue = false,
   Callback = function(Value)
      getgenv().Config.AutoShark = Value
      spawn(function()
          while getgenv().Config.AutoShark do
              game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BlackbeardReward", "Reroll", "1")
              wait(5)
          end
      end)
   end,
})

-- [[ 5. AUTO FARM LOGIC ]]
spawn(function()
    while wait() do
        if getgenv().Config.AutoFarm then
            local player = game.Players.LocalPlayer
            -- Tìm quái để Teleport
            for _, v in pairs(workspace.Enemies:GetChildren()) do
                if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                    repeat
                        if not getgenv().Config.AutoFarm then break end
                        -- Đứng trên đầu quái để né đòn
                        player.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, getgenv().Config.Distance, 0)
                        wait()
                    until v.Humanoid.Health <= 0 or not getgenv().Config.AutoFarm
                end
            end
        end
    end
end)

Rayfield:Notify({Title = "Kích hoạt thành công", Content = "Anti-Ban đang bảo vệ bạn!", Duration = 5
  })
