-- One row per institution per year, with codes decoded.

with source as (

    select * from {{ source('ipeds', 'hd') }}

),

renamed as (

    select
        try_cast(unitid as integer)                                   as unitid,
        try_cast(regexp_extract(filename, 'hd(\d{4})', 1) as integer) as survey_year,
        trim(instnm)                                                  as institution_name,
        trim(city)                                                    as city,
        upper(trim(stabbr))                                           as state_abbr,
        try_cast(sector as integer)                                   as sector_code,
        try_cast(control as integer)                                  as control_code,
        try_cast(iclevel as integer)                                  as level_code,
        filename                                                      as source_file

    from source

)

select
    r.unitid,
    r.survey_year,
    r.unitid::varchar || '-' || r.survey_year::varchar as institution_year_key,
    r.institution_name,
    r.city,
    r.state_abbr,
    r.sector_code,
    s.sector_name,
    case r.control_code
        when 1 then 'Public'
        when 2 then 'Private nonprofit'
        when 3 then 'Private for-profit'
        else 'Not reported'
    end as control_name,
    case r.level_code
        when 1 then '4-year or above'
        when 2 then '2-year'
        when 3 then 'Less than 2-year'
        else 'Not reported'
    end as level_name,
    r.source_file

from renamed as r
left join {{ ref('sector_codes') }} as s
    on r.sector_code = s.sector_code
