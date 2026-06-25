# cc-mac-notify

Claude Code 完成工作或詢問問題時，發送 macOS 原生通知。

## 通知版面

```
📁 目錄名
💬 會話命名
⚡️ 問題內容  /  🎐 等待指示
```

| 觸發時機 | 通知內容 |
|----------|----------|
| CC 停止（任務完成） | 🎐 等待指示 |
| CC 詢問問題（AskUserQuestion） | ⚡️ 問題內容 |

## Install

一鍵安裝：

```bash
curl -fsSL https://raw.githubusercontent.com/ayii0111/cc-mac-notify/main/install.sh | bash
# 在 CC 執行 /reload-plugins
```

或在 CC 內執行：

```
/plugin marketplace add ayii0111/cc-mac-notify
/plugin install cc-mac-notify@cc-mac-notify
/reload-plugins
```

或 clone 後本機安裝：

```bash
git clone https://github.com/ayii0111/cc-mac-notify
cd cc-mac-notify && ./install.sh
# 在 CC 執行 /reload-plugins
```

## Uninstall

```bash
bash uninstall.sh
```

## Tuning

在 shell profile 或 `~/.claude/settings.json` → `env` 設定：

| 變數 | 預設值 | 說明 |
|------|--------|------|
| `NOTIFY_SOUND` | `Glass` | 通知音效（macOS 系統音效名稱） |
