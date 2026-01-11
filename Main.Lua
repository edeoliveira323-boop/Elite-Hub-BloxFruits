-- [[ MASTER HUB BLOX FRUITS 2026 ]]
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('raw.githubusercontent.com'))()
end)

if not success then 
    warn("Erro ao carregar a interface. Verifique sua conexão.")
    return 
end

getgenv().Config = {
    AutoFarm = false,
    Distance = 25,
    AntiAFK = true
}

local Window = Rayfield:CreateWindow({
   Name = "Elite Hub | Blox Fruits 2026",
   LoadingTitle = "Carregando...",
   ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("Farm", 4483362458)

MainTab:CreateToggle({
   Name = "Ativar Auto Farm",
   CurrentValue = false,
   Callback = function(Value) getgenv().Config.AutoFarm = Value end,
})

-- Loop de Teste (Verifica no F9 se está rodando)
task.spawn(function()
    while task.wait(1) do
        if getgenv().Config.AutoFarm then
            print("Script ativo e processando lógica de farm...")
        end
    end
end)

Rayfield:Notify({Title = "Sucesso", Content = "Hub Executado!", Duration = 5})
