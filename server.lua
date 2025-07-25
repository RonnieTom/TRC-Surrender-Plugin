local function printBanner()
    print("--------------------------------------------------------------------------------")
    print("^2  ______               ___                     _")
    print("^2 /_  __/ ___   __ _   / _ \\ ___   ___   ___   (_) ___")
    print("^2  / /   / _ \\ /  ' \\ / , _// _ \\ / _ \\ / _ \\ / / / -_)")
    print("^2 /_/    \\___//_/_/_//_/|_| \\___//_//_//_//_//_/  \\__/")
    print("^0 --------------------------------------------------------------------------------")
    print("^0                Discord > https://discord.gg/6Fbv9AMXmx")     
    print("^0                KOOK > https://kook.vip/oi82zn")         
    print("^0                  QQ > 3547376520")           
    print("^0                     Script Name 插件名字 > [T-RCreation | Surrender Plugin]")            
    print("^0                       Author  作者 > Tom Ronnie")
    print("^0                        Current version 当前版本 > 1.0.0")
    print("^0                        Tebex 商店 > https://t-r-creation.tebex.io/")
    print("^0 --------------------------------------------------------------------------------")
    print("^1 If you need a CHAT similar to GTAworld or SAMP, you can check out my Tebex. I only sell it for $5.")
    print("^2 如果你需要类似 GTAworld 或 SAMP 的 CHAT，可以看看我的 Tebex。我只卖 5 美元。")
    print("^3 GTAworld나 SAMP와 비슷한 CHAT이 필요하시면 제 Tebex를 확인해 보세요. 5달러에 판매합니다.")
    print("^6 GTAworldやSAMPのようなCHATが必要な場合は、私のTebexをチェックしてみてください。たったの5ドルで販売しています。")
    print("^4 Si necesitas un CHAT similar a GTAworld o SAMP, puedes consultar mi Tebex. Lo vendo por solo $5.")
    print("^5 Se precisar de um CHAT semelhante ao GTAworld ou SAMP, pode conferir meu Tebex. Só o vendo por US$ 5.")                
end

CreateThread(function()
    printBanner()
    -- ...
end)

-- -- 投降插件服务器脚本
-- print("Surrender plugin server has been started 投降插件服务器端已启动")
-- 
-- -- 玩家连接时
-- AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
--     print("Player 玩家 " .. name .. " Connecting 正在连接...")
-- end)
-- 
-- -- 玩家断开连接时
-- AddEventHandler('playerDropped', function(reason)
--     print("Player disconnected, reason: " .. reason)
-- end)
-- 
-- -- 玩家加入时
-- AddEventHandler('playerSpawned', function()
--     local playerId = source
--     print("Player 玩家 " .. GetPlayerName(playerId) .. " Reborn 已重生")
-- end)
-- 
-- -- 玩家死亡时
-- AddEventHandler('baseevents:onPlayerDied', function(killedBy, reason)
--     local playerId = source
--     print("Player 玩家 " .. GetPlayerName(playerId) .. " Deceased 已死亡")
-- end) 
