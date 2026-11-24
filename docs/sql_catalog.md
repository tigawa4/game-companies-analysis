# SQL一覧

前提はPostgreSQLの `public` スキーマにある `companies`、`documents`、`contexts`、`observations`、`units` と、対象書類の処理済みデータです。元DBの定義・登録済みデータは別途必要です。下表は依存関係に基づく順序です。

| 順序 | ファイル | 用途 |
| --- | --- | --- |
| 事前確認（任意） | [check_download_coverage.sql](../sql/check_download_coverage.sql) | 対象3社×10年度の書類登録・処理状況を確認するSELECT。訂正書類等で複数行になる場合があります |
| 1 | [create_profit_table.sql](../sql/create_profit_table.sql) | `public.profit` を新規作成。すでに存在する場合はCREATE TABLEがエラーになります |
| 2 | [insert_and_update_profit_Nintendo.sql](../sql/insert_and_update_profit_Nintendo.sql) | 任天堂の損益項目を挿入または更新 |
| 2 | [insert_and_update_profit_capcom.sql](../sql/insert_and_update_profit_capcom.sql) | カプコンの損益項目を挿入または更新 |
| 2 | [insert_and_update_profit_koeitecmo.sql](../sql/insert_and_update_profit_koeitecmo.sql) | コーエーテクモホールディングスの損益項目を挿入または更新 |
| 3 | [create_view_profit_million_yen.sql](../sql/create_view_profit_million_yen.sql) | 13の金額列を円から百万円へ換算 |
| 3 | [create_view_profit_growth_rates.sql](../sql/create_view_profit_growth_rates.sql) | 同一企業の直前年度と比較して、金額項目の増減率を計算 |
| 4 | [create_view_profit_indicators.sql](../sql/create_view_profit_indicators.sql) | 売上原価率、売上総利益率、販管費率、営業利益率、経常利益率、当期純利益率および売上高成長率を提供 |

## 抽出と欠損

会社別SQLは会社ごとに年度と書類管理番号を固定します。処理済みの有価証券報告書（120）または訂正有価証券報告書（130）の採用変換版を使います。当期（`current`）の期間値（`duration`）で、対象年度の4月1日から翌年3月31日までに一致する連結・日本基準・追加ディメンションなしのデータを選びます。単位は分母なしのJPY、値は `available` かつ非NULLに絞ります。

同一書類・期間の候補内に同じ指標が複数あると、そのグループ全体が登録から外れます。登録行の欠損項目はNULLです。候補が消えた年度について、再実行時に既存の `profit` 行を削除する処理はありません。書類の採用方針、訂正の反映、候補重複や欠年の有無は要確認です。取得状況SQLの処理状態だけでは、標準化済みの値や原本との一致までは確認できません。

## 指標と単位

当年と直前年度の値があり、前年値が正の場合に、増減率を `当年値 ÷ 前年値 − 1` で算出します。それ以外はNULLです。収益性の各比率は対象金額を売上高で割り、売上高が0または欠損の場合はNULLになります。増減率・収益性の比率はいずれも小数で、表示時の百分率は100倍です。比率の前年差（ポイント）は2年の比率の差を100倍した量で、提供ビューには含まれません。
