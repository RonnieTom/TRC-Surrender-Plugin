# TRC-Surrender-Plugin 投降动画插件

## 插件介绍
这是一个为 FiveM 开发的多状态投降动画插件，允许玩家执行多种投降相关的动作，包括举手投降、跪地和俯卧等姿势。

## 主要功能
- 多种投降状态：
  - 正常状态 (状态 0)
  - 举手投降 (状态 1)
  - 跪地 (状态 2)
  - 俯卧 (状态 3)
  - 跪地举手 (状态 4)

- 流畅的动画过渡
- 状态锁定功能
- 死亡/重生时自动重置状态
- 直观的屏幕提示

## 按键说明
- X键：切换投降/正常状态
- Z键：切换跪地状态
- G键：切换俯卧状态

## 特殊功能
- 在跪地/俯卧状态下锁定移动
- 左上角显示当前状态提示
- 状态切换时会自动清理之前的动画
- 死亡后自动重置状态

## 动画细节
- 举手动画：使用 missminuteman_1ig_2/handsup_enter
- 跪地动画：使用 random@arrests/kneeling_arrest_idle
- 俯卧动画：使用 missfbi3_sniping/prone_dave

## 安装说明
1. 将此资源文件夹放入服务器的 resources 目录
2. 在 server.cfg 中添加 `ensure TRC-Surrender-Plugin`
3. 重启服务器或使用 `refresh` 和 `start TRC-Surrender-Plugin` 命令启动插件

## 注意事项
- 确保服务器已正确配置基础依赖
- 建议在使用此插件时关闭其他可能冲突的动画插件 