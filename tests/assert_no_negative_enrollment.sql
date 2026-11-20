-- Headcounts can never be negative.

select *
from {{ ref('stg_ipeds__fall_enrollment') }}
where total_enrolled < 0
   or men_enrolled < 0
   or women_enrolled < 0
