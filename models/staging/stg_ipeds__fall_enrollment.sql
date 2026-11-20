-- One row per institution per year per level of student (EFALEVEL).
-- Only the level-of-student totals are kept; race/ethnicity columns are left for later.

with source as (

    select * from {{ source('ipeds', 'ef_a') }}

)

select
    try_cast(unitid as integer)                                    as unitid,
    try_cast(regexp_extract(filename, 'ef(\d{4})a', 1) as integer) as survey_year,
    try_cast(efalevel as integer)                                  as student_level_code,
    try_cast(eftotlt as integer)                                   as total_enrolled,
    try_cast(eftotlm as integer)                                   as men_enrolled,
    try_cast(eftotlw as integer)                                   as women_enrolled,
    filename                                                       as source_file

from source
