with sales_per_product_category as (
    select
        date_trunc(month, order_date) as order_month
        , product_category
        , sum(gross_sales) as gross_sales
        , sum(net_sales) as net_sales
    from {{ ref('sales') }}
    where year(order_date) = 2019
    group by all
)

, monthly_totals as (
    select
        order_month
        , sum(gross_sales) as total_gross_sales
        , round(sum(gross_sales) / lag(sum(gross_sales)) over (order by order_month) - 1, 2) as gross_sales_mom_change
        , sum(net_sales) as total_net_sales
        , round(sum(net_sales) / lag(sum(net_sales)) over (order by order_month) - 1, 2) as net_sales_mom_change
    from sales_per_product_category
    group by order_month
)

select
    s.order_month
    , s.product_category
    , s.gross_sales
    , round(s.gross_sales / lag(s.gross_sales)
        over (partition by s.product_category order by s.order_month)
        - 1, 2) as category_gross_sales_mom_change
    , s.net_sales
    , round(s.net_sales / lag(s.net_sales)
        over (partition by s.product_category order by s.order_month)
        - 1, 2) as category_net_sales_mom_change
    , m.total_gross_sales
    , m.gross_sales_mom_change
    , m.total_net_sales
    , m.net_sales_mom_change
from sales_per_product_category s
join monthly_totals m on s.order_month = m.order_month
order by
    s.order_month asc
    , s.product_category asc
