with unioned as (

    select *, '2015' as source_file_year from {{ source('uk_road_safety_raw', 'VEHICLES_2015') }}
    union all
    select *, '2016' as source_file_year from {{ source('uk_road_safety_raw', 'VEHICLES_2016') }}
    union all
    select *, '2017' as source_file_year from {{ source('uk_road_safety_raw', 'VEHICLES_2017') }}
    union all
    select *, '2018' as source_file_year from {{ source('uk_road_safety_raw', 'VEHICLES_2018') }}

),

renamed as (

    select
        -- Surrogate key
        "Accident_Index"::varchar || '-' || "Vehicle_Reference"::varchar
                                                                as vehicle_id,

        -- Composite key components
        "Accident_Index"::varchar                               as accident_index,
        "Vehicle_Reference"::integer                            as vehicle_reference,

        -- Source tracking
        source_file_year::integer                               as source_year,

        -- Vehicle characteristics
        "Vehicle_Type"::integer                                 as vehicle_type_code,
        "Towing_and_Articulation"::integer                      as towing_and_articulation_code,
        "Vehicle_Manoeuvre"::integer                             as vehicle_manoeuvre_code,
        "Vehicle_Location-Restricted_Lane"::integer             as vehicle_location_code,
        "Junction_Location"::integer                            as junction_location_code,
        "Skidding_and_Overturning"::integer                     as skidding_and_overturning_code,

        -- Impact details
        "Hit_Object_in_Carriageway"::integer                    as hit_object_in_carriageway_code,
        "Vehicle_Leaving_Carriageway"::integer                  as vehicle_leaving_carriageway_code,
        "Hit_Object_off_Carriageway"::integer                   as hit_object_off_carriageway_code,
        "1st_Point_of_Impact"::integer                          as first_point_of_impact_code,

        -- Drive side
        "Was_Vehicle_Left_Hand_Drive?"::integer                 as was_left_hand_drive_code,

        -- Driver details
        "Journey_Purpose_of_Driver"::integer                    as journey_purpose_code,
        "Sex_of_Driver"::integer                                as sex_of_driver_code,
        nullif("Age_of_Driver"::integer, -1)                    as age_of_driver,
        nullif("Age_Band_of_Driver"::integer, -1)               as age_band_of_driver_code,

        -- Vehicle specs
        nullif("Engine_Capacity_(CC)"::integer, -1)             as engine_capacity_cc,
        "Propulsion_Code"::varchar                              as propulsion_code,
        nullif("Age_of_Vehicle"::integer, -1)                   as age_of_vehicle,

        -- Area / deprivation
        nullif("Driver_IMD_Decile"::integer, -1)                as driver_imd_decile,
        nullif("Driver_Home_Area_Type"::integer, -1)            as driver_home_area_type_code,
        nullif("Vehicle_IMD_Decile"::integer, -1)               as vehicle_imd_decile

    from unioned

)

select * from renamed
