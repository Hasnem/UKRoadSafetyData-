with casualties as (

    select * from {{ ref('stg_casualties') }}

),

accidents as (

    select * from {{ ref('stg_accidents') }}

),

vehicles as (

    select * from {{ ref('stg_vehicles') }}

),

-- Casualty lookup tables
lkp_casualty_class      as (select * from {{ ref('stg_lookup_casualty_class') }}),
lkp_casualty_severity   as (select * from {{ ref('stg_lookup_casualty_severity') }}),
lkp_casualty_type       as (select * from {{ ref('stg_lookup_casualty_type') }}),
lkp_sex_of_casualty     as (select * from {{ ref('stg_lookup_sex_of_casualty') }}),
lkp_age_band            as (select * from {{ ref('stg_lookup_age_band') }}),
lkp_ped_location        as (select * from {{ ref('stg_lookup_ped_location') }}),
lkp_ped_movement        as (select * from {{ ref('stg_lookup_ped_movement') }}),
lkp_car_passenger       as (select * from {{ ref('stg_lookup_car_passenger') }}),
lkp_bus_passenger       as (select * from {{ ref('stg_lookup_bus_passenger') }}),
lkp_ped_road_maintenance as (select * from {{ ref('stg_lookup_ped_road_maintenance') }}),
lkp_home_area_type      as (select * from {{ ref('stg_lookup_home_area_type') }}),

-- Accident context lookup tables
lkp_accident_severity   as (select * from {{ ref('stg_lookup_accident_severity') }}),
lkp_police_force        as (select * from {{ ref('stg_lookup_police_force') }}),
lkp_local_authority_district as (select * from {{ ref('stg_lookup_local_authority_district') }}),
lkp_road_type           as (select * from {{ ref('stg_lookup_road_type') }}),
lkp_light_conditions    as (select * from {{ ref('stg_lookup_light_conditions') }}),
lkp_weather_conditions  as (select * from {{ ref('stg_lookup_weather_conditions') }}),
lkp_urban_rural         as (select * from {{ ref('stg_lookup_urban_rural') }}),

-- Vehicle lookup
lkp_vehicle_type        as (select * from {{ ref('stg_lookup_vehicle_type') }})

select
    -- Primary key
    c.casualty_id,

    -- Foreign keys
    c.accident_index,
    c.vehicle_reference,
    c.casualty_reference,

    -- Casualty classification
    c.casualty_class_code,
    lkp_cc.label                                        as casualty_class,
    c.casualty_severity_code,
    lkp_cs.label                                        as casualty_severity,
    c.casualty_type_code,
    lkp_ct.label                                        as casualty_type,

    -- Demographics
    c.sex_of_casualty_code,
    lkp_sc.label                                        as sex_of_casualty,
    c.age_of_casualty,
    c.age_band_of_casualty_code,
    lkp_ab.label                                        as age_band_of_casualty,

    -- Pedestrian details
    c.pedestrian_location_code,
    lkp_pl.label                                        as pedestrian_location,
    c.pedestrian_movement_code,
    lkp_pm.label                                        as pedestrian_movement,

    -- Passenger details
    c.car_passenger_code,
    lkp_cp.label                                        as car_passenger,
    c.bus_or_coach_passenger_code,
    lkp_bp.label                                        as bus_or_coach_passenger,
    c.ped_road_maintenance_worker_code,
    lkp_prm.label                                       as ped_road_maintenance_worker,

    -- Area / deprivation
    c.casualty_home_area_type_code,
    lkp_hat.label                                       as casualty_home_area_type,
    c.casualty_imd_decile,

    -- Vehicle context (denormalized)
    v.vehicle_type_code,
    lkp_vt.label                                        as vehicle_type,

    -- Accident context (denormalized)
    a.accident_date,
    extract(year from a.accident_date)                  as accident_year,
    a.accident_time,
    a.accident_severity_code                            as accident_severity_code,
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

from casualties c

-- Join accident context
left join accidents a on c.accident_index = a.accident_index

-- Join vehicle context
left join vehicles v
    on  c.accident_index    = v.accident_index
    and c.vehicle_reference = v.vehicle_reference

-- Casualty lookups
left join lkp_casualty_class      lkp_cc  on c.casualty_class_code::varchar              = lkp_cc.code
left join lkp_casualty_severity   lkp_cs  on c.casualty_severity_code::varchar            = lkp_cs.code
left join lkp_casualty_type       lkp_ct  on c.casualty_type_code::varchar                = lkp_ct.code
left join lkp_sex_of_casualty     lkp_sc  on c.sex_of_casualty_code::varchar              = lkp_sc.code
left join lkp_age_band            lkp_ab  on c.age_band_of_casualty_code::varchar         = lkp_ab.code
left join lkp_ped_location        lkp_pl  on c.pedestrian_location_code::varchar          = lkp_pl.code
left join lkp_ped_movement        lkp_pm  on c.pedestrian_movement_code::varchar          = lkp_pm.code
left join lkp_car_passenger       lkp_cp  on c.car_passenger_code::varchar                = lkp_cp.code
left join lkp_bus_passenger       lkp_bp  on c.bus_or_coach_passenger_code::varchar       = lkp_bp.code
left join lkp_ped_road_maintenance lkp_prm on c.ped_road_maintenance_worker_code::varchar = lkp_prm.code
left join lkp_home_area_type      lkp_hat on c.casualty_home_area_type_code::varchar      = lkp_hat.code

-- Vehicle type lookup
left join lkp_vehicle_type        lkp_vt  on v.vehicle_type_code::varchar                 = lkp_vt.code

-- Accident context lookups
left join lkp_accident_severity   lkp_as  on a.accident_severity_code::varchar            = lkp_as.code
left join lkp_police_force        lkp_pf  on a.police_force_code::varchar                 = lkp_pf.code
left join lkp_local_authority_district lkp_lad on a.local_authority_district_code::varchar = lkp_lad.code
left join lkp_road_type           lkp_rt  on a.road_type_code::varchar                    = lkp_rt.code
left join lkp_light_conditions    lkp_lc  on a.light_conditions_code::varchar             = lkp_lc.code
left join lkp_weather_conditions  lkp_wc  on a.weather_conditions_code::varchar           = lkp_wc.code
left join lkp_urban_rural         lkp_ur  on a.urban_or_rural_area_code::varchar          = lkp_ur.code
