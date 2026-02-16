{{ config(materialized='table') }}


with orders as (
    select
        "Row ID" as row_id
        , "Order ID" as order_id
        , date_from_parts(
            regexp_substr("Order ID", '[A-Z]{2}-(\\d{4})', 1, 1, 'e', 1)
            , regexp_substr("Order Date", '\\d+')
            , 1) as order_date
        , date_from_parts(
            regexp_substr("Order ID", '[A-Z]{2}-(\\d{4})', 1, 1, 'e', 1)
            , regexp_substr("Ship Date", '\\d+')
            , 1) as ship_date
        , "State/Province" as state_province
        , "Region" as region
        , "Product ID" as product_id
        , "Category" as product_category
        , cast(replace("Sales", ',', '.') as number(10, 2)) as gross_sales
        , cast("Quantity" as int) as quantity_sold
        , cast(replace("Discount", ',', '.') as number(10, 2)) as discount_percentage
        , cast(replace("Profit", ',', '.') as number(10, 2)) as profit
    from {{ ref('stg_orders') }} o
)

, returns as (
    select
        "Order ID" as order_id
        , true as order_returned
    from {{ ref('stg_returns') }}
    group by "Order ID"
)

, people as (
    select
        "Region" as region
        , "Regional Manager" as regional_manager
    from {{ ref('stg_people') }}
)


, sales_with_returns as (
    select
        o.row_id
        , o.order_id
        , min(o.order_date) over (partition by o.order_id) as order_date
        , min(o.ship_date) over (partition by o.order_id) as ship_date
        , coalesce(r.order_returned, false) as order_returned
        , o.region
        , o.state_province
        , p.regional_manager
        , o.product_id
        , o.product_category
        , round(o.gross_sales, 2) as gross_sales
        , o.quantity_sold
        , round(o.gross_sales * o.discount_percentage, 2) as discounted_sales
        , round(o.profit, 2) as profit
        , coalesce(
            case when r.order_returned 
            then round(o.gross_sales * (1 - o.discount_percentage), 2)
            end, 0) as returned_sales
    from orders o
    left join returns r 
        on o.order_id = r.order_id
    left join people p
        on lower(o.region) = lower(p.region)
)

select
    order_date
    , ship_date
    , order_id
    , boolor_agg(order_returned) as order_returned
    , region
    , state_province
    , regional_manager
    , product_id
    , product_category
    , sum(gross_sales) as gross_sales
    , sum(quantity_sold) as quantity_sold
    , sum(discounted_sales) as discounted_sales
    , sum(returned_sales) as returned_sales
    , round(sum(gross_sales) - sum(discounted_sales) - sum(returned_sales), 2) as net_sales
    , round(sum(profit), 2) as profit
    , round(sum(gross_sales) - sum(discounted_sales) - sum(profit), 2) as cost_of_goods_sold
from sales_with_returns
group by all