<!--
Sync Impact Report
==================
Version change: N/A → 1.0.0 (initial creation)

Modified principles: N/A (initial creation)

Added sections:
  - Core Principles (10 principles from copilot-instructions.md)
  - Technology Stack
  - Development Workflow
  - Governance

Removed sections: N/A

Templates requiring updates:
  ✅ .specify/templates/constitution-template.md (source used)
  ⚠ .specify/templates/plan-template.md (pending review)
  ⚠ .specify/templates/spec-template.md (pending review)
  ⚠ .specify/templates/tasks-template.md (pending review)

Follow-up TODOs:
  - TODO(RATIFICATION_DATE): 正式な批准日を確定する（現状は初回作成日 2026-02-20 を使用）
  - TODO(AUTHORS): 主要承認者を authors フィールドに記載する
-->

# corun Constitution

## Core Principles

### I. コード品質 (Code Quality)

すべてのコードは定められたスタイルガイドとリントルールに従わなければならない (MUST)。
すべてのプルリクエストはコードレビューを通過し、CIテストを成功させなければならない (MUST)。
可読性と拡張性を維持するため、リファクタリングと共通処理化を優先しなければならない (MUST)。

- Static analysis: ShellCheck (`make lint`)
- Formatting: Shfmt (`make format`)
- Review gate: PR マージ前に CI 全ステップが green であること

**Rationale**: コードの保守性・テスト容易性・明確さは長期的な開発速度と品質を担保する基盤である。

### II. テスト標準 (NON-NEGOTIABLE)

TDD は必須であり、エッジケースを含む十分なテストカバレッジを確保しなければならない (MUST)。
Red-Green-Refactor サイクルを厳守し、テストが失敗することを確認してから実装しなければならない (MUST)。
コアモジュールのテストカバレッジは最低 85% を達成しなければならない (MUST)。
重要な処理フローには結合テストを実装しなければならない (MUST)。
結合テストはコマンド単位でファイルを分割し、独立して再実行できなければならない (MUST)。

- Unit test framework: BATS (`make test`)
- Integration test: `make integration_test`
- 結合テスト重点領域: コマンドの実行フロー / エラー処理と例外ケース / 外部サービスとの統合ポイント / パフォーマンスに影響する処理

**Rationale**: テストなしの実装は技術的負債を生み、長期的なリリース品質を低下させる。

### III. インターフェイス (Interface)

テキスト入出力はプロトコルに従わなければならない (MUST): `stdin/args → stdout`, `errors → stderr`。
設定ファイルは JSON / YAML / TOML 形式で、ユーザーフレンドリーな構造を持たなければならない (MUST)。
以下のオプションを提供しなければならない (MUST):

- `--verbose`: 詳細なログや情報を表示
- `-v`, `--version`: バージョン情報を表示
- `-h`, `--help`: 使用方法を表示

**Rationale**: 標準的な CLI インターフェイスはパイプ連携・スクリプトの自動化・ユーザビリティを高める。

### IV. パフォーマンス要件 (Performance)

各機能実装ごとにパフォーマンス監視を実施しなければならない (MUST)。

**Rationale**: 機能単位でパフォーマンスを継続的に測定することで、劣化を早期に検出できる。

### V. セキュリティ要件 (Security)

機密情報（APIキー、パスワードなど）をコードベースにハードコードしてはならない (MUST NOT)。
OWASP のセキュリティガイドラインを遵守しなければならない (MUST)。
シークレットは環境変数または CI のシークレット管理機構（例: GitHub Secrets）を通じて管理しなければならない (MUST)。

**Rationale**: ハードコードされた機密情報は漏洩リスクを著しく高め、信頼性とコンプライアンスを損なう。

### VI. 可観測性 (Observability)

テキスト I/O はデバッグ可能性を保証しなければならない (MUST)。
構造化されたログ記録を実装しなければならない (MUST)。
ログ形式は JSON を推奨し、少なくとも `timestamp`, `command`, `exit_code` を含めること (SHOULD)。

**Rationale**: 構造化ログにより、CI・本番環境での問題特定と自動分析が容易になる。

### VII. バージョン管理と互換性のない変更 (Versioning & Breaking Changes)

バージョン形式は SemVer（Semantic Versioning）に準拠しなければならない (MUST):
`MAJOR.MINOR.PATCH[-PRERELEASE][+BUILD]`

