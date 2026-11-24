-- 前年度からの増減率を提供するView
-- 前年度の値が正で当年度の値が存在する場合のみ算出する。それ以外の場合はNULLを返す。
CREATE OR REPLACE VIEW public.profit_growth_rates AS
 SELECT
  -- 証券コード
  current_year.security_code,
  -- 企業
  current_year.company_name,
  -- 会計年度
  current_year.fiscal_year,
  -- 期首日
  current_year.period_start,
  -- 期末日
  current_year.period_end,
  -- 売上高 前年度比増減率
  CASE WHEN previous_year.revenue > 0
       THEN (current_year.revenue / previous_year.revenue) - 1
  END AS revenue_growth_rate,
  -- 売上原価 前年度比増減率
  CASE WHEN previous_year.cost_of_sales > 0
       THEN (current_year.cost_of_sales / previous_year.cost_of_sales) - 1
  END AS cost_of_sales_growth_rate,
  -- 売上総利益 前年度比増減率
  CASE WHEN previous_year.gross_profit > 0
       THEN (current_year.gross_profit / previous_year.gross_profit) - 1
  END AS gross_profit_growth_rate,
  -- 販売費及び一般管理費 前年度比増減率
  CASE WHEN previous_year.selling_general_and_administrative_expenses > 0
       THEN (current_year.selling_general_and_administrative_expenses / previous_year.selling_general_and_administrative_expenses) - 1
  END AS sga_growth_rate,
  -- 営業利益 前年度比増減率
  CASE WHEN previous_year.operating_profit > 0
       THEN (current_year.operating_profit / previous_year.operating_profit) - 1
  END AS operating_profit_growth_rate,
  -- 営業外収益 前年度比増減率
  CASE WHEN previous_year.non_operating_income > 0
       THEN (current_year.non_operating_income / previous_year.non_operating_income) - 1
  END AS non_operating_income_growth_rate,
  -- 営業外費用 前年度比増減率
  CASE WHEN previous_year.non_operating_expenses > 0
       THEN (current_year.non_operating_expenses / previous_year.non_operating_expenses) - 1
  END AS non_operating_expenses_growth_rate,
  -- 経常利益 前年度比増減率
  CASE WHEN previous_year.ordinary_profit > 0
       THEN (current_year.ordinary_profit / previous_year.ordinary_profit) - 1
  END AS ordinary_profit_growth_rate,
  -- 特別利益 前年度比増減率
  CASE WHEN previous_year.extraordinary_income > 0
       THEN (current_year.extraordinary_income / previous_year.extraordinary_income) - 1
  END AS extraordinary_income_growth_rate,
  -- 特別損失 前年度比増減率
  CASE WHEN previous_year.extraordinary_loss > 0
       THEN (current_year.extraordinary_loss / previous_year.extraordinary_loss) - 1
  END AS extraordinary_loss_growth_rate,
  -- 税引前当期純利益 前年度比増減率
  CASE WHEN previous_year.profit_before_tax > 0
       THEN (current_year.profit_before_tax / previous_year.profit_before_tax) - 1
  END AS profit_before_tax_growth_rate,
  -- 法人税等 前年度比増減率
  CASE WHEN previous_year.income_taxes > 0
       THEN (current_year.income_taxes / previous_year.income_taxes) - 1
  END AS income_taxes_growth_rate,
  -- 当期純利益 前年度比増減率
  CASE WHEN previous_year.net_income > 0
       THEN (current_year.net_income / previous_year.net_income) - 1
  END AS net_income_growth_rate,
  -- 書類管理番号(対象年度)  
  current_year.source_document_id,
  -- 書類管理番号(基準年度)
  previous_year.source_document_id AS previous_source_document_id
 FROM public.profit AS current_year
 LEFT JOIN public.profit AS previous_year
  ON previous_year.security_code = current_year.security_code
  AND previous_year.fiscal_year = current_year.fiscal_year - 1;