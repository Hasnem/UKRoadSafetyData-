{% set years = ['2015', '2016', '2017', '2018'] %}

{% for year in years %}
{% if not loop.first %}union all{% endif %}
select
    -- Surrogate key
    "Accident_Index"::varchar || '-' || "Vehicle_Reference"::varchar
                                                            as vehicle_id,

    -- Composite key components
    "Accident_Index"::varchar                               as accident_index,
    try_cast("Vehicle_Reference"::varchar as integer)       as vehicle_reference,

    -- Source tracking
    '{{ year }}'::integer                                   as source_year,

    -- Vehicle characteristics
    try_cast("Vehicle_Type"::varchar as integer)            as vehicle_type_code,
    try_cast("Towing_and_Articulation"::varchar as integer) as towing_and_articulation_code,
    try_cast("Vehicle_Manoeuvre"::varchar as integer)        as vehicle_manoeuvre_code,
    try_cast("Vehicle_Location-Restricted_Lane"::varchar as integer)
                                                            as vehicle_location_code,
    try_cast("Junction_Location"::varchar as integer)       as junction_location_code,
    try_cast("Skidding_and_Overturning"::varchar as integer)
                                                            as skidding_and_overturning_code,

    -- Impact details
    try_cast("Hit_Object_in_Carriageway"::varchar as integer)
                                                            as hit_object_in_carriageway_code,
    try_cast("Vehicle_Leaving_Carriageway"::varchar as integer)
                                                            as vehicle_leaving_carriageway_code,
    try_cast("Hit_Object_off_Carriageway"::varchar as integer)
                                                            as hit_object_off_carriageway_code,
    try_cast("1st_Point_of_Impact"::varchar as integer)     as first_point_of_impact_code,

    -- Drive side
    try_cast("Was_Vehicle_Left_Hand_Drive?"::varchar as integer)
                                                            as was_left_hand_drive_code,

    -- Driver details
    try_cast("Journey_Purpose_of_Driver"::varchar as integer)
                                                            as journey_purpose_code,
    try_cast("Sex_of_Driver"::varchar as integer)           as sex_of_driver_code,
    nullif(try_cast("Age_of_Driver"::varchar as integer), -1)
                                                            as age_of_driver,
    nullif(try_cast("Age_Band_of_Driver"::varchar as integer), -1)
                                                            as age_band_of_driver_code,

    -- Vehicle specs
    nullif(try_cast("Engine_Capacity_(CC)"::varchar as integer), -1)
                                                            as engine_capacity_cc,
    "Propulsion_Code"::varchar                              as propulsion_code,
    nullif(try_cast("Age_of_Vehicle"::varchar as integer), -1)
                                                            as age_of_vehicle,

    -- Area / deprivation
    nullif(try_cast("Driver_IMD_Decile"::varchar as integer), -1)
                                                            as driver_imd_decile,
    nullif(try_cast("Driver_Home_Area_Type"::varchar as integer), -1)
                                                            as driver_home_area_type_code,
    nullif(try_cast("Vehicle_IMD_Decile"::varchar as integer), -1)
                                                            as vehicle_imd_decile

from {{ source('uk_road_safety_raw', 'VEHICLES_' ~ year) }}
{% endfor %}
