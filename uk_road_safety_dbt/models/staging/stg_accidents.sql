with unioned as (

    select *, '2015' as source_file_year from {{ source('uk_road_safety_raw', 'ACCIDENTS_2015') }}
    union all
    select *, '2016' as source_file_year from {{ source('uk_road_safety_raw', 'ACCIDENTS_2016') }}
    union all
    select *, '2017' as source_file_year from {{ source('uk_road_safety_raw', 'ACCIDENTS_2017') }}
    union all
    select *, '2018' as source_file_year from {{ source('uk_road_safety_raw', 'ACCIDENTS_2018') }}

),

renamed as (

    select
        -- Primary key
        "Accident_Index"::varchar                               as accident_index,

        -- Source tracking
        source_file_year::integer                               as source_year,

        -- Location
        "Location_Easting_OSGR"::integer                        as location_easting_osgr,
        "Location_Northing_OSGR"::integer                       as location_northing_osgr,
        "Longitude"::float                                      as longitude,
        "Latitude"::float                                       as latitude,
        "LSOA_of_Accident_Location"::varchar                    as lsoa_of_accident_location,

        -- Administrative
        "Police_Force"::integer                                 as police_force_code,
        "Local_Authority_(District)"::integer                   as local_authority_district_code,
        "Local_Authority_(Highway)"::varchar                    as local_authority_highway,

        -- Severity & counts
        "Accident_Severity"::integer                            as accident_severity_code,
        "Number_of_Vehicles"::integer                           as number_of_vehicles,
        "Number_of_Casualties"::integer                         as number_of_casualties,

        -- Date & time
        try_to_date("Date"::varchar, 'DD/MM/YYYY')             as accident_date,
        "Day_of_Week"::integer                                  as day_of_week_code,
        try_to_time("Time"::varchar, 'HH24:MI')                as accident_time,

        -- Road characteristics
        "1st_Road_Class"::integer                               as first_road_class_code,
        "1st_Road_Number"::integer                              as first_road_number,
        "Road_Type"::integer                                    as road_type_code,
        try_cast(nullif("Speed_limit"::varchar, 'NULL') as integer) as speed_limit,
        "2nd_Road_Class"::integer                               as second_road_class_code,
        "2nd_Road_Number"::integer                              as second_road_number,

        -- Junction
        "Junction_Detail"::integer                              as junction_detail_code,
        nullif("Junction_Control"::integer, -1)                 as junction_control_code,

        -- Pedestrian crossing
        "Pedestrian_Crossing-Human_Control"::integer            as ped_crossing_human_code,
        "Pedestrian_Crossing-Physical_Facilities"::integer      as ped_crossing_physical_code,

        -- Conditions
        "Light_Conditions"::integer                             as light_conditions_code,
        nullif("Weather_Conditions"::integer, -1)               as weather_conditions_code,
        nullif("Road_Surface_Conditions"::integer, -1)          as road_surface_conditions_code,
        nullif("Special_Conditions_at_Site"::integer, -1)       as special_conditions_code,
        nullif("Carriageway_Hazards"::integer, -1)              as carriageway_hazards_code,

        -- Area classification
        nullif("Urban_or_Rural_Area"::integer, -1)               as urban_or_rural_area_code,

        -- Police attendance
        "Did_Police_Officer_Attend_Scene_of_Accident"::integer  as police_officer_attend_code

    from unioned

)

select * from renamed
