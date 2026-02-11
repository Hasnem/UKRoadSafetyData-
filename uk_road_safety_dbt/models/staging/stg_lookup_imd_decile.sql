with source as (

    select * from {{ source('uk_road_safety_raw', 'LOOKUP_IMD_DECILE') }}

)

select
    "code"::varchar   as code,
    "label"::varchar  as label

from source
