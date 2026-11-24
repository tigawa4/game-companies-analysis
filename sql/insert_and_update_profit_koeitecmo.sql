-- 登録対象の会計年度と書類管理番号を指定する
WITH registration_targets(fiscal_year, document_id) AS (
 VALUES
  (2016, 'S100AI4U'),
  (2017, 'S100D8G0'),
  (2018, 'S100G2AS'),
  (2019, 'S100IU56'),
  (2020, 'S100LK40'),
  (2021, 'S100O9GQ'),
  (2022, 'S100QY9X'),
  (2023, 'S100TOUL'),
  (2024, 'S100W144'),
  (2025, 'S100YEES')
),
source AS (
 SELECT
  -- 証券コード
  companies.security_code,
  -- 企業
  companies.company_name,
  -- 会計年度
  registration_targets.fiscal_year,
  -- 書類管理番号
  documents.document_id,
  -- 期首日
  contexts.start_date AS period_start,
  -- 期末日
  contexts.end_date AS period_end,
  -- 勘定科目
  observations.metric_code,
  -- 金額
  observations.value
 FROM public.companies
 JOIN public.documents
  ON documents.edinet_code = companies.edinet_code
 JOIN registration_targets
  ON registration_targets.document_id = documents.document_id
 JOIN public.contexts
  ON contexts.dataset_id = documents.active_dataset_id
 JOIN public.observations
  ON observations.dataset_id = contexts.dataset_id
  AND observations.context_key = contexts.context_key
 JOIN public.units
  ON units.dataset_id = observations.dataset_id
  AND units.unit_key = observations.unit_key
 WHERE
  -- EDINETコード(株式会社コーエーテクモホールディングス)
  companies.edinet_code = 'E22460'
  -- 有価証券報告書および訂正有価証券報告書に限定する
  AND documents.document_type_code IN ('120', '130')
  -- ETLで処理済みの書類に限定する
  AND documents.processing_state = 'processed'
  -- 期首日は登録対象年度の4月1日とする
  AND contexts.start_date = CAST(registration_targets.fiscal_year || '-04-01' AS date)
  -- 期末日は登録対象年度の翌年の3月31日とする
  AND contexts.end_date = CAST((registration_targets.fiscal_year + 1) || '-03-31' AS date)
  -- フロー情報に限定する(ストック情報を除外する)
  AND contexts.period_kind = 'duration'
  -- 書類内の当期分に限定する(前期の比較値などを除外する)
  AND contexts.period_role = 'current'
  -- 連結財務諸表のデータに限定する
  AND contexts.consolidation = 'consolidated'
  -- 日本会計基準(J-GAAP)のデータに限定する
  AND contexts.accounting_standard = 'JGAAP'
  -- 地域別や事業別などのディメンションのついていないデータに限定する
  AND contexts.dimensions = '{}'::jsonb
  -- 単位が日本円(JPY)のデータに限定する
  AND units.measures = '["{http://www.xbrl.org/2003/iso4217}JPY"]'::jsonb
  -- 分母の単位がないデータに限定する("円/株"などの単位を除外する)
  AND units.denominator = '[]'::jsonb
  -- 取得結果のステータスが"利用可能"のデータに限定する
  AND observations.status = 'available'
  AND observations.value IS NOT NULL
  AND observations.metric_code IN (
   -- 売上高
   'revenue',
   -- 売上原価
   'cost_of_sales',
   -- 売上総利益
   'gross_profit',
   -- 販売費及び一般管理費
   'selling_general_and_administrative_expenses',
   -- 営業利益
   'operating_profit',
   -- 営業外収益
   'non_operating_income',
   -- 営業外費用
   'non_operating_expenses',
   -- 経常利益
   'ordinary_profit',
   -- 特別利益
   'extraordinary_income',
   -- 特別損失
   'extraordinary_loss',
   -- 税引前当期純利益
   'profit_before_tax',
   -- 法人税等
   'income_taxes',
   -- 当期純利益
   'net_income'
  )
),
-- 抽出した損益項目を対象書類ごとに横持ちに変換する
-- 抽出条件にあう値がない項目はNULLとなる
summary AS (
 SELECT
  security_code,
  company_name,
  fiscal_year,
  document_id,
  period_start,
  period_end,
  MAX(CASE WHEN metric_code = 'revenue' THEN value END) AS revenue,
  MAX(CASE WHEN metric_code = 'cost_of_sales' THEN value END) AS cost_of_sales,
  MAX(CASE WHEN metric_code = 'gross_profit' THEN value END) AS gross_profit,
  MAX(CASE WHEN metric_code = 'selling_general_and_administrative_expenses' THEN value END) AS selling_general_and_administrative_expenses,
  MAX(CASE WHEN metric_code = 'operating_profit' THEN value END) AS operating_profit,
  MAX(CASE WHEN metric_code = 'non_operating_income' THEN value END) AS non_operating_income,
  MAX(CASE WHEN metric_code = 'non_operating_expenses' THEN value END) AS non_operating_expenses,
  MAX(CASE WHEN metric_code = 'ordinary_profit' THEN value END) AS ordinary_profit,
  MAX(CASE WHEN metric_code = 'extraordinary_income' THEN value END) AS extraordinary_income,
  MAX(CASE WHEN metric_code = 'extraordinary_loss' THEN value END) AS extraordinary_loss,
  MAX(CASE WHEN metric_code = 'profit_before_tax' THEN value END) AS profit_before_tax,
  MAX(CASE WHEN metric_code = 'income_taxes' THEN value END) AS income_taxes,
  MAX(CASE WHEN metric_code = 'net_income' THEN value END) AS net_income
 FROM source
 GROUP BY
  security_code,
  company_name,
  fiscal_year,
  document_id,
  period_start,
  period_end
  -- 同じ損益項目が複数行あるグループは登録対象から除外する
 HAVING COUNT(*) = COUNT(DISTINCT metric_code)
)
INSERT INTO public.profit (
 security_code,
 company_name,
 fiscal_year,
 period_start,
 period_end,
 revenue,
 cost_of_sales,
 gross_profit,
 selling_general_and_administrative_expenses,
 operating_profit,
 non_operating_income,
 non_operating_expenses,
 ordinary_profit,
 extraordinary_income,
 extraordinary_loss,
 profit_before_tax,
 income_taxes,
 net_income,
 source_document_id
)
SELECT
 security_code,
 company_name,
 fiscal_year,
 period_start,
 period_end,
 revenue,
 cost_of_sales,
 gross_profit,
 selling_general_and_administrative_expenses,
 operating_profit,
 non_operating_income,
 non_operating_expenses,
 ordinary_profit,
 extraordinary_income,
 extraordinary_loss,
 profit_before_tax,
 income_taxes,
 net_income,
 document_id
FROM summary

-- 冪等性を実現する
-- 同じ入力で再実行しても登録結果が変わらないようにする
ON CONFLICT (security_code, fiscal_year)
DO UPDATE SET
 company_name = EXCLUDED.company_name,
 period_start = EXCLUDED.period_start,
 period_end = EXCLUDED.period_end,
 revenue = EXCLUDED.revenue,
 cost_of_sales = EXCLUDED.cost_of_sales,
 gross_profit = EXCLUDED.gross_profit,
 selling_general_and_administrative_expenses = EXCLUDED.selling_general_and_administrative_expenses,
 operating_profit = EXCLUDED.operating_profit,
 non_operating_income = EXCLUDED.non_operating_income,
 non_operating_expenses = EXCLUDED.non_operating_expenses,
 ordinary_profit = EXCLUDED.ordinary_profit,
 extraordinary_income = EXCLUDED.extraordinary_income,
 extraordinary_loss = EXCLUDED.extraordinary_loss,
 profit_before_tax = EXCLUDED.profit_before_tax,
 income_taxes = EXCLUDED.income_taxes,
 net_income = EXCLUDED.net_income,
 source_document_id = EXCLUDED.source_document_id
 
RETURNING *;