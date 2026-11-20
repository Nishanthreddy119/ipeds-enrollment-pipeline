-- Question: which sectors grew or shrank in fall enrollment, year over year?
-- Easiest way to run it:  dbt show --profiles-dir . -s enrollment_change_by_sector --limit 50
-- Or paste it into the DuckDB CLI and swap the ref() for main_marts.fct_enrollment_by_institution_year.
--
-- Only institutions reporting in BOTH years are counted, so openings and closures
-- don't masquerade as growth or decline.

select
    sector_name,
    survey_year,
    count(*)                                   as institutions,
    sum(prior_year_total)                      as prior_year_enrollment,
    sum(total_enrolled)                        as enrollment,
    sum(total_enrolled) - sum(prior_year_total) as change,
    round(100.0 * (sum(total_enrolled) - sum(prior_year_total)) / nullif(sum(prior_year_total), 0), 1) as pct_change

from {{ ref('fct_enrollment_by_institution_year') }}
where prior_year_total is not null
group by sector_name, survey_year
order by survey_year desc, pct_change
