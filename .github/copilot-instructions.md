# Copilot Instructions

## 役割: copilotの役割を明文化する
- Bash Scriptエキスパート開発者です。
- Bash SCriptのベストプラクティスに基づいた建設的な提案を提供します。
- 不明瞭な情報には、「これは...かもしれません」や「...を検討してください」などのフレーズを前置きとして付けてください。
- セキュリティとパフォーマンスを常に考慮し、コードの最適化を行います。
- 倫理的なコーディングプラクティスとセキュリティガイドラインを遵守します。
- コードの保守性、テスト容易性、明確さを優先してください。

## プロダクト概要（環境・手段・実行方法を記述する）

[GitHub Copilot CLI](https://github.com/github/copilot-cli)を利用して複数のプロンプトをnon-interactive modeで連続実行するためのCLIです。

### スクリプト名

- Script Name: `corun`

### 技術スタック

- bash
- GitHub Copilot CLI
- yq: YAMLを処理するためのコマンドラインツール
- jq: JSONを処理するためのコマンドラインツール
- BATS: Bash Automated Testing System、Bashスクリプトの単体テストフレームワーク
- ShellCheck: Bashスクリプトの静的解析ツール
- Shfmt: Bashスクリプトのコードフォーマッタ
- make: ビルド自動化ツール
- GitHub Actions: CI/CDパイプラインの構築に使用

### ディレクトリ構成

```
project-root/
├── bin/                 # 実行可能スクリプト
├── src/                 # ソースコード
├── tests/               # 単体テスト
├── integration_tests/   # 結合テスト
├── docs/                # ドキュメント
├── .github/             # GitHub ワークフローと設定
│   └── workflows/       # GitHub Actions ワークフロー
├── Makefile             # ビルド／テスト自動化
├── .gitignore           # Gitで無視するファイル一覧
├── Makefile             # ビルド／テスト自動化
└── README.md            # プロジェクト概要と使用方法
```

### ビルド

#### prerequisites

- bash version 5.2+
- GitHub Copilot CLI version 0.0.400+
- yq version 4.30.8+
- jq version 1.6+
- BATS version 1.3.0+
- ShellCheck version 0.9.0+
- Shfmt version 3.4.1+
- make version 4.3+

> 情報: これらのツールは、プロジェクトのビルドとテストに必要な前提条件です。インストールされていない場合は、各ツールの公式ドキュメントを参照してインストールしてください。

#### build command

| コマンド | 説明 | 標準的な実行時間 |
|---:|---|---|
| `make clean` | ビルド成果物・一時ファイルの削除（クリーン） | 数秒（<10秒） |
| `make build` | プロジェクトのビルド（コンパイル／パッケージ作成） | 数秒〜数分（約10秒〜2分、規模に依存） |
| `make test` | 単体テストの実行 | 数秒〜数分（約10秒〜3分、テスト数に依存） |
| `make integration_test` | 結合テスト（外部サービスや統合検証を含む） | 数分〜十数分（約1分〜10分、テスト内容に依存） |
| `make lint` | 静的解析（コードスタイル／Lint チェック） | 数秒〜1分（<1分） |
| `make format` | コードフォーマットの自動修正 | 数秒〜1分（<1分） |
| `make all` | ビルドとテストの全自動実行 | 数分（約10秒〜5分、プロジェクト規模とテスト数に依存） |
| `make ci` | CI環境でのビルドとテストの全自動実行 | 数分（約10秒〜5分、プロジェクト規模とテスト数に依存） |
| `make help` | 使用可能なコマンドと説明の表示 | 数秒（<10秒） |

### CIパイプライン

Use GitHub Actions for CI/CD pipeline.The pipeline defined in `.github/workflows/ci.yml` run on:
- push to `main`, `next` and `feature/**` branches
- pull request to `main`, `next` and `feature/**` branches

The pipeline includes the following steps:

| Step | Action/Command | Description |
|---:|---|---|
| 1 | `actions/checkout@v3` | リポジトリをチェックアウトしてソースを取得 |
| 2 | `install prerequisites` | `bash`, `copilot-cli`, `yq`, `jq`, `bats`, `shellcheck`, `shfmt`, `make` など必要ツールをインストール |
| 3 | `make lint` / `shellcheck` | シェルスクリプトの静的解析を実行しスタイルと潜在的な問題を検出 |
| 4 | `make format` / `shfmt --diff` | コードフォーマットの差分チェック（差分があれば CI 失敗） |
| 5 | `make test` / `bats` | 単体テストを実行 |
| 6 | `make integration_test` | 結合テストを実行（該当する場合） |
| 7 | `make build` | プロジェクトをビルド／パッケージ作成（該当する場合） |
| 8 | `actions/upload-artifact` / `codecov` | テスト結果やカバレッジレポートをアップロード |

aptで以下のツールをインストールすることができます：

```bash
sudo apt update
sudo apt install -y bash jq bats shellcheck shfmt make
```
GitHub Copilot CLI と yq は、公式のインストール手順に従ってインストールしてください。

### 単体テスト（フレームワーク、実行コマンド、設定ファイル等）

- BATS (Bash Automated Testing System) を使用して単体テストを実行します。
- テストファイルは `tests/` ディレクトリに配置され、`.bats` 拡張子を持ちます。
- 外部依存（GitHub Copilot CLI 等）を単体テストから切り離すために以下のスタブ戦略を採用する:
  - `tests/fixtures/` にスタブスクリプト（外部コマンドのシミュレーター）を配置し、`PATH` に優先追加して差し替える
  - BATS の `setup()` / `teardown()` で `PATH` を制御し、テスト間の副作用を排除する
  - 環境変数（`CORUN_VERBOSE` 等）はテスト内で直接設定し、`parse_flags()` を経由せず単体で検証可能にする
- テストの実行は以下のコマンドで行います。

```bash
make test
```

### 結合テスト（起動手順、テストデータ、実行方法等）

- 結合テストは `integration_tests/` ディレクトリに配置され、外部サービスや統合検証を含むテストを実行します。
- テストの実行は以下のコマンドで行います。

```bash
make integration_test
```

### コードスタイル

- ShellCheck を使用してコードの静的解析を行い、コードスタイルと潜在的な問題を検出します。
- Shfmt を使用してコードのフォーマットを自動修正します。
- コードスタイルのチェックとフォーマットは以下のコマンドで行います。

```bash
make lint
make format
```

## 厳守事項（絶対に守るべきルール・制約を宣言する）

1. コード品質

- すべてのコードは、定められたスタイルガイドとリントルールに従う必要がある。
- すべてのプルリクエストは、コードレビューを通過し、CIテストを成功させる必要がある。
- 可読性と拡張性を維持するため、必要に応じてコードのリファクタリングと共通処理化を優先する。
- `set -euo pipefail` はすべてのスクリプトで使用するが、パイプチェーン（`corun ... | head` 等）では SIGPIPE（終了コード 141）によって意図せずスクリプトが中断されることに注意する。SIGPIPE が発生しうる箇所は `|| true` または局所的な `set +e` でハンドリングし、結合テストでシナリオを明示的にカバーすること。

2. テスト標準(NON-NEGOTIABLE)（テストファースト前提、単体テスト・結合テストの必須ルールを含む）

- TDDは必須であり、エッジケースを含む十分なテストカバレッジを確保する必要がある。
- Red-Green-Refactor(テストを書く→ユーザーが承認する→テストが失敗する→その後実装する→テストが成功する→リファクタリングする→テストが成功するというプロセス)サイクルを遵守し、テストが失敗することを確認してからコードを実装し、最後にコードをリファクタリングする必要がある。
- コアモジュールのテストカバレッジは、最低でも85%を目指す必要がある。
- 重要な処理フローには結合テストを実装する必要がある。
- 結合テストは、コマンド単位で再実行できるに、コマンド単位でファイル分割する。
- 結合テストが必要な重点領域:
  - コマンドの実行フロー
  - エラー処理と例外ケース
  - 外部サービスとの統合ポイント
  - パフォーマンスに影響を与える可能性のある処理

3. インターフェイス

- テキスト入出力はプロトコル: stdin/args → stdout, errors → stderr
- 設定ファイルは、JSON/YAML/TOML形式で、ユーザーフレンドリーな構造を持つ必要がある。
- 詳細なログや情報を表示させるためのオプション(--verbose)を提供する必要がある。
- バージョン情報を表示させるためのオプション(-v, --version)を提供する必要がある。
- 使用方法を表示させるためのオプション(-h, --help)を提供する必要がある。

4. パフォーマンス要件

- 各機能実装毎にパフォーマンス監視を実施する。

5. セキュリティ要件

- 機密情報（APIキー、パスワードなど）をコードベースにハードコードしない。
- OWASPのセキュリティガイドラインを遵守する。

6. 可観測性

- テキストI/Oはデバッグ可能性を保証する。
- 構造化されたログ記録が必要。

7. バージョン管理と互換性のない変更

- バージョン形式は、SemVer（Semantic Versioning）に準拠する。
- コミットログは、conventional commitsの形式に準拠する。
- Conventional Commitsに準拠したコミットログから次のバージョンを決定する。

8. シンプルさ

- シンプルに始める
- シンプルに保つ
- YAGNI原則（You Aren't Gonna Need It）を遵守する

9. ガバナンス

- 憲法は他のすべての慣行に優先する。改正には文書、承認、移行計画が必要である。

10. ドキュメント整備

- 日本語で記載する。
- 新機能や重要な変更点は、必ず開発者向けドキュメントを更新する。
- README.md/CHANGELOG.md/CONTRIBUTING.mdなどの主要ドキュメントは常に最新の状態を保つ。
- コード内のコメントは、コードの意図や複雑なロジックを説明するために使用し、コードの変更に合わせて更新する。