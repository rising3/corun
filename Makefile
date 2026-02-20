# corun Makefile
#
# 使用方法: make <target>
# 例: make test, make lint, make build

SHELL := /usr/bin/env bash
.SHELLFLAGS := -euo pipefail -c

# ディレクトリ定義
BIN_DIR     := bin
SRC_DIR     := src
TEST_DIR    := tests/unit
INT_TEST_DIR := integration_tests
FIXTURE_DIR := tests/fixtures

# ツール定義
SHELLCHECK  := shellcheck
SHFMT       := shfmt
BATS        := bats
BASH        := bash

# 解析対象ファイル
SH_FILES    := $(shell find $(SRC_DIR) -name '*.sh' 2>/dev/null) \
               $(shell test -f $(BIN_DIR)/corun && echo $(BIN_DIR)/corun || true)
BATS_UNIT   := $(shell find $(TEST_DIR) -name '*.bats' 2>/dev/null)
BATS_INT    := $(shell find $(INT_TEST_DIR) -name '*.bats' 2>/dev/null)

.DEFAULT_GOAL := help

# ─────────────────────────────────────────────────
# help: 使用可能なコマンドと説明の一覧を表示する
# ─────────────────────────────────────────────────
.PHONY: help
help:
	@echo "corun - 使用可能な make ターゲット"
	@echo ""
	@echo "  make lint             シェルスクリプトの静的解析 (shellcheck)"
	@echo "  make format           コードフォーマット自動修正 (shfmt)"
	@echo "  make format-check     フォーマット差分チェック (shfmt --diff, CI 用)"
	@echo "  make test             単体テストの実行 (bats tests/unit/)"
	@echo "  make integration_test 結合テストの実行 (bats integration_tests/)"
	@echo "  make build            ビルド (bin/corun の実行権限付与・検証)"
	@echo "  make clean            ビルド成果物・一時ファイルの削除"
	@echo "  make all              lint + format-check + test + integration_test + build"
	@echo "  make ci               CI 環境用: all と同等"
	@echo "  make help             このヘルプを表示"

# ─────────────────────────────────────────────────
# lint: ShellCheck による静的解析
# ─────────────────────────────────────────────────
.PHONY: lint
lint:
	@echo "==> lint: ShellCheck"
	@if [ -z "$(SH_FILES)" ]; then \
		echo "  (解析対象ファイルなし)"; \
	else \
		$(SHELLCHECK) --shell=bash $(SH_FILES); \
		echo "  OK"; \
	fi

# ─────────────────────────────────────────────────
# format: Shfmt によるコードフォーマット自動修正
# ─────────────────────────────────────────────────
.PHONY: format
format:
	@echo "==> format: shfmt -w"
	@if [ -z "$(SH_FILES)" ]; then \
		echo "  (フォーマット対象ファイルなし)"; \
	else \
		$(SHFMT) -w -i 2 -ci $(SH_FILES); \
		echo "  OK"; \
	fi
	@if [ -n "$(BATS_UNIT)$(BATS_INT)" ]; then \
		$(SHFMT) -w -i 2 -ci $(BATS_UNIT) $(BATS_INT); \
	fi

# ─────────────────────────────────────────────────
# format-check: フォーマット差分チェック (CI 用)
# 差分があれば非ゼロで終了してCIを失敗させる
# ─────────────────────────────────────────────────
.PHONY: format-check
format-check:
	@echo "==> format-check: shfmt --diff"
	@if [ -z "$(SH_FILES)" ]; then \
		echo "  (チェック対象ファイルなし)"; \
	else \
		$(SHFMT) -d -i 2 -ci $(SH_FILES); \
	fi
	@if [ -n "$(BATS_UNIT)$(BATS_INT)" ]; then \
		$(SHFMT) -d -i 2 -ci $(BATS_UNIT) $(BATS_INT); \
	fi
	@echo "  OK"

# ─────────────────────────────────────────────────
# test: 単体テストの実行
# ─────────────────────────────────────────────────
.PHONY: test
test:
	@echo "==> test: bats $(TEST_DIR)/"
	@if [ -z "$(BATS_UNIT)" ]; then \
		echo "  (単体テストファイルなし)"; \
	else \
		$(BATS) $(TEST_DIR)/; \
	fi

# ─────────────────────────────────────────────────
# integration_test: 結合テストの実行
# ─────────────────────────────────────────────────
.PHONY: integration_test
integration_test:
	@echo "==> integration_test: bats $(INT_TEST_DIR)/"
	@if [ -z "$(BATS_INT)" ]; then \
		echo "  (結合テストファイルなし)"; \
	else \
		$(BATS) $(INT_TEST_DIR)/; \
	fi

# ─────────────────────────────────────────────────
# build: bin/corun の実行権限付与と構文チェック
# ─────────────────────────────────────────────────
.PHONY: build
build:
	@echo "==> build"
	@if [ ! -f $(BIN_DIR)/corun ]; then \
		echo "  SKIP: $(BIN_DIR)/corun が存在しません"; \
	else \
		chmod +x $(BIN_DIR)/corun; \
		$(BASH) -n $(BIN_DIR)/corun; \
		echo "  OK: $(BIN_DIR)/corun"; \
	fi

# ─────────────────────────────────────────────────
# clean: ビルド成果物と一時ファイルの削除
# ─────────────────────────────────────────────────
.PHONY: clean
clean:
	@echo "==> clean"
	@rm -rf dist/ .bats_tmp/ 2>/dev/null || true
	@echo "  OK"

# ─────────────────────────────────────────────────
# all: 全工程を順番に実行
# ─────────────────────────────────────────────────
.PHONY: all
all: lint format-check test integration_test build

# ─────────────────────────────────────────────────
# ci: CI 環境用（all と同等）
# ─────────────────────────────────────────────────
.PHONY: ci
ci: all
