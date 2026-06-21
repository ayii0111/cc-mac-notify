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

```bash
curl -fsSL https://raw.githubusercontent.com/ayii0111/cc-mac-notify/main/install.sh | bash
```

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/ayii0111/cc-mac-notify/main/uninstall.sh | bash
```

## Tuning

在 shell profile 或 `~/.claude/settings.json` → `env` 設定：

| 變數 | 預設值 | 說明 |
|------|--------|------|
| `NOTIFY_SOUND` | `Glass` | 通知音效（macOS 系統音效名稱） |
