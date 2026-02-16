with expected as (
    select
        "Order ID" as order_id
        , "Product ID" as product_id
        , sum(round(cast(replace("Sales", ',', '.') as number(10, 2)), 2)) as gross_sales
        , sum(cast("Quantity" as int)) as quantity_sold
        , sum(round(cast(replace("Profit", ',', '.') as number(10, 2)), 2)) as profit
    from {{ ref('stg_orders') }}
    group by all
)

, actual as (
    select
        order_id
        , product_id
        , gross_sales
        , quantity_sold
        , profit
    from {{ ref('sales') }}
)

select
    e.order_id
    , e.product_id
    , e.gross_sales as expected_gross_sales
    , a.gross_sales as actual_gross_sales
    , e.quantity_sold as expected_quantity_sold
    , a.quantity_sold as actual_quantity_sold
    , e.profit as expected_profit
    , a.profit as actual_profit
from expected e
join actual a
    on e.order_id = a.order_id
    and e.product_id = a.product_id
where e.gross_sales != a.gross_sales
    or e.quantity_sold != a.quantity_sold
    or e.profit != a.profit