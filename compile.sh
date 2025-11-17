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

# ===== 全角句読点変換（複数ファイル対応） =====
echo "🔧 全角句読点（。→．、→，）を複数ファイルに対して変換します..."

# 変換対象ファイルリスト: 引数で指定があればそれを使い、なければデフォルトリストを使う
if [ "$#" -gt 0 ]; then
  PUNCT_FILES=("$@")
else
  # デフォルトで句読点を直すファイルをここに列挙します。必要に応じて追加してください。
  PUNCT_FILES=("final.tex" "reference.tex" "1.tex" "2.tex" "3.tex")
fi

total_period=0
total_comma=0
for f in "${PUNCT_FILES[@]}"; do
  if [ ! -f "$f" ]; then
    echo "⚠ ファイルが見つかりません（スキップ）: $f"
    continue
  fi

  # 変換前の個数をカウント
  count_period=$(grep -o "。" "$f" | wc -l)
  count_comma=$(grep -o "、" "$f" | wc -l)

  echo "　$f — 検出: 「。」=$count_period、「、」=$count_comma"

  # 置換（GNU sed を想定）。環境によっては sed の -i オプションの挙動が異なるため
  # 必要なら -i.bak 等を使うか、引数でファイル指定して実行してください。
  sed -i -e 's/。/．/g' -e 's/、/，/g' "$f"
  if [ $? -ne 0 ]; then
    error_exit "句読点変換中にエラーが発生しました: $f"
  fi

  total_period=$((total_period + count_period))
  total_comma=$((total_comma + count_comma))
done

echo "　変換対象合計 — 検出: 「。」=$total_period、「、」=$total_comma"

# 1回目のplatexコンパイル
echo "▶ 1回目の platex 実行中..."
platex "$TEX_FILE" > /dev/null 2>&1
if [ $? -ne 0 ]; then
  error_exit "platex (1回目) の実行に失敗しました。"
fi

# # 2回目のplatexコンパイル
# echo "▶ 2回目の platex 実行中..."
# platex "$TEX_FILE" > /dev/null 2>&1
# if [ $? -ne 0 ]; then
#   error_exit "platex (2回目) の実行に失敗しました。"
# fi

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

# sleep 4

# # 一時ファイルのクリーンアップ
# echo "🧹 不要な一時ファイルを削除しています..."
# if rm -f final.log final.aux final.dvi final.fdb_latexmk final.fls final.toc final.out final.synctex.gz; then
#   echo "🧼 一時ファイルを削除しました（エディタの警告を防止）。"
# else
#   echo "⚠ 一時ファイルの削除に失敗しました。手動で削除してください。"
# fi
# touch final.log final.aux final.dvi final.fdb_latexmk final.fls final.toc final.out final.synctex.gz && rm -f final.log final.aux final.dvi final.fdb_latexmk final.fls final.toc final.out final.synctex.gz


exit 0
