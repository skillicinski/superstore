select
    "Order ID"
    , count(distinct "Order Date") as distinct_dates
from {{ ref('stg_orders') }}
group by "Order ID"
having distinct_dates > 1