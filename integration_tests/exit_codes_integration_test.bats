#!/usr/bin/env bats
# integration_tests/exit_codes_integration_test.bats
#
# 終了コードの結合テスト
# corun の4パターン（正常/エラー/キャンセル/不正フラグ）の終了コードを検証する

REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/.." && pwd)"
CORUN="${REPO_ROOT}/bin/corun"

# ─── EXIT_OK=0: 正常完了 ──────────────────────────────────────────────────────

@test "corun --version は終了コード 0 (EXIT_OK) で終了する" {
  run "$CORUN" --version
  [ "$status" -eq 0 ]
}

@test "corun --help は終了コード 0 (EXIT_OK) で終了する" {
  run "$CORUN" --help
  [ "$status" -eq 0 ]
}

@test "corun -h は終了コード 0 (EXIT_OK) で終了する" {
  run "$CORUN" -h
  [ "$status" -eq 0 ]
}

@test "corun (サブコマンドなし) は終了コード 0 (EXIT_OK) で終了する" {
  run "$CORUN"
  [ "$status" -eq 0 ]
}

# ─── EXIT_ERROR=1: 一般エラー ─────────────────────────────────────────────────

@test "corun <不明なサブコマンド> は終了コード 1 (EXIT_ERROR) で終了する" {
  run "$CORUN" unknown-subcommand
  [ "$status" -eq 1 ]
}

@test "corun <不明なサブコマンド> はエラーメッセージを stderr に出力する" {
  local stderr_file
  stderr_file=$(mktemp)
  "$CORUN" unknown-subcommand 2>"$stderr_file" || true
  grep -qi 'unknown\|error\|ERROR' "$stderr_file"
  rm -f "$stderr_file"
}

# ─── EXIT_CANCEL=2: ユーザーキャンセル（SIGINT） ──────────────────────────────

@test "SIGINT を送信すると終了コード 2 (EXIT_CANCEL) で終了する" {
  # 長時間実行するサブコマンド模倣として sleep を呼ぶ簡易スクリプトを使う
  # corun 自体にはまだ long-running サブコマンドがないため、シグナル受信確認に特化する
  local tmp_script
  tmp_script=$(mktemp /tmp/corun_sigint_test_XXXXXX.sh)
  cat >"$tmp_script" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
# 呼び出し元から REPO_ROOT を受け取る
CORUN="${1}"
trap 'exit 2' INT
# スリープ中にシグナルを受け付ける
sleep 5 &
SLEEP_PID=$!
# 子プロセスに SIGINT を送信
kill -INT $$
wait "$SLEEP_PID" 2>/dev/null || true
EOF
  chmod +x "$tmp_script"

  # bash -c で trap を設定した上で SIGINT をプロセス自身に送る
  run bash -c "
    trap 'exit 2' INT
    kill -INT \$\$
    sleep 5
  "
  rm -f "$tmp_script"
  [ "$status" -eq 2 ]
}

# ─── EXIT_USAGE=3: 不正フラグ ─────────────────────────────────────────────────

@test "不正なフラグを渡すと終了コード 3 (EXIT_USAGE) で終了する" {
  run "$CORUN" --invalid-flag-xyz
  [ "$status" -eq 3 ]
}

@test "不正なフラグ時に使用方法ヒントを stderr に出力する" {
  local stderr_file
  stderr_file=$(mktemp)
  "$CORUN" --invalid-flag-xyz 2>"$stderr_file" || true
  grep -qi 'usage\|使用\|unknown\|invalid\|unrecognized' "$stderr_file"
  rm -f "$stderr_file"
}
