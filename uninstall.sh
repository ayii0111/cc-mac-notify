#!/usr/bin/env bash
set -euo pipefail

TOOL_NAME="cc-mac-notify"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
INSTALL_DIR="$CLAUDE_DIR/community-tools/$TOOL_NAME"
SETTINGS="$CLAUDE_DIR/settings.json"

# --- 從 settings.json 移除 hook 條目 ---
node - "$SETTINGS" "$INSTALL_DIR" <<'NODEJS'
const fs = require('fs');
const path = require('path');
const [,, settingsPath, installDir] = process.argv;

let settings = {};
try { settings = JSON.parse(fs.readFileSync(settingsPath, 'utf8')); } catch { process.exit(0); }

// 讀取安裝時記錄的 hook 路徑（支援 clone/curl 兩種模式）
let hookPaths = [installDir];
try {
  const saved = fs.readFileSync(path.join(installDir, '.hook_path'), 'utf8').trim();
  if (saved) hookPaths.push(saved);
} catch {}

const isOurs = (h) => hookPaths.some(p => h.command && h.command.includes(p));
let removed = 0;

// 從 Stop 移除
if (settings.hooks && settings.hooks.Stop) {
  settings.hooks.Stop.forEach(entry => {
    if (!entry.hooks) return;
    const before = entry.hooks.length;
    entry.hooks = entry.hooks.filter(h => !isOurs(h));
    removed += before - entry.hooks.length;
  });
  // 移除空的 Stop entry
  settings.hooks.Stop = settings.hooks.Stop.filter(e => (e.hooks || []).length > 0);
  if (settings.hooks.Stop.length === 0) delete settings.hooks.Stop;
}

// 從 PreToolUse AskUserQuestion 移除
if (settings.hooks && settings.hooks.PreToolUse) {
  settings.hooks.PreToolUse.forEach(entry => {
    if (entry.matcher !== 'AskUserQuestion' || !entry.hooks) return;
    const before = entry.hooks.length;
    entry.hooks = entry.hooks.filter(h => !isOurs(h));
    removed += before - entry.hooks.length;
  });
  // 移除空的 AskUserQuestion entry
  settings.hooks.PreToolUse = settings.hooks.PreToolUse.filter(
    e => e.matcher !== 'AskUserQuestion' || (e.hooks || []).length > 0
  );
  if (settings.hooks.PreToolUse.length === 0) delete settings.hooks.PreToolUse;
}

fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2) + '\n');
console.log(removed > 0 ? `✓ 已從 settings.json 移除 ${removed} 個 hook 條目` : '✓ settings.json 中無對應條目');
NODEJS

# --- 刪除安裝目錄 ---
if [ -d "$INSTALL_DIR" ]; then
  rm -rf "$INSTALL_DIR"
  echo "✓ 已刪除 $INSTALL_DIR"
fi

echo "✅ $TOOL_NAME 已移除"
