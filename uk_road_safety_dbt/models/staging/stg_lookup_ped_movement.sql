with source as (

    select * from {{ source('uk_road_safety_raw', 'LOOKUP_PED_MOVEMENT') }}

)

select
    "code"::varchar   as code,
    "label"::varchar  as label

from source
