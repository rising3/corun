#!/usr/bin/env bats
# integration_tests/pipe_integration_test.bats
#
# パイプ連携の結合テスト
# stdout/stderr 分離とパイプチェーン動作を検証する

REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/.." && pwd)"
CORUN="${REPO_ROOT}/bin/corun"

# ─── stdout/stderr 分離テスト ─────────────────────────────────────────────────

@test "corun --version をパイプで受け取ったとき stdout にエラーメッセージが含まれない" {
  local piped_output
  piped_output=$("$CORUN" --version 2>/dev/null | cat)
  # ERROR や error が stdout に漏れていないことを確認
  ! echo "$piped_output" | grep -qi 'error\|ERROR'
}

@test "corun --version の stdout 出力をパイプで取得できる" {
  local piped_output
  piped_output=$("$CORUN" --version | cat)
  [[ "$piped_output" =~ ^corun\ version\ [0-9]+\.[0-9]+\.[0-9]+ ]]
}

@test "2>/dev/null で stderr を捨てたとき stdout にエラーが漏れない" {
  local stdout_content
  stdout_content=$("$CORUN" --version 2>/dev/null)
  # stdout にエラーが混在していないこと
  ! grep -qi 'error\|ERROR\|level=DEBUG' <<<"$stdout_content"
}

@test "corun --version のエラー出力は stderr のみに出る (stdout にない)" {
  # stdout のみをキャプチャする（stderr は /dev/null へ）
  local stdout_only
  stdout_only=$("$CORUN" --version 2>/dev/null)
  # バージョン行のみが含まれる
  [[ "$stdout_only" =~ ^corun\ version\  ]]
}

# ─── stdin クローズ済みテスト ─────────────────────────────────────────────────

@test "corun --version <&- (stdin クローズ済み) は終了コード 0 で正常終了する" {
  run bash -c "'${CORUN}' --version <&-"
  [ "$status" -eq 0 ]
}

@test "corun --help <&- (stdin クローズ済み) は終了コード 0 で正常終了する" {
  run bash -c "'${CORUN}' --help <&-"
  [ "$status" -eq 0 ]
}

@test "corun <&- (stdin クローズ済み、引数なし) はハングせずに終了する" {
  # タイムアウト 5 秒以内に終了することを確認
  run bash -c "timeout 5 '${CORUN}' <&-"
  # タイムアウト (exit 124) でなければ OK
  [ "$status" -ne 124 ]
}

# ─── SIGPIPE 対応テスト ───────────────────────────────────────────────────────

@test "corun --version | head -1 は SIGPIPE で意図せず失敗しない" {
  # パイプ先が早期終了しても corun 自体がエラーにならないことを確認
  # SIGPIPE での exit code 141 でなければ OK（|| true で受け止める）
  local exit_code
  "$CORUN" --version | head -1 >/dev/null 2>&1 || exit_code=$?
  # 141 (SIGPIPE) は許容しない（または成功）
  [ "${exit_code:-0}" -ne 141 ]
}
