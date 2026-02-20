# Changelog

このファイルはプロジェクトの変更履歴を記録します。

形式は [Keep a Changelog](https://keepachangelog.com/ja/1.0.0/) に準拠し、
バージョン管理は [Semantic Versioning](https://semver.org/lang/ja/) に従います。

## [Unreleased]

## [0.1.0] - 2026-02-21

### Added

- feat: add common CLI base (flags, exit codes, io, help, version)
  - `src/lib/exit_codes.sh`: 終了コード定数 (`EXIT_OK=0`, `EXIT_ERROR=1`, `EXIT_CANCEL=2`, `EXIT_USAGE=3`) とヘルパー関数 (`die()`, `exit_with()`)
  - `src/lib/io.sh`: 入出力ユーティリティ (`out()` → stdout, `err()` → stderr, `log_debug()` → ISO8601 構造化ログ)
  - `src/lib/flags.sh`: グローバルフラグ解析 (`parse_flags()`: `--help`/`-h`, `--verbose`, `--version`/`-v`, 不明フラグで終了コード 3)
  - `src/lib/version.sh`: バージョン情報出力 (`print_version()`: `corun version X.Y.Z` 形式)
  - `src/lib/help.sh`: ヘルプ出力 (`print_help()`: DESCRIPTION / USAGE / AVAILABLE COMMANDS / EXAMPLES / LEARN MORE の 5 セクション)
  - `src/corun.sh`: ルートコマンドディスパッチャ（フラグ解析 → バージョン/ヘルプ表示 → サブコマンド振り分け、SIGINT で終了コード 2）
  - `bin/corun`: エントリポイントスクリプト
  - `VERSION`: セマンティックバージョン管理ファイル (`0.1.0`)
- feat: add project scaffold (Makefile, CI pipeline)
  - `Makefile`: `lint` / `format` / `format-check` / `test` / `integration_test` / `build` / `clean` / `all` / `ci` / `help` ターゲット
  - `.github/workflows/ci.yml`: GitHub Actions パイプライン（push/PR to `main`, `next`, `feature/**`）
- test: add comprehensive test suite
  - 単体テスト 56 件（exit_codes / io / flags / version / help）
  - 結合テスト 36 件（version / verbose / exit_codes / pipe / help）
  - TDD Red-Green-Refactor サイクルで実装

[Unreleased]: https://github.com/rising3/corun/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/rising3/corun/releases/tag/v0.1.0
