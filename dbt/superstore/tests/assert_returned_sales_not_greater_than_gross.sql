select *
from {{ ref('sales') }}
where returned_sales > gross_sales