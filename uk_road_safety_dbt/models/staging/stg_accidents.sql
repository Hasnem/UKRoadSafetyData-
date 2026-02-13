{% set years = ['2015', '2016', '2017', '2018'] %}

{% for year in years %}
{% if not loop.first %}union all{% endif %}
select
    -- Primary key
    "Accident_Index"::varchar                               as accident_index,

    -- Source tracking
    '{{ year }}'::integer                                   as source_year,

    -- Location
    try_cast("Location_Easting_OSGR"::varchar as integer)  as location_easting_osgr,
    try_cast("Location_Northing_OSGR"::varchar as integer) as location_northing_osgr,
    try_cast("Longitude"::varchar as float)                 as longitude,
    try_cast("Latitude"::varchar as float)                  as latitude,
    "LSOA_of_Accident_Location"::varchar                    as lsoa_of_accident_location,

    -- Administrative
    try_cast("Police_Force"::varchar as integer)            as police_force_code,
    try_cast("Local_Authority_(District)"::varchar as integer)
                                                            as local_authority_district_code,
    "Local_Authority_(Highway)"::varchar                    as local_authority_highway,

    -- Severity & counts
    try_cast("Accident_Severity"::varchar as integer)       as accident_severity_code,
    try_cast("Number_of_Vehicles"::varchar as integer)      as number_of_vehicles,
    try_cast("Number_of_Casualties"::varchar as integer)    as number_of_casualties,

    -- Date & time
    try_to_date("Date"::varchar, 'DD/MM/YYYY')             as accident_date,
    try_cast("Day_of_Week"::varchar as integer)             as day_of_week_code,
    "Time"::time                                             as accident_time,

    -- Road characteristics
    try_cast("1st_Road_Class"::varchar as integer)          as first_road_class_code,
    try_cast("1st_Road_Number"::varchar as integer)         as first_road_number,
    try_cast("Road_Type"::varchar as integer)               as road_type_code,
    try_cast(nullif("Speed_limit"::varchar, 'NULL') as integer) as speed_limit,
    try_cast("2nd_Road_Class"::varchar as integer)          as second_road_class_code,
    try_cast("2nd_Road_Number"::varchar as integer)         as second_road_number,

    -- Junction
    try_cast("Junction_Detail"::varchar as integer)         as junction_detail_code,
    nullif(try_cast("Junction_Control"::varchar as integer), -1)
                                                            as junction_control_code,

    -- Pedestrian crossing
    try_cast("Pedestrian_Crossing-Human_Control"::varchar as integer)
                                                            as ped_crossing_human_code,
    try_cast("Pedestrian_Crossing-Physical_Facilities"::varchar as integer)
                                                            as ped_crossing_physical_code,

    -- Conditions
    try_cast("Light_Conditions"::varchar as integer)        as light_conditions_code,
    nullif(try_cast("Weather_Conditions"::varchar as integer), -1)
                                                            as weather_conditions_code,
    nullif(try_cast("Road_Surface_Conditions"::varchar as integer), -1)
                                                            as road_surface_conditions_code,
    nullif(try_cast("Special_Conditions_at_Site"::varchar as integer), -1)
                                                            as special_conditions_code,
    nullif(try_cast("Carriageway_Hazards"::varchar as integer), -1)
                                                            as carriageway_hazards_code,

    -- Area classification
    nullif(try_cast("Urban_or_Rural_Area"::varchar as integer), -1)
                                                            as urban_or_rural_area_code,

    -- Police attendance
    try_cast("Did_Police_Officer_Attend_Scene_of_Accident"::varchar as integer)
                                                            as police_officer_attend_code

from {{ source('uk_road_safety_raw', 'ACCIDENTS_' ~ year) }}
{% endfor %}
