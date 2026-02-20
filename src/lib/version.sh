#!/usr/bin/env bash
# src/lib/version.sh
#
# バージョン情報の読み取りと出力
# VERSION ファイルから SemVer を読み取り、corun version X.Y.Z 形式で stdout に出力する

# SCRIPT_DIR: このファイル自身のディレクトリ（VERSION ファイルの基準パス解決に使用）
_CORUN_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_CORUN_ROOT="$(cd "${_CORUN_LIB_DIR}/../.." && pwd)"
_CORUN_VERSION_FILE="${_CORUN_ROOT}/VERSION"

# print_version() — バージョン情報を stdout に出力する
#
# 出力形式: corun version X.Y.Z
# VERSION ファイルが存在しない場合は "0.0.0" を使用する。
#
# 使用方法:
#   print_version
#
# 例:
#   print_version
#   # → corun version 0.1.0
print_version() {
  local version
  if [[ -f "$_CORUN_VERSION_FILE" ]]; then
    version="$(tr -d '[:space:]' <"$_CORUN_VERSION_FILE")"
  else
    version="0.0.0"
  fi
  printf 'corun version %s\n' "$version"
}