コミットログは Conventional Commits の形式に準拠しなければならない (MUST)。
次のバージョンは Conventional Commits のコミットログから決定しなければならない (MUST)。

- MAJOR: 破壊的変更 (`BREAKING CHANGE`)
- MINOR: 後方互換性のある機能追加 (`feat:`)
- PATCH: バグ修正・ドキュメント等 (`fix:`, `docs:`, etc.)

**Rationale**: SemVer と Conventional Commits により、リリース自動化・依存管理・変更履歴の透明性が確保される。

### VIII. シンプルさ (Simplicity)

シンプルに始め、シンプルに保たなければならない (MUST)。
YAGNI 原則（You Aren't Gonna Need It）を遵守しなければならない (MUST)。
不必要な複雑性の追加は正当化できなければならない (MUST)。

**Rationale**: 過剰な設計はメンテナンスコストを増大させ、変更への適応力を低下させる。

### IX. ガバナンス (Governance)

本憲章は他のすべての慣行に優先する (MUST)。
憲章の改正には文書化・承認・移行計画が必要である (MUST)。
憲章バージョンは SemVer に準拠する:
- MAJOR: 後方非互換なガバナンス/原則の削除・再定義
- MINOR: 新原則・セクションの追加または大幅な拡充
- PATCH: 文言の明確化・誤字修正・非意味的な修正

**Rationale**: 明確なガバナンスルールにより、一貫性のある意思決定と変更管理が可能になる。

### X. ドキュメント整備 (Documentation)

ドキュメントは日本語で記載しなければならない (MUST)。
新機能や重要な変更点は、必ず開発者向けドキュメントを更新しなければならない (MUST)。
`README.md` / `CHANGELOG.md` / `CONTRIBUTING.md` などの主要ドキュメントは常に最新の状態を保たなければならない (MUST)。
コード内コメントはコードの意図・複雑なロジックを説明するために使用し、変更に合わせて更新しなければならない (MUST)。
重要な設計判断は ADR として `docs/adr/` に記録し、ADR を真実の源泉（source of truth）としなければならない (MUST)。

**Rationale**: 一貫したドキュメントはチームの共有理解を保ち、新メンバーやエージェントのオンボーディングコストを下げる。

## Technology Stack

| ロール | ツール | バージョン要件 |
|---|---|---|
| スクリプト言語 | bash | 0.5.2+ |
| AI CLI 連携 | GitHub Copilot CLI | 0.0.400+ |
| YAML 処理 | yq | 4.30.8+ |
| JSON 処理 | jq | 1.6+ |
| 単体テスト | BATS | 1.3.0+ |
| 静的解析 | ShellCheck | 0.9.0+ |
| コードフォーマット | Shfmt | 3.4.1+ |
| ビルド自動化 | make | 4.3+ |
| CI/CD | GitHub Actions | — |

## Development Workflow

1. 仕様確認: `docs/adr/` → `docs/specs/features/` → `docs/architecture/` の順で参照
2. テスト作成: 実装前にテストを作成し、失敗を確認（Red）
3. 実装: テストが通るまで実装（Green）
4. リファクタリング: テストが通ることを維持しつつリファクタリング（Refactor）
5. 品質チェック: `make lint` → `make test` → `make integration_test` → `make build`
6. PR 作成: Conventional Commits 形式のコミットメッセージ・関連 ADR へのリンクを含める
7. レビュー: CI 全ステップが green であること・コードレビュー通過を必須とする

## Governance

本憲章はすべての慣行・ガイドライン・プロセスに優先する。

**改正手順**:
1. 改正案を PR として提出する
2. 変更の背景・影響・移行計画を PR に明記する
3. メンテナの承認を得る
4. 承認後に `LAST_AMENDED_DATE` とバージョンを更新する
5. 影響を受けるテンプレート・ガイドを更新する

**コンプライアンス**:
- すべての PR・コードレビューで本憲章への準拠を確認すること (MUST)
- 複雑性の追加は必ず正当化すること (MUST)
- 実行時の開発ガイドは `.github/copilot-instructions.md` を参照すること

**Version**: 1.0.0 | **Ratified**: 2026-02-20 | **Last Amended**: 2026-02-20
