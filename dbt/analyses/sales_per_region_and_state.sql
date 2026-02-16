with sales_per_region_and_state as (
    select
        region
        , state_province
        , count(distinct order_id) as orders
        , count(distinct case when order_returned then order_id else null end) as returns
        , sum(net_sales) as net_sales
    from {{ ref('sales') }}
    where year(order_date) = 2019
    group by all
)

select
    region
    , state_province
    , orders
    , sum(orders) over (partition by region) as regional_orders
    , returns
    , sum(returns) over (partition by region) as regional_returns
    , net_sales
    , sum(net_sales) over (partition by region) as regional_net_sales
    , round(net_sales / sum(net_sales) 
        over (partition by region)
        , 2) as percent_of_regional_net_sales
from sales_per_region_and_state
order by
    net_sales desc
    , regional_net_sales desc