-- 対象3社について2016年度から2025年度の(訂正)有価証券報告書の取得状況とETL処理状況を確認するクエリ
-- 会計年度は期首時点の西暦で表す(2025年度:2025/04/01-2026/03/31)
-- 有価証券報告書(120)および訂正有価証券報告書(130)を対象とする
WITH target_companies(security_code, company_name) AS (
 VALUES
  ('79740', '任天堂株式会社'),
  ('96970', '株式会社カプコン'),
  ('36350', '株式会社コーエーテクモホールディングス')
), target_years(fiscal_year) AS (
 VALUES
  (2016),
  (2017),
  (2018),
  (2019),
  (2020),
  (2021),
  (2022),
  (2023),
  (2024),
  (2025)
), expected AS (
 SELECT 
  -- 対象企業
  target_companies.*,
  -- 会計年度
  target_years.fiscal_year,
  -- 期首日
  CAST(target_years.fiscal_year || '-04-01' AS DATE) AS period_start,
  -- 期末日
  CAST((target_years.fiscal_year + 1) || '-03-31' AS DATE) AS period_end
 FROM target_companies
 CROSS JOIN target_years
)
SELECT
 -- 企業
 expected.company_name,
 -- 会計年度
 expected.fiscal_year,
 -- 書類管理番号
 documents.document_id,
 -- 書類種別(有価証券報告書または訂正有価証券報告書)
 documents.document_type_code,
 -- 処理状態
 documents.processing_state,
 -- 失敗または取得見送りの理由
 documents.processing_error
FROM expected
LEFT JOIN public.companies
 ON companies.security_code = expected.security_code
LEFT JOIN public.documents
 ON documents.edinet_code = companies.edinet_code
 AND documents.period_start = expected.period_start
 AND documents.period_end = expected.period_end
 AND documents.document_type_code IN ('120', '130')
ORDER BY
 expected.security_code,
 expected.fiscal_year,
 documents.submitted_at,
 documents.document_id;