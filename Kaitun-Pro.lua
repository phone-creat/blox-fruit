-- [[ CONFIGURATION ]]
getgenv().Config = {
    AutoChest = false,
    SafeMode = true,
    ChestDistance = 100000 -- Khoảng cách quét toàn bản đồ
}

-- [[ 1. HỆ THỐNG ANTI-BAN CHUYÊN DỤNG ]]
local function InitAntiBan()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldNamecall = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        if getnamecallmethod() == "FireServer" and (tostring(self):find("Check") or tostring(self):find("Teleport")) then
            return nil
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end
InitAntiBan()

-- [[ 2. HÀM TÌM RƯƠNG THẾ HỆ MỚI (FIX LỖI KHÔNG NHẬT) ]]
local function GetAllChests()
    local Chests = {}
    -- Quét toàn bộ Workspace để tìm các vật thể có tên "Chest"
    for _, v in pairs(game:GetService("Workspace"):GetDescendants()) do
        if v:IsA("TouchTransmitter") and (v.Parent.Name:find("Chest") or v.Parent.Name:find("Giver")) then
            table.insert(Chests, v.Parent)
        end
    end
    return Chests
end

-- [[ 3. LOGIC NHẬT RƯƠNG SIÊU TỐC ]]
spawn(function()
    while wait() do
        if getgenv().Config.AutoChest then
            pcall(function()
                local player = game.Players.LocalPlayer
                local character = player.Character
                local root = character:FindFirstChild("HumanoidRootPart")
                
                local allChests = GetAllChests()
                
                if #allChests > 0 then
                    for _, chest in pairs(allChests) do
                        if not getgenv().Config.AutoChest then break end
                        if chest:FindFirstChild("TouchTransmitter") then
                            -- Chế độ xuyên tường
                            if getgenv().Config.SafeMode then
                                character.Humanoid:ChangeState(11)
                            end

                            -- Bay tới rương
                            root.CFrame = chest.CFrame
                            
                            -- Lệnh chạm ảo (Kích hoạt nhặt rương ngay lập tức)
                            firetouchinterest(root, chest, 0)
                            wait(0.1)
                            firetouchinterest(root, chest, 1)
                            
                            wait(0.2) -- Đợi rương biến mất rồi đi rương tiếp theo
                        end
                    end
                else
                    -- Nếu không còn rương, đợi 5s để rương hồi (respawn)
                    print("Hết rương trên Server, đang đợi...")
                    wait(5)
                end
            end)
        end
    end
end)

-- [[ 4. GIAO DIỆN ]]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "💰 GEMINI FIX: CHEST MASTER",
   LoadingTitle = "Đang áp dụng Deep Scan rương...",
})

local Tab = Window:CreateTab("Auto Chest", 4483362458)

Tab:CreateToggle({
   Name = "Bật Nhặt Rương (Đã Fix)",
   CurrentValue = false,
   Callback = function(Value) getgenv().Config.AutoChest = Value end,
})

Tab:CreateLabel("Hệ thống sẽ tự động quét rương ẩn.")
Tab:CreateLabel("Lưu ý: Nếu đứng im là do Server hết rương.")

Rayfield:Notify({Title = "Đã Fix Lỗi Nhặt", Content = "Sử dụng firetouchinterest để nhặt cực nhanh.", Duration = 5
    })
