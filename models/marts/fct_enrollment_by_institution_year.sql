-- One row per institution per year: total, undergrad and grad headcount,
-- joined to institution attributes, with year-over-year change.
--
-- EFALEVEL codes used (confirm against the EFyyyyA data dictionary for your years):
--   1  = All students total
--   2  = All students, undergraduate total
--   12 = All students, graduate total

with enrollment as (

    select
        unitid,
        survey_year,
        max(case when student_level_code = 1  then total_enrolled end) as total_enrolled,
        max(case when student_level_code = 2  then total_enrolled end) as undergrad_enrolled,
        max(case when student_level_code = 12 then total_enrolled end) as grad_enrolled

    from {{ ref('stg_ipeds__fall_enrollment') }}
    group by unitid, survey_year

),

with_prior as (

    select
        *,
        lag(total_enrolled) over (partition by unitid order by survey_year) as prior_year_total,
        lag(survey_year)    over (partition by unitid order by survey_year) as prior_survey_year

    from enrollment

)

select
    i.institution_year_key,
    e.unitid,
    e.survey_year,
    i.institution_name,
    i.state_abbr,
    i.sector_name,
    i.control_name,
    i.level_name,
    e.total_enrolled,
    e.undergrad_enrolled,
    coalesce(e.grad_enrolled, 0) as grad_enrolled,

    -- only compare to the prior year if it really is the previous year (no gaps)
    case when e.prior_survey_year = e.survey_year - 1 then e.prior_year_total end as prior_year_total,
    case when e.prior_survey_year = e.survey_year - 1
         then e.total_enrolled - e.prior_year_total end as yoy_change,
    case when e.prior_survey_year = e.survey_year - 1 and e.prior_year_total > 0
         then round(100.0 * (e.total_enrolled - e.prior_year_total) / e.prior_year_total, 1)
    end as yoy_pct_change

from with_prior as e
inner join {{ ref('stg_ipeds__institutions') }} as i
    on  e.unitid = i.unitid
    and e.survey_year = i.survey_year
