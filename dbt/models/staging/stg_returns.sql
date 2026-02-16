
select
    $1 as "Returned"
    , $2 as "Order ID"
from @{{ target.database }}.seeds.gcs_seeds/returns.csv
(file_format => '{{ target.database }}.seeds.csv_semicolon')
