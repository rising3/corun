#!/usr/bin/env bats
# tests/unit/version_test.bats
#
# version.sh の単体テスト
# TDD Red フェーズ: src/lib/version.sh が存在しない状態で実行すると全テスト失敗する

REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
LIB="${REPO_ROOT}/src/lib/version.sh"

# ─── print_version() テスト ───────────────────────────────────────────────────

@test "print_version() は 'corun version X.Y.Z' 形式を stdout に出力する" {
  run bash -c "source '${LIB}'; print_version"
  [ "$status" -eq 0 ]
  [[ "$output" =~ ^corun\ version\ [0-9]+\.[0-9]+\.[0-9]+ ]]
}

@test "print_version() の出力は SemVer パターンに一致する (^[0-9]+\\.[0-9]+\\.[0-9]+)" {
  run bash -c "source '${LIB}'; print_version"
  # バージョン番号部分を抽出して SemVer パターンを検証
  local version_part
  version_part=$(echo "$output" | sed 's/corun version //')
  [[ "$version_part" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

@test "print_version() は stderr に何も出力しない" {
  local stderr_file
  stderr_file=$(mktemp)
  bash -c "source '${LIB}'; print_version" 2>"$stderr_file"
  [ ! -s "$stderr_file" ]
  rm -f "$stderr_file"
}

@test "print_version() は終了コード 0 で終了する" {
  run bash -c "source '${LIB}'; print_version"
  [ "$status" -eq 0 ]
}

@test "print_version() の出力は 'corun version ' で始まる" {
  run bash -c "source '${LIB}'; print_version"
  [[ "$output" == "corun version "* ]]
}

@test "print_version() は VERSION ファイルが存在しないとき '0.0.0' を出力する" {
  run bash -c "
    source '${LIB}'
    # source 後に VERSION ファイルパスを存在しないパスに差し替える
    _CORUN_VERSION_FILE='/nonexistent/path/VERSION'
    print_version
  "
  [ "$status" -eq 0 ]
  [ "$output" = "corun version 0.0.0" ]
}
