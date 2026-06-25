#!/usr/bin/env bash
set -e
NAME="cc-mac-notify"
claude plugin uninstall "${NAME}@${NAME}"
claude plugin marketplace remove "$NAME"
echo "✓ 已移除 ${NAME}。重啟 CC 套用。"
