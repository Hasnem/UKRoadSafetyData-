with source as (

    select * from {{ source('uk_road_safety_raw', 'LOOKUP_SECOND_ROAD_CLASS') }}

)

select
    "code"::varchar   as code,
    "label"::varchar  as label

from source
