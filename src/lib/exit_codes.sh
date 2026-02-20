#!/usr/bin/env bash
# src/lib/exit_codes.sh
#
# 終了コード定数とヘルパー関数
# すべてのモジュールはこのファイルを source して終了コードを参照する

# ─── 終了コード定数 ────────────────────────────────────────────────────────────
# declare -rx: 他スクリプトへのエクスポートを前提とした読み取り専用グローバル定数

declare -rx EXIT_OK=0     # 正常終了
declare -rx EXIT_ERROR=1  # 一般エラー
declare -rx EXIT_CANCEL=2 # ユーザーキャンセル（SIGINT）
declare -rx EXIT_USAGE=3  # 使用方法エラー（不正フラグ等）

# ─── ヘルパー関数 ──────────────────────────────────────────────────────────────

# die() — エラーメッセージを stderr に出力して終了する
#
# 使用方法:
#   die <message> [exit_code]
#
# 引数:
#   message   - stderr に出力するエラーメッセージ（必須）
#   exit_code - 終了コード（省略時は EXIT_ERROR=1）
#
# 例:
#   die "設定ファイルが見つかりません"
#   die "使用方法が正しくありません" "$EXIT_USAGE"
die() {
  local message="${1:-"Unknown error"}"
  local code="${2:-$EXIT_ERROR}"
  echo "ERROR: ${message}" >&2
  exit "$code"
}

# exit_with() — 指定した終了コードでスクリプトを終了する
#
# 使用方法:
#   exit_with <exit_code>
#
# 引数:
#   exit_code - 終了コード（必須）
#
# 例:
#   exit_with "$EXIT_OK"
#   exit_with 3
exit_with() {
  local code="${1:?exit_with: exit_code is required}"
  exit "$code"
}
