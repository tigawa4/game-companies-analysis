-- 損益計算書の項目を円単位で格納するテーブル
CREATE TABLE public.profit (
 -- 証券コード
 security_code text NOT NULL,
 -- 企業
 company_name text NOT NULL,
 -- 会計年度
 fiscal_year integer NOT NULL,
 -- 期首日
 period_start date NOT NULL,
 -- 期末日
 period_end date NOT NULL,
 -- 売上高
 revenue numeric,
 -- 売上原価
 cost_of_sales numeric,
 -- 売上総利益
 gross_profit numeric,
 -- 販売費及び一般管理費
 selling_general_and_administrative_expenses numeric,
 -- 営業利益
 operating_profit numeric,
 -- 営業外収益
 non_operating_income numeric,
 -- 営業外費用
 non_operating_expenses numeric,
 -- 経常利益
 ordinary_profit numeric,
 -- 特別利益
 extraordinary_income numeric,
 -- 特別損失
 extraordinary_loss numeric,
 -- 税引前当期純利益
 profit_before_tax numeric,
 -- 法人税等
 income_taxes numeric,
 -- 当期純利益
 net_income numeric,
 -- 書類管理番号
 source_document_id text NOT NULL REFERENCES public.documents(document_id),
 
 PRIMARY KEY(security_code, fiscal_year),
 
 CHECK(period_start <= period_end)
);