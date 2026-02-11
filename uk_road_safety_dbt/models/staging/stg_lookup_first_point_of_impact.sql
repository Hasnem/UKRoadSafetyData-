with source as (

    select * from {{ source('uk_road_safety_raw', 'LOOKUP_FIRST_POINT_OF_IMPACT') }}

)

select
    "code"::varchar   as code,
    "label"::varchar  as label

from source
