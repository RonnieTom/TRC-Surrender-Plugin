-- 投降插件客户端脚本 | Surrender plugin client script
local surrenderState = 0 -- 0: 正常, 1: 举手, 2: 跪下, 3: 趴下, 4: 跪着抱头 | 0: Normal, 1: Hands up, 2: Kneeling, 3: Prone, 4: Kneeling with hands up
local isSurrendering = false -- 是否正在投降 | Whether currently surrendering
local lastSurrenderState = 0 -- 上一个投降状态 | Last surrender state
local lastPosition = vector3(0, 0, 0) -- 上一个位置 | Last position
local collisionCheckEnabled = true -- 碰撞检查是否启用 | Whether collision check is enabled
local interruptionNotificationTimer = 0 -- 中断通知计时器 | Interruption notification timer
local isShowingInterruptionNotification = false -- 是否显示中断通知 | Whether showing interruption notification
local weaponInterruptionNotificationTimer = 0 -- 武器中断通知计时器 | Weapon interruption notification timer
local isShowingWeaponInterruptionNotification = false -- 是否显示武器中断通知 | Whether showing weapon interruption notification

-- 动画字典和名称 | Animation dictionaries and names
local animations = {
    handsUp = {dict = "missminuteman_1ig_2", anim = "handsup_enter"}, -- 举手 | Hands up
    kneeling = {dict = "random@arrests", anim = "kneeling_arrest_idle"}, -- 跪下 | Kneeling
    prone = {dict = "move_crawlprone_pistol", anim = "front"}, -- 趴下 | Prone
    kneelingHandsUp = {dict = "mp_arresting", anim = "idle"} -- 跪着抱头 | Kneeling with hands up
}

-- 引入配置和多语言 | Import config and multi-language
local locale = Config and Config.Locale -- 语言设置 | Language setting

-- 加载动画字典 | Load animation dictionary
function LoadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(0)
    end
end

-- 播放动画 | Play animation
function PlayAnimation(dict, anim, flag)
    LoadAnimDict(dict)
    TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, -8.0, -1, flag, 0, false, false, false)
end

-- 停止动画 | Stop animation
function StopAnimation()
    ClearPedTasks(PlayerPedId())
end

-- 显示帮助提示（GTA5原版左上角Help Text） | Show help notification (GTA5 original top-left Help Text)
function ShowNotification(text)
    SendNUIMessage({action = "show", text = text, position = Config.NotificationPosition or "top-left"})
end

-- 隐藏提示 | Hide notification
function HideNotification()
    SendNUIMessage({action = "hide"})
end

-- 显示动作被中断通知（带6秒时间限制） | Show interruption notification (with 6-second limit)
function ShowInterruptionNotification()
    if not isShowingInterruptionNotification then
        isShowingInterruptionNotification = true
        interruptionNotificationTimer = 6000 -- 6秒 = 6000毫秒 | 6 seconds = 6000 milliseconds
        ShowNotification(Lang[locale].interrupted)
    end
end

-- 显示使用武器中断通知（带6秒时间限制） | Show weapon usage interruption notification (with 6-second limit)
function ShowWeaponInterruptionNotification()
    if not isShowingWeaponInterruptionNotification then
        isShowingWeaponInterruptionNotification = true
        weaponInterruptionNotificationTimer = 6000 -- 6秒 = 6000毫秒 | 6 seconds = 6000 milliseconds
        ShowNotification(Lang[locale].weapon_interrupted)
    end
end

-- 显示状态通知 | Show state notification
function ShowStateNotification()
    if surrenderState == 1 then -- 举手状态 | Hands up state
        ShowNotification(Lang[locale].handsup)
    elseif surrenderState == 2 then -- 跪下状态 | Kneeling state
        ShowNotification(Lang[locale].kneel)
    elseif surrenderState == 3 then -- 趴下状态 | Prone state
        ShowNotification(Lang[locale].prone)
    elseif surrenderState == 4 then -- 跪着抱头状态 | Kneeling with hands up state
        ShowNotification(Lang[locale].kneel_handsup)
    end
end

