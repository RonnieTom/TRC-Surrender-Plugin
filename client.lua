-- 投降插件客户端脚本
local surrenderState = 0 -- 0: 正常, 1: 举手, 2: 跪下, 3: 趴下, 4: 跪着抱头
local isSurrendering = false
local lastSurrenderState = 0

-- 动画字典和名称
local animations = {
    handsUp = {dict = "missminuteman_1ig_2", anim = "handsup_enter"},
    kneeling = {dict = "random@arrests", anim = "kneeling_arrest_idle"},
    prone = {dict = "move_crawlprone_pistol", anim = "front"},
    kneelingHandsUp = {dict = "mp_arresting", anim = "idle"}
}

-- 引入配置和多语言
local locale = Config and Config.Locale

-- 加载动画字典
function LoadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(0)
    end
end

-- 播放动画
function PlayAnimation(dict, anim, flag)
    LoadAnimDict(dict)
    TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, -8.0, -1, flag, 0, false, false, false)
end

-- 停止动画
function StopAnimation()
    ClearPedTasks(PlayerPedId())
end

-- 显示帮助提示（GTA5原版左上角Help Text）
function ShowNotification(text)
    SendNUIMessage({action = "show", text = text, position = Config.NotificationPosition or "top-left"})
end

function HideNotification()
    SendNUIMessage({action = "hide"})
end

-- 显示状态通知
function ShowStateNotification()
    if surrenderState == 1 then -- 举手状态
        ShowNotification(Lang[locale].handsup)
    elseif surrenderState == 2 then -- 跪下状态
        ShowNotification(Lang[locale].kneel)
    elseif surrenderState == 3 then -- 趴下状态
        ShowNotification(Lang[locale].prone)
    elseif surrenderState == 4 then -- 跪着抱头状态
        ShowNotification(Lang[locale].kneel_handsup)
    end
end


-- 开始举手
function StartHandsUp()
    lastSurrenderState = surrenderState
    ClearPedTasks(PlayerPedId())
    surrenderState = 1
    isSurrendering = true
    FreezeEntityPosition(PlayerPedId(), false)
    Citizen.CreateThread(function()
        RequestAnimDict(animations.handsUp.dict)
        while not HasAnimDictLoaded(animations.handsUp.dict) do
            Citizen.Wait(100)
        end
        TaskPlayAnim(PlayerPedId(), animations.handsUp.dict, animations.handsUp.anim, 8.0, 8.0, -1, 50, 0, false, false, false)
    end)
    ShowStateNotification()
end

-- 开始跪下
function StartKneeling()
    lastSurrenderState = surrenderState
    ClearPedTasks(PlayerPedId())
    surrenderState = 2
    isSurrendering = true
    Citizen.CreateThread(function()
        RequestAnimDict(animations.kneeling.dict)
        while not HasAnimDictLoaded(animations.kneeling.dict) do
            Citizen.Wait(100)
        end
        TaskPlayAnim(PlayerPedId(), animations.kneeling.dict, animations.kneeling.anim, 1.8, 3.5, -1, 1, 0, false, false, false)
    end)
    ShowStateNotification()
end

-- 开始趴下
function StartProne()
    lastSurrenderState = surrenderState
    ClearPedTasks(PlayerPedId())
    surrenderState = 3
    isSurrendering = true
    Citizen.CreateThread(function()
        local ped = PlayerPedId()
        RequestAnimDict("missfbi3_sniping")
        while not HasAnimDictLoaded("missfbi3_sniping") do
            Citizen.Wait(10)
        end
        TaskPlayAnim(ped, "missfbi3_sniping", "prone_dave", 2.0, 2.0, -1, 1, 0, false, false, false)
        FreezeEntityPosition(ped, true)
        ShowStateNotification()
        while surrenderState == 3 do
            Citizen.Wait(500)
        end
        FreezeEntityPosition(ped, false)
    end)
end

-- 开始跪着抱头
function StartKneelingHandsUp()
    lastSurrenderState = surrenderState
    ClearPedTasks(PlayerPedId())
    surrenderState = 4
    isSurrendering = true
    Citizen.CreateThread(function()
        -- 先跪下
        RequestAnimDict(animations.kneeling.dict)
        while not HasAnimDictLoaded(animations.kneeling.dict) do
            Citizen.Wait(10)
        end
        TaskPlayAnim(PlayerPedId(), animations.kneeling.dict, animations.kneeling.anim, 179.8, 3.5, -1, 1, 0, false, false, false)
        Citizen.Wait(500) -- 等待跪下动作进入状态
        -- 再抱头
        RequestAnimDict("random@arrests@busted")
        while not HasAnimDictLoaded("random@arrests@busted") do
            Citizen.Wait(10)
        end
        TaskPlayAnim(PlayerPedId(), "random@arrests@busted", "idle_a", 8.0, 8.0, -1, 49, 0, false, false, false)
    end)
    ShowStateNotification()
end

-- 恢复正常状态
function ResetToNormal()
    surrenderState = 0
    isSurrendering = false
    ClearPedTasks(PlayerPedId())
    ResetPedMovementClipset(PlayerPedId(), 0.0)
    FreezeEntityPosition(PlayerPedId(), false)
    HideNotification()
end

-- 处理按键输入
function HandleKeyPress()
    if surrenderState == 0 then -- 正常状态
        if IsControlJustPressed(0, 73) then -- X键
            StartHandsUp()
        end
    elseif surrenderState == 1 then -- 举手状态
        if IsControlJustPressed(0, 73) then -- X键
            ResetToNormal()
        elseif IsControlJustPressed(0, 20) then -- Z键
            StartKneeling()
        elseif IsControlJustPressed(0, 47) then -- G键
            StartProne()
        elseif IsControlJustPressed(0, 249) then -- N键
            StartHandsUp()
        end
    elseif surrenderState == 2 then -- 跪下状态
        if IsControlJustPressed(0, 73) then -- X键
            ResetToNormal()
        elseif IsControlJustPressed(0, 20) then -- Z键
            StartKneelingHandsUp()
        elseif IsControlJustPressed(0, 249) then -- N键
            StartHandsUp()
        end
    elseif surrenderState == 3 then -- 趴下状态
        if IsControlJustPressed(0, 73) then -- X键
            ResetToNormal()
        elseif IsControlJustPressed(0, 249) then -- N键
            StartHandsUp()
        end
    elseif surrenderState == 4 then -- 跪着抱头状态
        if IsControlJustPressed(0, 73) then -- X键
            ResetToNormal()
        elseif IsControlJustPressed(0, 249) then -- N键
            StartHandsUp()
        elseif IsControlJustPressed(0, 20) then -- Z键
            StartKneeling()
        end
    end
end

-- 处理指令
RegisterCommand('sp', function()
    if surrenderState == 0 then
        StartHandsUp()
    else
        ResetToNormal()
    end
end, false)

-- 主循环
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        -- 处理按键输入
        HandleKeyPress()
        
        -- 如果处于投降状态，禁用移动
        if isSurrendering and surrenderState > 1 then
            FreezeEntityPosition(PlayerPedId(), true)
        end
        
        -- 显示状态通知
        if isSurrendering then
            ShowStateNotification()
        end
    end
end)

-- 玩家重生时重置状态
AddEventHandler('playerSpawned', function()
    ResetToNormal()
    HideNotification()
end)

-- 玩家死亡时重置状态
AddEventHandler('baseevents:onPlayerDied', function()
    ResetToNormal()
    HideNotification()
end)

print("投降插件已加载 - 按X键或输入/sp开始投降") 