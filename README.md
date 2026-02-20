# corun

GitHub Copilot CLI を non-interactive モードで複数のプロンプトを連続実行するための CLI ツールです。

## インストール手順

### 前提条件

| ツール | バージョン |
|---|---|
| bash | 5.2+ |
| GitHub Copilot CLI | 0.0.400+ |
| yq | 4.30.8+ |
| jq | 1.6+ |
| make | 4.3+ |

### インストール

```bash
git clone https://github.com/rising3/corun.git
cd corun
make build
```

`bin/corun` に実行権限が付与され、利用可能になります。

`PATH` に `bin/` を追加するか、シンボリックリンクを作成してください：

```bash
export PATH="$PWD/bin:$PATH"
```

## 使用方法

```
corun [--help|-h] [--verbose] [--version|-v] <subcommand> [<args>]
```

### 基本的な使用例

```bash
# バージョン確認
corun --version

# ヘルプ表示
corun --help

# 詳細ログを有効化
corun --verbose run prompts.yaml

# プロンプトファイルを実行（今後実装予定）
corun run prompts.yaml
```

## グローバルフラグ一覧

| フラグ | 省略形 | 説明 |
|---|---|---|
| `--help` | `-h` | ヘルプを表示して終了（終了コード 0） |
| `--verbose` | なし | 詳細ログ（`timestamp= level=DEBUG msg=`）を stderr に出力 |
| `--version` | `-v` | バージョン情報（`corun version X.Y.Z`）を表示して終了（終了コード 0） |

> `--help` と `--version` を同時指定した場合は `--help` が優先されます。

## 終了コード表

| コード | 定数名 | 説明 |
|---|---|---|
| `0` | `EXIT_OK` | 正常終了 |
| `1` | `EXIT_ERROR` | 一般エラー（サブコマンドが不明など） |
| `2` | `EXIT_CANCEL` | ユーザーキャンセル（SIGINT / Ctrl-C） |
| `3` | `EXIT_USAGE` | 使用方法エラー（不明なフラグを指定した場合） |

```bash
corun --version          # → 終了コード 0
corun unknown-cmd        # → 終了コード 1
# Ctrl-C 送信            # → 終了コード 2
corun --invalid-flag     # → 終了コード 3
```

## 開発

```bash
make lint            # ShellCheck 静的解析
make format          # Shfmt コードフォーマット
make test            # 単体テスト（BATS）
make integration_test # 結合テスト
make build           # ビルド（実行権限付与）
make ci              # CI 全ステップ実行
make help            # コマンド一覧
```

## ライセンス

[LICENSE](./LICENSE) をご参照ください。
