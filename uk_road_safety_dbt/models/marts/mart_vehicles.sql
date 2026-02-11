with vehicles as (

    select * from {{ ref('stg_vehicles') }}

),

accidents as (

    select * from {{ ref('stg_accidents') }}

),

-- Vehicle lookup tables
lkp_vehicle_type              as (select * from {{ ref('stg_lookup_vehicle_type') }}),
lkp_vehicle_manoeuvre         as (select * from {{ ref('stg_lookup_vehicle_manoeuvre') }}),
lkp_towing_articulation       as (select * from {{ ref('stg_lookup_towing_articulation') }}),
lkp_vehicle_location          as (select * from {{ ref('stg_lookup_vehicle_location') }}),
lkp_junction_location         as (select * from {{ ref('stg_lookup_junction_location') }}),
lkp_skidding_overturning      as (select * from {{ ref('stg_lookup_skidding_overturning') }}),
lkp_hit_object_carriageway    as (select * from {{ ref('stg_lookup_hit_object_carriageway') }}),
lkp_vehicle_leaving_carriageway as (select * from {{ ref('stg_lookup_vehicle_leaving_carriageway') }}),
lkp_hit_object_off_carriageway as (select * from {{ ref('stg_lookup_hit_object_off_carriageway') }}),
lkp_first_point_of_impact     as (select * from {{ ref('stg_lookup_first_point_of_impact') }}),
lkp_left_hand_drive           as (select * from {{ ref('stg_lookup_left_hand_drive') }}),
lkp_journey_purpose           as (select * from {{ ref('stg_lookup_journey_purpose') }}),
lkp_sex_of_driver             as (select * from {{ ref('stg_lookup_sex_of_driver') }}),
lkp_age_band                  as (select * from {{ ref('stg_lookup_age_band') }}),
lkp_propulsion_code           as (select * from {{ ref('stg_lookup_propulsion_code') }}),
lkp_home_area_type            as (select * from {{ ref('stg_lookup_home_area_type') }}),

-- Accident context lookup tables
lkp_accident_severity         as (select * from {{ ref('stg_lookup_accident_severity') }}),
lkp_police_force              as (select * from {{ ref('stg_lookup_police_force') }}),
lkp_local_authority_district  as (select * from {{ ref('stg_lookup_local_authority_district') }}),
lkp_road_type                 as (select * from {{ ref('stg_lookup_road_type') }}),
lkp_light_conditions          as (select * from {{ ref('stg_lookup_light_conditions') }}),
lkp_weather_conditions        as (select * from {{ ref('stg_lookup_weather_conditions') }}),
lkp_urban_rural               as (select * from {{ ref('stg_lookup_urban_rural') }})

select
    -- Primary key
    v.vehicle_id,

    -- Foreign keys
    v.accident_index,
    v.vehicle_reference,

    -- Vehicle characteristics
    v.vehicle_type_code,
    lkp_vt.label                                        as vehicle_type,
    v.vehicle_manoeuvre_code,
    lkp_vm.label                                        as vehicle_manoeuvre,
    v.towing_and_articulation_code,
    lkp_ta.label                                        as towing_and_articulation,
    v.vehicle_location_code,
    lkp_vl.label                                        as vehicle_location,
    v.junction_location_code,
    lkp_jl.label                                        as junction_location,
    v.skidding_and_overturning_code,
    lkp_so.label                                        as skidding_and_overturning,

    -- Impact details
    v.hit_object_in_carriageway_code,
    lkp_hoc.label                                       as hit_object_in_carriageway,
    v.vehicle_leaving_carriageway_code,
    lkp_vlc.label                                       as vehicle_leaving_carriageway,
    v.hit_object_off_carriageway_code,
    lkp_hooc.label                                      as hit_object_off_carriageway,
    v.first_point_of_impact_code,
    lkp_fpi.label                                       as first_point_of_impact,

    -- Drive side
    v.was_left_hand_drive_code,
    lkp_lhd.label                                       as was_left_hand_drive,

    -- Driver details
    v.journey_purpose_code,
    lkp_jp.label                                        as journey_purpose,
    v.sex_of_driver_code,
    lkp_sd.label                                        as sex_of_driver,
    v.age_of_driver,
    v.age_band_of_driver_code,
    lkp_ab.label                                        as age_band_of_driver,

    -- Vehicle specs
    v.engine_capacity_cc,
    v.propulsion_code,
    lkp_pc.label                                        as propulsion,
    v.age_of_vehicle,

    -- Area / deprivation
    v.driver_imd_decile,
    v.driver_home_area_type_code,
    lkp_hat.label                                       as driver_home_area_type,
    v.vehicle_imd_decile,

    -- Accident context (denormalized)
    a.accident_date,
    extract(year from a.accident_date)                  as accident_year,
    a.accident_time,
    a.accident_severity_code,
    lkp_as.label                                        as accident_severity,
    a.latitude,
    a.longitude,
    lkp_pf.label                                        as police_force,
    lkp_lad.label                                       as local_authority_district,
    lkp_rt.label                                        as road_type,
    a.speed_limit,
    lkp_lc.label                                        as light_conditions,
    lkp_wc.label                                        as weather_conditions,
    lkp_ur.label                                        as urban_or_rural_area

