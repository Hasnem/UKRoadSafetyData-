with unioned as (

    select *, '2015' as source_file_year from {{ source('uk_road_safety_raw', 'CASUALTIES_2015') }}
    union all
    select *, '2016' as source_file_year from {{ source('uk_road_safety_raw', 'CASUALTIES_2016') }}
    union all
    select *, '2017' as source_file_year from {{ source('uk_road_safety_raw', 'CASUALTIES_2017') }}
    union all
    select *, '2018' as source_file_year from {{ source('uk_road_safety_raw', 'CASUALTIES_2018') }}

),

renamed as (

    select
        -- Surrogate key
        "Accident_Index"::varchar || '-' || "Vehicle_Reference"::varchar || '-' || "Casualty_Reference"::varchar
                                                                as casualty_id,

        -- Composite key components
        "Accident_Index"::varchar                               as accident_index,
        "Vehicle_Reference"::integer                            as vehicle_reference,
        "Casualty_Reference"::integer                           as casualty_reference,

        -- Source tracking
        source_file_year::integer                               as source_year,

        -- Casualty classification
        "Casualty_Class"::integer                               as casualty_class_code,
        "Sex_of_Casualty"::integer                              as sex_of_casualty_code,
        "Age_of_Casualty"::integer                              as age_of_casualty,
        "Age_Band_of_Casualty"::integer                         as age_band_of_casualty_code,
        "Casualty_Severity"::integer                            as casualty_severity_code,

        -- Pedestrian details
        "Pedestrian_Location"::integer                          as pedestrian_location_code,
        "Pedestrian_Movement"::integer                          as pedestrian_movement_code,

        -- Passenger details
        "Car_Passenger"::integer                                as car_passenger_code,
        "Bus_or_Coach_Passenger"::integer                       as bus_or_coach_passenger_code,
        "Pedestrian_Road_Maintenance_Worker"::integer           as ped_road_maintenance_worker_code,

        -- Type and area
        "Casualty_Type"::integer                                as casualty_type_code,
        nullif("Casualty_Home_Area_Type"::integer, -1)          as casualty_home_area_type_code,
        nullif("Casualty_IMD_Decile"::integer, -1)              as casualty_imd_decile

    from unioned

)

select * from renamed
