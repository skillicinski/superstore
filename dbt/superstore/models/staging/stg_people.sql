
select
    $1 as "Regional Manager"
    , $2 as "Region"
from @{{ target.database }}.seeds.gcs_seeds/people.csv
(file_format => '{{ target.database }}.seeds.csv_semicolon')