-- 检查是否被撞击或干扰 | Check for collisions or interruptions
function CheckForInterruption()
    local ped = PlayerPedId() -- 玩家Ped | Player ped
    local currentPosition = GetEntityCoords(ped) -- 当前位置 | Current position
    local currentHealth = GetEntityHealth(ped) -- 当前生命值 | Current health
    
    -- 检查位置变化（被推动） | Check position change (pushed)
    if #(currentPosition - lastPosition) > 0.5 then
        return true
    end
    
    -- 检查是否在车辆中 | Check if in vehicle
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle ~= 0 then
        return true
    end
    
    -- 检查是否被其他玩家推搡 | Check if pushed by other players
    local playerCoords = GetEntityCoords(ped) -- 玩家坐标 | Player coordinates
    local players = GetActivePlayers() -- 活跃玩家 | Active players
    for _, player in ipairs(players) do
        if player ~= PlayerId() then -- 排除自己 | Exclude self
            local otherPed = GetPlayerPed(player) -- 其他玩家的Ped | Other player's ped
            local otherCoords = GetEntityCoords(otherPed) -- 其他玩家坐标 | Other player's coordinates
            local distance = #(playerCoords - otherCoords) -- 距离 | Distance
            
            if distance < 1.5 then -- 距离过近 | Too close
                local otherVelocity = GetEntityVelocity(otherPed) -- 其他玩家速度 | Other player's velocity
                if #otherVelocity > 0.5 then -- 速度过快（可能在推搡） | Too fast (possible pushing)
                    return true
                end
            end
        end
    end
    
    -- 检查是否被攻击 | Check if being attacked
    if IsPedBeingStunned(ped, 0) or IsPedRagdoll(ped) then -- 被击晕或 ragdoll 状态 | Stunned or ragdoll state
        return true
    end
    
    lastPosition = currentPosition -- 更新上一位置 | Update last position
    return false
end

-- 开始举手 | Start hands up
function StartHandsUp()
    lastSurrenderState = surrenderState -- 记录上一状态 | Record last state
    ClearPedTasks(PlayerPedId()) -- 清除当前动作 | Clear current tasks
    surrenderState = 1 -- 设置为举手状态 | Set to hands up state
    isSurrendering = true -- 标记为正在投降 | Mark as surrendering
    lastPosition = GetEntityCoords(PlayerPedId()) -- 记录当前位置 | Record current position
    FreezeEntityPosition(PlayerPedId(), false) -- 解除位置冻结 | Unfreeze position
    Citizen.CreateThread(function() -- 创建线程加载动画 | Create thread to load animation
        RequestAnimDict(animations.handsUp.dict)
        while not HasAnimDictLoaded(animations.handsUp.dict) do
            Citizen.Wait(100)
        end
        TaskPlayAnim(PlayerPedId(), animations.handsUp.dict, animations.handsUp.anim, 2.4, 2.4, -1, 50, 0, false, false, false)
    end)
    ShowStateNotification() -- 显示状态通知 | Show state notification
end

-- 开始跪下 | Start kneeling
function StartKneeling()
    lastSurrenderState = surrenderState -- 记录上一状态 | Record last state
    ClearPedTasks(PlayerPedId()) -- 清除当前动作 | Clear current tasks
    surrenderState = 2 -- 设置为跪下状态 | Set to kneeling state
    isSurrendering = true -- 标记为正在投降 | Mark as surrendering
    lastPosition = GetEntityCoords(PlayerPedId()) -- 记录当前位置 | Record current position
    FreezeEntityPosition(PlayerPedId(), false) -- 解除位置冻结 | Unfreeze position
    Citizen.CreateThread(function() -- 创建线程加载动画 | Create thread to load animation
        RequestAnimDict(animations.kneeling.dict)
        while not HasAnimDictLoaded(animations.kneeling.dict) do
            Citizen.Wait(100)
        end
        TaskPlayAnim(PlayerPedId(), animations.kneeling.dict, animations.kneeling.anim, 1.8, 3.5, -1, 1, 0, false, false, false)
    end)
    ShowStateNotification() -- 显示状态通知 | Show state notification
end

