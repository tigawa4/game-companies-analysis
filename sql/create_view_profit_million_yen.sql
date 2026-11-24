-- 損益計算書の金額を円から百万円に変換するView
CREATE OR REPLACE VIEW public.profit_million_yen AS(
 SELECT
  -- 証券コード
  security_code,
  -- 企業
  company_name,
  -- 会計年度
  fiscal_year,
  -- 期首日
  period_start,
  -- 期末日
  period_end,
  -- 売上高
  revenue / 1000000 AS revenue_million_yen,
  -- 売上原価
  cost_of_sales / 1000000 AS cost_of_sales_million_yen,
  -- 売上総利益
  gross_profit / 1000000 AS gross_profit_million_yen,
  -- 販売費及び一般管理費
  selling_general_and_administrative_expenses / 1000000 AS sga_million_yen,
  -- 営業利益
  operating_profit / 1000000 AS operating_profit_million_yen,
  -- 営業外収益
  non_operating_income / 1000000 AS non_operating_income_million_yen,
  -- 営業外費用
  non_operating_expenses / 1000000 AS non_operating_expenses_million_yen,
  -- 経常利益
  ordinary_profit / 1000000 AS ordinary_profit_million_yen,
  -- 特別利益
  extraordinary_income / 1000000 AS extraordinary_income_million_yen,
  -- 特別損失
  extraordinary_loss / 1000000 AS extraordinary_loss_million_yen,
  -- 税引前当期純利益
  profit_before_tax / 1000000 AS profit_before_tax_million_yen,
  -- 法人税等
  income_taxes / 1000000 AS income_taxes_million_yen,
  -- 当期純利益(連結)
  net_income / 1000000 AS net_income_million_yen,
  -- 書類管理番号
  source_document_id
 FROM public.profit
);