#!/usr/bin/env bash
# Claude Code Notification hook：在 macOS 通知中心顯示 cc 的提醒
# stdin = hook 事件 JSON（Stop 或 PreToolUse）
#
# 版面：
#   標題    = 📁 目錄名
#   副標題  = 💬 會話命名
#   內容    = ⚡️ 問題內容 / 🎐 等待指示
#
# 環境變數旋鈕：
#   NOTIFY_SOUND — 通知音效名稱（預設：Glass）
set -euo pipefail

INPUT=$(cat)

HOOK_EVENT=$(printf '%s' "$INPUT" | jq -r '.hook_event_name // "Notification"')
CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // ""')
TP=$(printf  '%s' "$INPUT" | jq -r '.transcript_path // ""')
SID=$(printf '%s' "$INPUT" | jq -r '.session_id // ""')

# 依 hook 事件解析訊息
if [ "$HOOK_EVENT" = "PreToolUse" ]; then
  FIRST_Q=$(printf '%s' "$INPUT" | jq -r '.tool_input.questions[0].question // ""')
  COUNT=$(printf '%s' "$INPUT" | jq -r '.tool_input.questions | length' 2>/dev/null || echo 1)
  if [ "${COUNT:-1}" -gt 1 ]; then
    MSG="⚡️ ${FIRST_Q:-需要你回答}（共 ${COUNT} 題）"
  else
    MSG="⚡️ ${FIRST_Q:-需要你回答問題}"
  fi
elif [ "$HOOK_EVENT" = "Stop" ]; then
  MSG="🎐 等待指示"
else
  MSG=$(printf '%s' "$INPUT" | jq -r '.message // "需要你的注意"')
fi

# 缺 transcript_path 時，從 cwd（/ 換 -）推回專案目錄再拼出 jsonl
if [ -z "$TP" ] && [ -n "$CWD" ] && [ -n "$SID" ]; then
  SLUG=$(printf '%s' "$CWD" | sed 's#/#-#g')
  TP="$HOME/.claude/projects/${SLUG}/${SID}.jsonl"
fi

CACHE=""
[ -n "$TP" ] && CACHE="$(dirname "$TP")/.session_cache.json"

# --- 取得會話命名（優先序：自訂名 > 即時 ai-title > cache 摘要 > 目錄名）---
NAME=""

# 1) /rename 的自訂名
if [ -n "$CACHE" ] && [ -f "$CACHE" ]; then
  if [ "$(jq -r --arg p "$TP" '.entries[$p].session.is_renamed // false' "$CACHE" 2>/dev/null)" = "true" ]; then
    NAME=$(jq -r --arg p "$TP" '.entries[$p].session.rename_name // ""' "$CACHE" 2>/dev/null)
  fi
fi

# 2) JSONL 最後一筆 ai-title
if [ -z "$NAME" ] && [ -n "$TP" ] && [ -f "$TP" ]; then
  NAME=$(grep '"type":"ai-title"' "$TP" 2>/dev/null | tail -1 | jq -r '.aiTitle // ""' 2>/dev/null)
fi

# 3) cache 的 summary
if [ -z "$NAME" ] && [ -n "$CACHE" ] && [ -f "$CACHE" ]; then
  NAME=$(jq -r --arg p "$TP" '.entries[$p].session.summary // ""' "$CACHE" 2>/dev/null)
fi

# 4) 退回目錄名
[ -z "$NAME" ] && NAME=$([ -n "$CWD" ] && basename "$CWD" || echo "(未命名會話)")

DIR_NAME=$([ -n "$CWD" ] && basename "$CWD" || echo "Claude Code")
TITLE="📁 $DIR_NAME"
NAME="💬 $NAME"

SOUND="${NOTIFY_SOUND:-Glass}"

osascript \
  -e 'on run argv' \
  -e 'display notification (item 1 of argv) with title (item 2 of argv) subtitle (item 3 of argv) sound name (item 4 of argv)' \
  -e 'end run' \
  "$MSG" "$TITLE" "$NAME" "$SOUND" 2>/dev/null || true
