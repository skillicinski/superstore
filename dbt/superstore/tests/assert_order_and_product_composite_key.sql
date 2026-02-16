select 
    order_id
    , product_id
    , count(*) as record_count
from {{ ref('sales') }}
group by
    order_id
    , product_id
having count(*) > 1