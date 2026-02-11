with source as (

    select * from {{ source('uk_road_safety_raw', 'LOOKUP_PROPULSION_CODE') }}

)

select
    "code"::varchar   as code,
    "label"::varchar  as label

from source
