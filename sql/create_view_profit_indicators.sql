-- 収益性・利益構造を示す指標を提供するView
CREATE OR REPLACE VIEW public.profit_indicators AS
WITH profit_ratios AS (
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
  -- 売上原価率
  cost_of_sales / NULLIF(revenue, 0) AS cost_of_sales_ratio,
  -- 売上総利益率
  gross_profit / NULLIF(revenue, 0) AS gross_profit_margin,
  -- 販管費率
  selling_general_and_administrative_expenses / NULLIF(revenue, 0) AS sga_ratio,
  -- 営業利益率
  operating_profit / NULLIF(revenue, 0) AS operating_profit_margin,
  -- 経常利益率
  ordinary_profit / NULLIF(revenue, 0) AS ordinary_profit_margin,
  -- 当期純利益率(連結)
  net_income / NULLIF(revenue, 0) AS net_income_margin,
  -- 書類管理番号
  source_document_id
 FROM public.profit
)
SELECT
 profit_ratios.*,
 -- 売上高成長率
 profit_growth_rates.revenue_growth_rate
FROM 
 profit_ratios
LEFT OUTER JOIN public.profit_growth_rates
ON profit_ratios.security_code = profit_growth_rates.security_code
AND profit_ratios.fiscal_year = profit_growth_rates.fiscal_year;
