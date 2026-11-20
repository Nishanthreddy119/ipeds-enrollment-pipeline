-- Which institutions drove the decline in the sector that shrank?
-- Step 1 finds the sector with the lowest change; step 2 lists its biggest movers.

with sector_change as (

    select
        sector_name,
        sum(total_enrolled) - sum(prior_year_total) as change
    from {{ ref('fct_enrollment_by_institution_year') }}
    where survey_year = 2024
      and prior_year_total is not null
    group by sector_name
    order by change
    limit 1

)

select
    f.institution_name,
    f.state_abbr,
    f.sector_name,
    f.prior_year_total,
    f.total_enrolled,
    f.yoy_change,
    f.yoy_pct_change,
    -- share of the sector's net decline this one school explains
    round(100.0 * f.yoy_change / s.change, 1) as pct_of_sector_change

from {{ ref('fct_enrollment_by_institution_year') }} as f
inner join sector_change as s
    on f.sector_name = s.sector_name
where f.survey_year = 2024
  and f.prior_year_total is not null
order by f.yoy_change
