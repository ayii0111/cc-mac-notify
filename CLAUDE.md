# cc-mac-notify 詞彙表

## Hook 一覽

| 名稱 | 觸發時機 | Hook Event | Matcher |
|------|----------|------------|---------|
| notify（停止） | CC 完成停止 | `Stop` | — |
| notify（詢問） | CC 問問題 | `PreToolUse` | `AskUserQuestion` |

## 通知版面

```
標題：   📁 目錄名
副標題： 💬 會話命名
內容：   ⚡️ 問題內容  /  🎐 等待指示
```

## 內容對應

| 事件 | 通知內容 |
|------|----------|
| Stop | 🎐 等待指示 |
| AskUserQuestion（單題） | ⚡️ 問題內容 |
| AskUserQuestion（多題） | ⚡️ 問題內容（共 N 題） |

## 環境變數旋鈕

| 變數 | 預設值 | 說明 |
|------|--------|------|
| `NOTIFY_SOUND` | `Glass` | 通知音效（macOS 系統音效名稱） |

設定方式：加在 shell profile（`~/.zshrc`）或 `~/.claude/settings.json` 的 `env` 欄位。

## 會話命名優先序

1. `/rename` 自訂名（`is_renamed: true`）
2. JSONL 最後一筆 `ai-title`（即時自動命名）
3. session cache 的 `summary`
4. fallback：目錄名

## 注意事項

- 純 `osascript` 實作，無需額外依賴，macOS 內建即可用
- 依賴 `jq`（CC 環境通常已內建）
- 點擊通知會跳到「工序指令編寫程式」（Script Editor），為 osascript 的 macOS 限制
