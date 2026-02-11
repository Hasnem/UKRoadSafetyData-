{% set years = ['2015', '2016', '2017', '2018'] %}

{% for year in years %}
{% if not loop.first %}union all{% endif %}
select
    -- Surrogate key
    "Accident_Index"::varchar || '-' || "Vehicle_Reference"::varchar || '-' || "Casualty_Reference"::varchar
                                                            as casualty_id,

    -- Composite key components
    "Accident_Index"::varchar                               as accident_index,
    try_cast("Vehicle_Reference"::varchar as integer)       as vehicle_reference,
    try_cast("Casualty_Reference"::varchar as integer)      as casualty_reference,

    -- Source tracking
    '{{ year }}'::integer                                   as source_year,

    -- Casualty classification
    try_cast("Casualty_Class"::varchar as integer)          as casualty_class_code,
    try_cast("Sex_of_Casualty"::varchar as integer)         as sex_of_casualty_code,
    try_cast("Age_of_Casualty"::varchar as integer)         as age_of_casualty,
    try_cast("Age_Band_of_Casualty"::varchar as integer)    as age_band_of_casualty_code,
    try_cast("Casualty_Severity"::varchar as integer)       as casualty_severity_code,

    -- Pedestrian details
    try_cast("Pedestrian_Location"::varchar as integer)     as pedestrian_location_code,
    try_cast("Pedestrian_Movement"::varchar as integer)     as pedestrian_movement_code,

    -- Passenger details
    try_cast("Car_Passenger"::varchar as integer)           as car_passenger_code,
    try_cast("Bus_or_Coach_Passenger"::varchar as integer)  as bus_or_coach_passenger_code,
    try_cast("Pedestrian_Road_Maintenance_Worker"::varchar as integer)
                                                            as ped_road_maintenance_worker_code,

    -- Type and area
    try_cast("Casualty_Type"::varchar as integer)           as casualty_type_code,
    nullif(try_cast("Casualty_Home_Area_Type"::varchar as integer), -1)
                                                            as casualty_home_area_type_code,
    nullif(try_cast("Casualty_IMD_Decile"::varchar as integer), -1)
                                                            as casualty_imd_decile

from {{ source('uk_road_safety_raw', 'CASUALTIES_' ~ year) }}
{% endfor %}
