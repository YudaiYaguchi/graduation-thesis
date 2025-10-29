#!/bin/bash

# ===============================
# LaTeX PDF ビルドスクリプト
# ===============================

# コンパイル対象ファイル
TEX_FILE="final.tex"
DVI_FILE="final.dvi"
PDF_FILE="final.pdf"

# ===== 関数定義 =====

# エラー発生時の共通処理
error_exit() {
  echo "❌ エラー: $1"
  exit 1
}

# ===== 実行開始 =====
echo "🧩 LaTeX コンパイルを開始します..."

# TEXファイル存在確認
if [ ! -f "$TEX_FILE" ]; then
  error_exit "$TEX_FILE が見つかりません。"
fi

# 1回目のplatexコンパイル
echo "▶ 1回目の platex 実行中..."
platex "$TEX_FILE" > /dev/null 2>&1
if [ $? -ne 0 ]; then
  error_exit "platex (1回目) の実行に失敗しました。"
fi

# 2回目のplatexコンパイル
echo "▶ 2回目の platex 実行中..."
platex "$TEX_FILE" > /dev/null 2>&1
if [ $? -ne 0 ]; then
  error_exit "platex (2回目) の実行に失敗しました。"
fi

# DVI → PDF変換
echo "▶ dvipdfmx による PDF 生成中..."
dvipdfmx "$DVI_FILE" > /dev/null 2>&1
if [ $? -ne 0 ]; then
  error_exit "dvipdfmx による PDF 生成に失敗しました。"
fi

# PDF生成確認
if [ ! -f "$PDF_FILE" ]; then
  error_exit "PDF ファイルが生成されませんでした。"
fi

echo "✅ PDF生成が完了しました: $PDF_FILE"
exit 0
