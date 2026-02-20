#!/usr/bin/env bash
# src/lib/help.sh
#
# ヘルプ出力テンプレート
# 5 セクション（DESCRIPTION / USAGE / AVAILABLE COMMANDS / EXAMPLES / LEARN MORE）
# を stdout に出力する

# print_help() — コマンドのヘルプを stdout に出力する
#
# 出力セクション:
#   DESCRIPTION       - corun の概要
#   USAGE             - コマンドの使い方
#   AVAILABLE COMMANDS - 利用可能なサブコマンド一覧
#   EXAMPLES          - 使用例
#   LEARN MORE        - 追加情報の参照先
#
# 引数:
#   subcommand (省略可) - サブコマンド名。指定された場合はサブコマンドのヘルプを出力する
#
# 使用方法:
#   print_help
#   print_help run
print_help() {
  local subcommand="${1:-}"

  if [[ -n "$subcommand" ]]; then
    _print_subcommand_help "$subcommand"
    return 0
  fi

  _print_root_help
}

# _print_root_help() — ルートコマンドのヘルプを出力する（内部関数）
_print_root_help() {
  printf '%s\n' \
    "DESCRIPTION" \
    "  corun — GitHub Copilot CLI を non-interactive モードで連続実行するための CLI ツール。" \
    "  プロンプトファイル（YAML/JSON）を読み込み、複数のプロンプトを順番に実行します。" \
    "" \
    "USAGE" \
    "  corun [--help|-h] [--verbose] [--version|-v] <subcommand> [<args>]" \
    "" \
    "AVAILABLE COMMANDS" \
    "  run       プロンプトファイルを読み込み、Copilot CLI を連続実行する" \
    "" \
    "EXAMPLES" \
    "  corun run prompts.yaml           # プロンプトファイルを実行する" \
    "  corun run prompts.yaml --verbose # 詳細ログを有効にして実行する" \
    "  corun --version                  # バージョン情報を表示する" \
    "" \
    "LEARN MORE" \
    "  ドキュメント: https://github.com/rising3/corun#readme" \
    "  Issues:      https://github.com/rising3/corun/issues"
}

# _print_subcommand_help() — サブコマンドのヘルプを出力する（内部関数）
_print_subcommand_help() {
  local subcommand="$1"
  case "$subcommand" in
    run)
      printf '%s\n' \
        "DESCRIPTION" \
        "  corun run — プロンプトファイルを読み込み、Copilot CLI を連続実行する" \
        "" \
        "USAGE" \
        "  corun run <prompt-file> [--verbose]" \
        "" \
        "AVAILABLE COMMANDS" \
        "  (このサブコマンドにはサブコマンドがありません)" \
        "" \
        "EXAMPLES" \
        "  corun run prompts.yaml" \
        "  corun run prompts.json --verbose" \
        "" \
        "LEARN MORE" \
        "  詳細: corun --help"
      ;;
    *)
      printf '%s\n' \
        "DESCRIPTION" \
        "  '%s': 不明なサブコマンドです" "$subcommand" \
        "" \
        "USAGE" \
        "  corun --help で使用可能なコマンド一覧を確認してください" \
        "" \
        "AVAILABLE COMMANDS" \
        "  corun --help を実行してください" \
        "" \
        "EXAMPLES" \
        "  corun --help" \
        "" \
        "LEARN MORE" \
        "  https://github.com/rising3/corun#readme"
      ;;
  esac
}
