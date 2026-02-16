select
    date_trunc(month, order_date) as order_month
    , sum(gross_sales) as gross_sales
    , sum(returned_sales) as returned_sales
    , sum(net_sales) as net_sales
    , round(sum(gross_sales) / lag(sum(gross_sales))
        over (order by date_trunc(month, order_date))
        - 1, 2) as gross_sales_mom_change
    , round(sum(net_sales) / lag(sum(net_sales))
        over (order by date_trunc(month, order_date))
        - 1, 2) as net_sales_mom_change
from {{ ref('sales') }}
where year(order_date) = 2019
group by all
order by
    order_month asc