-- 开始趴下 | Start prone
function StartProne()
    lastSurrenderState = surrenderState -- 记录上一状态 | Record last state
    ClearPedTasks(PlayerPedId()) -- 清除当前动作 | Clear current tasks
    surrenderState = 3 -- 设置为趴下状态 | Set to prone state
    isSurrendering = true -- 标记为正在投降 | Mark as surrendering
    lastPosition = GetEntityCoords(PlayerPedId()) -- 记录当前位置 | Record current position
    FreezeEntityPosition(PlayerPedId(), false) -- 解除位置冻结 | Unfreeze position
    Citizen.CreateThread(function() -- 创建线程加载动画 | Create thread to load animation
        local ped = PlayerPedId() -- 玩家Ped | Player ped
        RequestAnimDict("missfbi3_sniping")
        while not HasAnimDictLoaded("missfbi3_sniping") do
            Citizen.Wait(10)
        end
        TaskPlayAnim(ped, "missfbi3_sniping", "prone_dave", 2.0, 2.0, -1, 1, 0, false, false, false)
        ShowStateNotification() -- 显示状态通知 | Show state notification
    end)
end

-- 开始跪着抱头 | Start kneeling with hands up
function StartKneelingHandsUp()
    lastSurrenderState = surrenderState -- 记录上一状态 | Record last state
    ClearPedTasks(PlayerPedId()) -- 清除当前动作 | Clear current tasks
    surrenderState = 4 -- 设置为跪着抱头状态 | Set to kneeling with hands up state
    isSurrendering = true -- 标记为正在投降 | Mark as surrendering
    lastPosition = GetEntityCoords(PlayerPedId()) -- 记录当前位置 | Record current position
    FreezeEntityPosition(PlayerPedId(), false) -- 解除位置冻结 | Unfreeze position
    Citizen.CreateThread(function() -- 创建线程加载动画 | Create thread to load animation
        -- 先跪下 | First kneel
        RequestAnimDict(animations.kneeling.dict)
        while not HasAnimDictLoaded(animations.kneeling.dict) do
            Citizen.Wait(10)
        end
        TaskPlayAnim(PlayerPedId(), animations.kneeling.dict, animations.kneeling.anim, 179.8, 3.5, -1, 1, 0, false, false, false)
        Citizen.Wait(500) -- 等待跪下动作进入状态 | Wait for kneeling animation to start
        -- 再抱头 | Then put hands up
        RequestAnimDict("random@arrests@busted")
        while not HasAnimDictLoaded("random@arrests@busted") do
            Citizen.Wait(10)
        end
        TaskPlayAnim(PlayerPedId(), "random@arrests@busted", "idle_a", 2.8, 8.0, -1, 49, 0, false, false, false)
    end)
    ShowStateNotification() -- 显示状态通知 | Show state notification
end

-- 恢复正常状态 | Reset to normal state
function ResetToNormal()
    surrenderState = 0 -- 重置为正常状态 | Reset to normal state
    isSurrendering = false -- 标记为未在投降 | Mark as not surrendering
    ClearPedTasks(PlayerPedId()) -- 清除所有动作 | Clear all tasks
    ResetPedMovementClipset(PlayerPedId(), 0.0) -- 重置移动动画 | Reset movement clipset
    FreezeEntityPosition(PlayerPedId(), false) -- 确保位置未冻结 | Ensure position is unfrozen
    HideNotification() -- 隐藏通知 | Hide notification
    -- 清除中断通知状态 | Clear interruption notification states
    isShowingInterruptionNotification = false
    interruptionNotificationTimer = 0
    isShowingWeaponInterruptionNotification = false
    weaponInterruptionNotificationTimer = 0
end