from vehicles v

-- Join accident context
left join accidents a on v.accident_index = a.accident_index

-- Vehicle lookups
left join lkp_vehicle_type              lkp_vt   on v.vehicle_type_code::varchar                = lkp_vt.code
left join lkp_vehicle_manoeuvre         lkp_vm   on v.vehicle_manoeuvre_code::varchar            = lkp_vm.code
left join lkp_towing_articulation       lkp_ta   on v.towing_and_articulation_code::varchar     = lkp_ta.code
left join lkp_vehicle_location          lkp_vl   on v.vehicle_location_code::varchar            = lkp_vl.code
left join lkp_junction_location         lkp_jl   on v.junction_location_code::varchar           = lkp_jl.code
left join lkp_skidding_overturning      lkp_so   on v.skidding_and_overturning_code::varchar    = lkp_so.code
left join lkp_hit_object_carriageway    lkp_hoc  on v.hit_object_in_carriageway_code::varchar   = lkp_hoc.code
left join lkp_vehicle_leaving_carriageway lkp_vlc on v.vehicle_leaving_carriageway_code::varchar = lkp_vlc.code
left join lkp_hit_object_off_carriageway lkp_hooc on v.hit_object_off_carriageway_code::varchar = lkp_hooc.code
left join lkp_first_point_of_impact     lkp_fpi  on v.first_point_of_impact_code::varchar       = lkp_fpi.code
left join lkp_left_hand_drive           lkp_lhd  on v.was_left_hand_drive_code::varchar         = lkp_lhd.code
left join lkp_journey_purpose           lkp_jp   on v.journey_purpose_code::varchar              = lkp_jp.code
left join lkp_sex_of_driver             lkp_sd   on v.sex_of_driver_code::varchar                = lkp_sd.code
left join lkp_age_band                  lkp_ab   on v.age_band_of_driver_code::varchar           = lkp_ab.code
left join lkp_propulsion_code           lkp_pc   on v.propulsion_code::varchar                   = lkp_pc.code
left join lkp_home_area_type            lkp_hat  on v.driver_home_area_type_code::varchar        = lkp_hat.code

-- Accident context lookups
left join lkp_accident_severity         lkp_as   on a.accident_severity_code::varchar            = lkp_as.code
left join lkp_police_force              lkp_pf   on a.police_force_code::varchar                 = lkp_pf.code
left join lkp_local_authority_district  lkp_lad  on a.local_authority_district_code::varchar     = lkp_lad.code
left join lkp_road_type                 lkp_rt   on a.road_type_code::varchar                    = lkp_rt.code
left join lkp_light_conditions          lkp_lc   on a.light_conditions_code::varchar             = lkp_lc.code
left join lkp_weather_conditions        lkp_wc   on a.weather_conditions_code::varchar           = lkp_wc.code
left join lkp_urban_rural               lkp_ur   on a.urban_or_rural_area_code::varchar          = lkp_ur.code
