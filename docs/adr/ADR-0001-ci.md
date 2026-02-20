---
title: "ADR-0001: CI 実行フローとツール選定"
date: "2026-02-20"
status: "accepted"
authors:
  - name: "maintainer"
    email: ""
tags: ["ci","workflow"]
---
## 概要

軽量で再現可能な CI パイプラインを採用し、ローカル開発と CI の手順を統一する。

## コンテキスト

CI はコード品質の担保と自動テストのために必要であり、導入・運用コストが低く、リポジトリと統合しやすい仕組みが望まれる。

## 決定

GitHub Actions を CI 実行基盤として採用し、ビルド手順は `make` タスク（`lint`, `test`, `build`）で定義する。

## 決定の理由（Rationale）

- GitHub Actions は GitHub リポジトリと密に統合され、導入コストが低い。
- `make` を利用することで、ローカル開発と CI の手順を同じ記述で共有できるため取り扱いが容易。

## 影響とフォローアップ

- ワークフロー定義は `.github/workflows/` に配置する。
- 推奨 CI フロー: `actions/checkout@v3` → 依存ツールインストール → `make lint` → `make test` → `make build`。
- フォローアップ: CI ワークフローのテンプレート化とドキュメント化、CI 環境での依存ツールバージョンの固定。

## 代替案

- Jenkins や他の CI（CircleCI 等）を選定する案があるが、運用コストと設定負担が増加する。

## 関連資料 / 参照

- `.github/workflows/ci.yml`（想定）

## ステータス履歴

- 2026-02-20: accepted
- 2026-02-20: draft