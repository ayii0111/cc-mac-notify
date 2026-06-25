#!/usr/bin/env bash
set -e
NAME="cc-mac-notify"
claude plugin marketplace add "ayii0111/$NAME"
claude plugin install "${NAME}@${NAME}"
echo "✓ 安裝完成。在 CC 執行 /reload-plugins 或重啟 CC 套用。"
