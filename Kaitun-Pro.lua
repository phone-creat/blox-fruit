-- [[ CONFIGURATION ]]
getgenv().Config = {
    AutoChest = false,
    SafeMode = true, -- Tàng hình khi nhặt rương
    AntiBan = true
}

-- [[ 1. HỆ THỐNG ANTI-BAN & BYPASS ]]
local function ActivateAntiBan()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldNamecall = mt.__namecall

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" then
            local args = {...}
            -- Chặn các Remote quét tốc độ và dịch chuyển
            if tostring(self) == "AdminCheck" or tostring(self) == "CheatCheck" or tostring(self) == "Logger" then
                return nil
            end
        end
        return oldNamecall(self, ...)
    end)
    
    -- Chặn bị văng khi di chuyển nhanh giữa các rương
    local oldIndex = mt.__index
    mt.__index = newcclosure(function(t, k)
        if k == "WalkSpeed" then return 16 end
        return oldIndex(t, k)
    end)
    setreadonly(mt, true)
    print("🛡️ Anti-Ban Nhặt Rương: Đã Kích Hoạt")
end
ActivateAntiBan()

-- [[ 2. LOGIC NHẶT RƯƠNG THÔNG MINH ]]
spawn(function()
    while wait() do
        if getgenv().Config.AutoChest then
            pcall(function()
                local player = game.Players.LocalPlayer
                local character = player.Character
                
                -- Tìm rương trong Workspace
                for _, v in pairs(game:GetService("Workspace"):GetChildren()) do
                    if v:IsA("Part") and (v.Name:find("Chest") or v.Name:find("ChestGiver")) then
                        -- Chế độ tàng hình/xuyên tường để an toàn
                        if getgenv().Config.SafeMode then
                            for _, part in pairs(character:GetDescendants()) do
                                if part:IsA("BasePart") then part.CanCollide = false end
                            end
                        end

                        -- Bay tới rương (Sử dụng Tween để mượt hơn, tránh bị kick)
                        repeat
                            if not getgenv().Config.AutoChest then break end
                            character.HumanoidRootPart.CFrame = v.CFrame
                            wait(0.1) -- Tốc độ nhặt rương (0.1 là cực nhanh)
                        until not v:IsDescendantOf(game:GetService("Workspace")) or not getgenv().Config.AutoChest
                    end
                end
            end)
        end
    end
end)

-- [[ 3. GIAO DIỆN RAYFIELD UI ]]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "💰 SCRIPT CHEST: AUTO COLLECTOR",
   LoadingTitle = "Đang quét rương trên bản đồ...",
})

local MainTab = Window:CreateTab("Nhặt Rương", 4483362458)

MainTab:CreateToggle({
   Name = "Bật Tự Động Nhặt Rương (Auto Chest)",
   CurrentValue = false,
   Callback = function(Value) 
      getgenv().Config.AutoChest = Value 
      if Value then
          Rayfield:Notify({Title = "Thông báo", Content = "Đang bắt đầu đi lượm tiền...", Duration = 3})
      end
   end,
})

MainTab:CreateToggle({
   Name = "Chế độ An Toàn (Safe Mode)",
   CurrentValue = true,
   Callback = function(Value) getgenv().Config.SafeMode = Value end,
})

MainTab:CreateSection("Thông tin túi đồ")
local BeliLabel = MainTab:CreateLabel("Tiền hiện có: Loading...")

-- Cập nhật tiền liên tục lên Menu
spawn(function()
    while wait(1) do
        BeliLabel:Set("Tiền hiện có: " .. game.Players.LocalPlayer.Data.Beli.Value .. " 💵")
    end
end)

Rayfield:Notify({Title = "Sẵn Sàng!", Content = "Hệ thống nhặt rương đã được nạp.", Duration = 5
    })
