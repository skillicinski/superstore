select
    date_trunc(year, order_date) as order_year
    , product_category
    , count(distinct order_id) as orders
    , count(distinct case when order_returned then order_id end) as returns
    , sum(gross_sales) as gross_sales
    , sum(returned_sales) as returned_sales
    , sum(net_sales) as net_sales
    , round(div0null(sum(profit), sum(gross_sales)), 2) as profit_margin
    , sum(cost_of_goods_sold) as cost_of_goods_sold
from {{ ref('sales') }}
group by all
order by 
    order_year asc
    , net_sales desc