-- 处理按键输入 | Handle key input
function HandleKeyPress()
    if surrenderState == 0 then -- 正常状态 | Normal state
        if IsControlJustPressed(0, Config.XKey) then -- X键 | X key
            StartHandsUp()
        end
    elseif surrenderState == 1 then -- 举手状态 | Hands up state
        if IsControlJustPressed(0, Config.XKey) then -- X键 | X key
            ResetToNormal()
        elseif IsControlJustPressed(0, Config.ZKey) then -- Z键 | Z key
            StartKneeling()
        elseif IsControlJustPressed(0, Config.GKey) then -- G键 | G key
            StartProne()
        elseif IsControlJustPressed(0, Config.NKey) then -- N键 | N key
            StartHandsUp()
        end
    elseif surrenderState == 2 then -- 跪下状态 | Kneeling state
        if IsControlJustPressed(0, Config.XKey) then -- X键 | X key
            ResetToNormal()
        elseif IsControlJustPressed(0, Config.ZKey) then -- Z键 | Z key
            StartKneelingHandsUp()
        elseif IsControlJustPressed(0, Config.NKey) then -- N键 | N key
            StartHandsUp()
        end
    elseif surrenderState == 3 then -- 趴下状态 | Prone state
        if IsControlJustPressed(0, Config.XKey) then -- X键 | X key
            ResetToNormal()
        elseif IsControlJustPressed(0, Config.NKey) then -- N键 | N key
            StartHandsUp()
        end
    elseif surrenderState == 4 then -- 跪着抱头状态 | Kneeling with hands up state
        if IsControlJustPressed(0, Config.XKey) then -- X键 | X key
            ResetToNormal()
        elseif IsControlJustPressed(0, Config.NKey) then -- N键 | N key
            StartHandsUp()
        elseif IsControlJustPressed(0, Config.ZKey) then -- Z键 | Z key
            StartKneeling()
        end
    end
end

-- 处理指令 | Handle command
RegisterCommand('sp', function()
    if surrenderState == 0 then -- 正常状态则开始举手 | Start hands up if in normal state
        StartHandsUp()
    else -- 否则重置为正常状态 | Otherwise reset to normal
        ResetToNormal()
    end
end, false)

-- 主循环 | Main loop
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        -- 处理按键输入 | Handle key input
        HandleKeyPress()
        
        -- 检查是否被干扰（仅在投降状态时） | Check for interruption (only in surrender state)
        if isSurrendering and surrenderState > 0 and collisionCheckEnabled then
            if CheckForInterruption() then
                ResetToNormal()
                ShowInterruptionNotification()
            end
        end

        -- 检查是否使用武器中断（仅在投降状态时） | Check for weapon usage interruption (only in surrender state)
        if isSurrendering and surrenderState > 0 then
            local ped = PlayerPedId() -- 玩家Ped | Player ped
            -- 检查是否按下射击键或正在近战攻击 | Check if shooting or in melee combat
            if IsPedShooting(ped) or IsControlPressed(0, 24) or IsPedInMeleeCombat(ped) then
                ResetToNormal()
                ShowWeaponInterruptionNotification()
            end
        end
        
        -- 处理中断通知计时器 | Handle interruption notification timer
        if isShowingInterruptionNotification then
            interruptionNotificationTimer = interruptionNotificationTimer - 16 -- 每帧约16ms | Approximately 16ms per frame
            if interruptionNotificationTimer <= 0 then
                isShowingInterruptionNotification = false
                HideNotification()
            end
        end
        -- 处理武器中断通知计时器 | Handle weapon interruption notification timer
        if isShowingWeaponInterruptionNotification then
            weaponInterruptionNotificationTimer = weaponInterruptionNotificationTimer - 16 -- 每帧约16ms | Approximately 16ms per frame
            if weaponInterruptionNotificationTimer <= 0 then
                isShowingWeaponInterruptionNotification = false
                HideNotification()
            end
        end
        
        -- 显示状态通知 | Show state notification
        if isSurrendering then
            ShowStateNotification()
        end
    end
end)

-- 玩家重生时重置状态 | Reset state when player spawns
AddEventHandler('playerSpawned', function()
    ResetToNormal()
    HideNotification()
end)

-- 玩家死亡时重置状态 | Reset state when player dies
AddEventHandler('baseevents:onPlayerDied', function()
    ResetToNormal()
    HideNotification()
end)

print("投降插件已加载 - 按X键或输入/sp开始投降") -- Surrender plugin loaded - press X or type /sp to start surrendering
