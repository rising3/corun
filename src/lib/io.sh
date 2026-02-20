#!/usr/bin/env bash
# src/lib/io.sh
#
# 入出力ユーティリティ関数
# stdout/stderr の分離と構造化ログ出力を提供する

# ─── 出力ヘルパー ──────────────────────────────────────────────────────────────

# out() — 標準出力 (stdout) へメッセージを出力する
#
# 使用方法:
#   out <message>
#
# 例:
#   out "処理が完了しました"
out() {
  printf '%s\n' "$*"
}

# err() — 標準エラー出力 (stderr) へメッセージを出力する
#
# 使用方法:
#   err <message>
#
# 例:
#   err "エラー: ファイルが見つかりません"
err() {
  printf '%s\n' "$*" >&2
}

# ─── 構造化ログ ────────────────────────────────────────────────────────────────

# log_debug() — DEBUG レベルの構造化ログを stderr へ出力する
#
# CORUN_VERBOSE=1 のときのみ出力する。
# 出力形式: timestamp=<ISO8601> level=DEBUG msg=<message>
#
# 使用方法:
#   log_debug <message>
#
# 環境変数:
#   CORUN_VERBOSE - 1 のとき出力を有効化（省略時または 0 のとき無効）
#
# 例:
#   CORUN_VERBOSE=1 log_debug "フラグ解析完了"
#   # → timestamp=2026-02-21T12:34:56 level=DEBUG msg=フラグ解析完了
log_debug() {
  [ "${CORUN_VERBOSE:-0}" -eq 1 ] || return 0
  local ts
  ts="$(date -u '+%Y-%m-%dT%H:%M:%S')"
  printf 'timestamp=%s level=DEBUG msg=%s\n' "$ts" "$*" >&2
}
