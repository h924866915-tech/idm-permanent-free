# IDM 永久免费（无弹窗 / 无强制更新）

让 Internet Download Manager 永久免费使用、不弹许可证窗口、不弹"文件已损坏"、不强制更新。**不破解/不修改 exe**，保留官方数字签名，因此不会触发 IDM 的自校验。

## 原理

| 问题 | 成因 | 本方案 |
|---|---|---|
| 弹「序列号被禁用」 | 用了注册对话框里的示例假序列号 | 清空序列号，走试用模式 |
| 弹「主程序文件已损坏」 | 修改了 IDMan.exe 导致自校验失败 | 使用官方正版 exe（保留签名） |
| 强制更新 | 更新检查开关 + 联网验证 | 关闭 CheckUpdtVM + hosts/防火墙阻断 |
| 试用到期 | 30 天试用计数 | 重置试用状态 + 每 4 周自动续期 |

## 一键激活

1. 安装 **官方正版** IDM（从官网 https://www.internetdownloadmanager.com 下载安装，版本 6.43 及以上均可）。
2. 把本仓库的 `activate.bat` 和 `reset_trial.bat` 放到 **IDM 安装目录**（与 `IDMan.exe` 同级）。
3. **右键 → 以管理员身份运行** `activate.bat`。

脚本会自动：结束 IDM 进程 → 清空伪造序列号 → 重置试用期 → 禁用更新 → 写入 hosts 与防火墙阻断规则 → 注册每 4 周自动续期的计划任务。

## 手动重置试用期

任何时刻（例如换电脑、重装 IDM 后）都可以双击 `reset_trial.bat` 重置试用期。

`activate.bat` 已通过 Windows 计划任务 `IDM Trial Reset` 每 4 周自动执行 `reset_trial.bat`（在 30 天试用到期前提前续期，永不过期）。

## 文件说明

- `activate.bat` — 一键激活（完整流程，管理员运行一次即可）
- `reset_trial.bat` — 试用期重置（手动 / 计划任务调用）
- `README.md` — 本说明

## 卸载 / 还原

- 卸载 IDM：运行 IDM 安装目录里的 `Uninstall.exe`（绿色版为 `!)卸载.bat`）。
- 删除计划任务：任务计划程序里删除 `IDM Trial Reset`。
- 还原 hosts：删除 `C:\Windows\System32\drivers\etc\hosts` 中 `# ---- IDM license/update block` 之间（含起止行）的内容。
- 删除防火墙规则：`netsh advfirewall firewall delete rule name="IDM_Block_IDMGrHlp"` 与 `IDM_Block_idmBroker`。

## 注意

- 本脚本仅修改注册表、hosts 和防火墙规则，**不改动任何 IDM 程序文件**。
- 仅供个人学习与软件试用技术研究，请支持正版。
