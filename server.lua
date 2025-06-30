-- 投降插件服务器脚本
print("投降插件服务器端已启动")

-- 玩家连接时
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    print("玩家 " .. name .. " 正在连接...")
end)

-- 玩家断开连接时
AddEventHandler('playerDropped', function(reason)
    print("玩家断开连接，原因: " .. reason)
end)

-- 玩家加入时
AddEventHandler('playerSpawned', function()
    local playerId = source
    print("玩家 " .. GetPlayerName(playerId) .. " 已重生")
end)

-- 玩家死亡时
AddEventHandler('baseevents:onPlayerDied', function(killedBy, reason)
    local playerId = source
    print("玩家 " .. GetPlayerName(playerId) .. " 已死亡")
end) 