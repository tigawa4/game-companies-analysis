# テーブル定義とデータ辞書

元のPostgreSQLスキーマと公開SQLから、分析に関係する列と制約を抜粋します。

| 元DBのテーブル | 主キー | 役割・参照関係 |
| --- | --- | --- |
| `companies` | `edinet_code` | 提出者。分析では `security_code`、`company_name` を使用 |
| `documents` | `document_id` | 書類台帳。`edinet_code` は `companies` を参照。`(active_dataset_id, document_id)` は `datasets(dataset_id, document_id)` を参照。書類種別・処理状態・対象期間を保持 |
| `datasets` | `dataset_id` | 書類ごとの変換版。`document_id` は `documents` を参照 |
| `contexts` | `(dataset_id, context_key)` | `start_date`、`end_date`、`period_kind`、`period_role`、`consolidation`、`accounting_standard`、`dimensions` を保持 |
| `units` | `(dataset_id, unit_key)` | 分子 `measures` と分母 `denominator` の単位を保持 |
| `raw_facts` | `(dataset_id, fact_key)` | 変換前の出典をたどるための元行 |
| `observations` | `(dataset_id, observation_key)` | 標準項目の `metric_code`、`value`、`status` を保持。変換版とコンテキスト・単位・元行を参照。 `(dataset_id, metric_code, context_key)` に一意制約 |

`contexts`、`units`、`raw_facts`、`observations` の `dataset_id` は `datasets` を参照します。`raw_facts` と `observations` のコンテキスト・単位参照は、対応するキーと `dataset_id` の複合外部キーです。`observations` は `(dataset_id, source_fact_key)` で元行を参照します。

## 加工テーブル `public.profit`

| 列 | 型 | 定義 |
| --- | --- | --- |
| `security_code`, `company_name` | `text` | 証券コードと企業名。必須 |
| `fiscal_year` | `integer` | 期首年。必須 |
| `period_start`, `period_end` | `date` | 期首日と期末日。必須。期首日が期末日以前であることをCHECK制約で保証 |
| `source_document_id` | `text` | 採用した書類管理番号。必須。`public.documents(document_id)` への外部キー |
| 損益項目13列 | `numeric` | 円単位。NULL可 |

主キーは `(security_code, fiscal_year)` です。期首年と日付の対応、連結区分、会計基準、通貨は登録SQLの抽出条件です。

| 損益項目の列 | 意味 |
| --- | --- |
| `revenue`, `cost_of_sales`, `gross_profit` | 売上高、売上原価、売上総利益 |
| `selling_general_and_administrative_expenses`, `operating_profit` | 販売費及び一般管理費、営業利益 |
| `non_operating_income`, `non_operating_expenses`, `ordinary_profit` | 営業外収益、営業外費用、経常利益 |
| `extraordinary_income`, `extraordinary_loss` | 特別利益、特別損失 |
| `profit_before_tax`, `income_taxes`, `net_income` | 税引前当期純利益、法人税等、連結の当期純利益 |

日本基準の `net_income` は `ProfitLoss` に対応します。親会社株主に帰属する当期純利益（`ProfitLossAttributableToOwnersOfParent`）は別項目です。

分析用ビューの算出方法は[SQL一覧](sql_catalog.md)を参照してください。
