-- [[ CONFIGURAÇÕES GLOBAIS ]]
getgenv().Config = {
    AutoFarm = false,
    Distance = 25,
    AutoStats = false,
    StatType = "Melee", -- Opções: "Melee", "Defense", "Sword", "Blox Fruit"
    AntiAFK = true,
    FastAttack = true
}

-- 1. DATABASE DE QUESTS (MAPEAMENTO DE NÍVEL E POSIÇÃO)
-- Adicione novas coordenadas conforme você muda de ilha
local Quests = {
    {Level = 0, Name = "Bandit Quest 1", NPC = CFrame.new(1059, 16, 1545), Enemy = "Bandit"},
    {Level = 15, Name = "Monkey Quest 1", NPC = CFrame.new(-1598, 36, 153), Enemy = "Monkey"},
    {Level = 30, Name = "Gorilla Quest 1", NPC = CFrame.new(-1216, 28, -492), Enemy = "Gorilla"},
    {Level = 60, Name = "Pirate Quest 1", NPC = CFrame.new(-1141, 4, 3833), Enemy = "Pirate"}
}

-- 2. MOTOR DE MOVIMENTAÇÃO (TWEEN SERVICE ANTI-BAN)
local function SmoothTween(Target)
    local char = game.Players.LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local dist = (Target.Position - char.HumanoidRootPart.Position).Magnitude
    local speed = 275 -- Velocidade otimizada para 2026
    local tween = game:GetService("TweenService"):Create(
        char.HumanoidRootPart, 
        TweenInfo.new(dist/speed, Enum.EasingStyle.Linear), 
        {CFrame = Target}
    )
    tween:Play()
    return tween
end

-- 3. INTERFACE DE USUÁRIO (RAYFIELD)
local Rayfield = loadstring(game:HttpGet('sirius.menu'))()
local Window = Rayfield:CreateWindow({
   Name = "MASTER HUB | BLOX FRUITS 2026",
   ConfigurationSaving = { Enabled = true, FileName = "MasterHubData" }
})

-- ABAS
local MainTab = Window:CreateTab("Auto Farm", 4483362458)
local StatsTab = Window:CreateTab("Status", 4483362458)

-- BOTÕES E OPÇÕES
MainTab:CreateToggle({
   Name = "Ativar Auto Farm Completo",
   CurrentValue = false,
   Callback = function(Value) getgenv().Config.AutoFarm = Value end,
})

MainTab:CreateSlider({
   Name = "Distância do Farm",
   Range = {0, 60},
   Increment = 1,
   CurrentValue = 25,
   Callback = function(Value) getgenv().Config.Distance = Value end,
})

StatsTab:CreateToggle({
   Name = "Auto Pontos de Status",
   CurrentValue = false,
   Callback = function(Value) getgenv().Config.AutoStats = Value end,
})

StatsTab:CreateDropdown({
   Name = "Focar em:",
   Options = {"Melee", "Defense", "Sword", "Blox Fruit"},
   CurrentOption = "Melee",
   Callback = function(Option) getgenv().Config.StatType = Option end,
})

-- 4. LÓGICA DE EXECUÇÃO (INTELIGÊNCIA DO SCRIPT)

-- Loop de Farm e Quest
task.spawn(function()
    while task.wait() do
        if getgenv().Config.AutoFarm then
            pcall(function()
                local player = game.Players.LocalPlayer
                local lvl = player.Data.Level.Value
                local currentQuest
                
                -- Escolhe a melhor quest para o nível atual
                for _, q in pairs(Quests) do
                    if lvl >= q.Level then currentQuest = q end
                end

                if not player.PlayerGui.Main:FindFirstChild("Quest") then
                    -- Se não tem missão, voa até o NPC e aceita
                    SmoothTween(currentQuest.NPC)
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", currentQuest.Name, 1)
                else
                    -- Se tem missão, procura o inimigo
                    local enemyFound = false
                    for _, e in pairs(workspace.Enemies:GetChildren()) do
                        if e.Name == currentQuest.Enemy and e:FindFirstChild("Humanoid") and e.Humanoid.Health > 0 then
                            enemyFound = true
                            repeat task.wait()
                                -- Posiciona o jogador em cima do inimigo
                                SmoothTween(e.HumanoidRootPart.CFrame * CFrame.new(0, getgenv().Config.Distance, 0))
                                -- Ataque Direto (Fast Attack)
                                game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("Attack")
                            until not getgenv().Config.AutoFarm or not e.Parent or e.Humanoid.Health <= 0
                        end
                    end
                    -- Se não achou no workspace, tenta achar no mapa geral
                    if not enemyFound then
                        for _, e in pairs(workspace:GetChildren()) do
                            if e.Name == currentQuest.Enemy and e:FindFirstChild("HumanoidRootPart") then
                                SmoothTween(e.HumanoidRootPart.CFrame)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Loop de Auto Status
task.spawn(function()
    while task.wait(1) do
        if getgenv().Config.AutoStats then
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AddPoint", getgenv().Config.StatType, 1)
        end
    end
end)

-- 5. ANTI-AFK (IMPEDE DISCONNECT)
if getgenv().Config.AntiAFK then
    game.Players.LocalPlayer.Idled:Connect(function()
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end)
end

Rayfield:Notify({Title = "Master Hub 2026", Content = "Script carregado com sucesso!", Duration = 5})
