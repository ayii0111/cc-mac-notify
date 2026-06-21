#!/usr/bin/env bash
set -euo pipefail

TOOL_NAME="cc-mac-notify"
HOOK_SCRIPT="notify.sh"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
INSTALL_DIR="$CLAUDE_DIR/community-tools/$TOOL_NAME"
SETTINGS="$CLAUDE_DIR/settings.json"

# --- 模式偵測：從 repo 內執行 vs curl 管道 ---
SOURCE="${BASH_SOURCE[0]:-}"
REPO_SCRIPT=""
if [ -n "$SOURCE" ] && [ "$SOURCE" != "/dev/stdin" ]; then
  CANDIDATE="$(cd -P "$(dirname "$SOURCE")" 2>/dev/null && pwd)/hooks/$HOOK_SCRIPT"
  [ -f "$CANDIDATE" ] && REPO_SCRIPT="$CANDIDATE"
fi

mkdir -p "$INSTALL_DIR"

if [ -n "$REPO_SCRIPT" ]; then
  HOOK_PATH="$REPO_SCRIPT"
  echo "📦 Clone mode：使用 $HOOK_PATH"
else
  HOOK_PATH="$INSTALL_DIR/hooks/$HOOK_SCRIPT"
  echo "📥 Curl mode：安裝到 $HOOK_PATH"
  mkdir -p "$INSTALL_DIR/hooks"
  curl -fsSL "https://raw.githubusercontent.com/ayii0111/cc-mac-notify/main/hooks/$HOOK_SCRIPT" \
    -o "$HOOK_PATH"
  chmod +x "$HOOK_PATH"
fi

# 記錄 hook 路徑供 uninstall 使用
echo "$HOOK_PATH" > "$INSTALL_DIR/.hook_path"

# --- 合併 settings.json（node：CC 必定有）---
node - "$SETTINGS" "$HOOK_PATH" <<'NODEJS'
const fs = require('fs');
const [,, settingsPath, hookPath] = process.argv;

let settings = {};
try { settings = JSON.parse(fs.readFileSync(settingsPath, 'utf8')); } catch {}

if (!settings.hooks) settings.hooks = {};

const cmd = `bash "${hookPath}"`;
const hasCmd = (entry) => (entry.hooks || []).some(h => h.command === cmd);
let added = 0;

// 1. Stop hook：加到第一個 entry，若無則新建
if (!settings.hooks.Stop) settings.hooks.Stop = [];
if (!settings.hooks.Stop.some(hasCmd)) {
  if (settings.hooks.Stop.length === 0) {
    settings.hooks.Stop.push({ hooks: [] });
  }
  settings.hooks.Stop[0].hooks.push({ type: 'command', command: cmd });
  added++;
}

// 2. PreToolUse AskUserQuestion hook
if (!settings.hooks.PreToolUse) settings.hooks.PreToolUse = [];
let askEntry = settings.hooks.PreToolUse.find(e => e.matcher === 'AskUserQuestion');
if (!askEntry) {
  askEntry = { matcher: 'AskUserQuestion', hooks: [] };
  settings.hooks.PreToolUse.push(askEntry);
}
if (!hasCmd(askEntry)) {
  askEntry.hooks.push({ type: 'command', command: cmd });
  added++;
}

fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2) + '\n');
console.log(added > 0 ? `✓ 已加入 ${added} 個 hook 條目` : '✓ Hook 已存在，略過');
NODEJS

echo ""
echo "✅ $TOOL_NAME 安裝完成！"
echo ""
echo "調整旋鈕（選填，設在 shell profile 或 ~/.claude/settings.json → env）："
echo "  NOTIFY_SOUND   通知音效名稱（預設：Glass）"
echo ""
if [ -n "$REPO_SCRIPT" ]; then
  REPO_ROOT="$(cd -P "$(dirname "$REPO_SCRIPT")/.." 2>/dev/null && pwd)"
  echo "移除：bash \"$REPO_ROOT/uninstall.sh\""
else
  echo "移除：curl -fsSL https://raw.githubusercontent.com/ayii0111/cc-mac-notify/main/uninstall.sh | bash"
fi
