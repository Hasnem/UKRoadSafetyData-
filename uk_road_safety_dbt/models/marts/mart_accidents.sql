with accidents as (

    select * from {{ ref('stg_accidents') }}

),

-- Lookup tables
lkp_police_force            as (select * from {{ ref('stg_lookup_police_force') }}),
lkp_local_authority_district as (select * from {{ ref('stg_lookup_local_authority_district') }}),
lkp_accident_severity       as (select * from {{ ref('stg_lookup_accident_severity') }}),
lkp_day_of_week             as (select * from {{ ref('stg_lookup_day_of_week') }}),
lkp_first_road_class        as (select * from {{ ref('stg_lookup_road_class') }}),
lkp_road_type               as (select * from {{ ref('stg_lookup_road_type') }}),
lkp_second_road_class       as (select * from {{ ref('stg_lookup_second_road_class') }}),
lkp_junction_detail         as (select * from {{ ref('stg_lookup_junction_detail') }}),
lkp_junction_control        as (select * from {{ ref('stg_lookup_junction_control') }}),
lkp_ped_crossing_human      as (select * from {{ ref('stg_lookup_ped_crossing_human') }}),
lkp_ped_crossing_physical   as (select * from {{ ref('stg_lookup_ped_crossing_physical') }}),
lkp_light_conditions        as (select * from {{ ref('stg_lookup_light_conditions') }}),
lkp_weather_conditions      as (select * from {{ ref('stg_lookup_weather_conditions') }}),
lkp_road_surface            as (select * from {{ ref('stg_lookup_road_surface') }}),
lkp_special_conditions      as (select * from {{ ref('stg_lookup_special_conditions') }}),
lkp_carriageway_hazards     as (select * from {{ ref('stg_lookup_carriageway_hazards') }}),
lkp_urban_rural             as (select * from {{ ref('stg_lookup_urban_rural') }}),
lkp_police_officer_attend   as (select * from {{ ref('stg_lookup_police_officer_attend') }})

select
    -- Primary key
    a.accident_index,

    -- Source tracking
    a.source_year,

    -- Location
    a.latitude,
    a.longitude,
    a.location_easting_osgr,
    a.location_northing_osgr,
    a.lsoa_of_accident_location,

    -- Administrative
    a.police_force_code,
    lkp_pf.label                                        as police_force,
    a.local_authority_district_code,
    lkp_lad.label                                       as local_authority_district,
    a.local_authority_highway,

    -- Severity & counts
    a.accident_severity_code,
    lkp_sev.label                                       as accident_severity,
    a.number_of_vehicles,
    a.number_of_casualties,

    -- Date & time
    a.accident_date,
    extract(year from a.accident_date)                  as accident_year,
    extract(month from a.accident_date)                 as accident_month,
    a.accident_time,
    a.day_of_week_code,
    lkp_dow.label                                       as day_of_week,

    -- Road characteristics
    a.first_road_class_code,
    lkp_frc.label                                       as first_road_class,
    a.first_road_number,
    a.road_type_code,
    lkp_rt.label                                        as road_type,
    a.speed_limit,
    a.second_road_class_code,
    lkp_src.label                                       as second_road_class,
    a.second_road_number,

    -- Junction
    a.junction_detail_code,
    lkp_jd.label                                        as junction_detail,
    a.junction_control_code,
    lkp_jc.label                                        as junction_control,

    -- Pedestrian crossing
    a.ped_crossing_human_code,
    lkp_pch.label                                       as ped_crossing_human,
    a.ped_crossing_physical_code,
    lkp_pcp.label                                       as ped_crossing_physical,

    -- Conditions
    a.light_conditions_code,
    lkp_lc.label                                        as light_conditions,
    a.weather_conditions_code,
    lkp_wc.label                                        as weather_conditions,
    a.road_surface_conditions_code,
    lkp_rs.label                                        as road_surface_conditions,
    a.special_conditions_code,
    lkp_sc.label                                        as special_conditions,
    a.carriageway_hazards_code,
    lkp_ch.label                                        as carriageway_hazards,

    -- Area classification
    a.urban_or_rural_area_code,
    lkp_ur.label                                        as urban_or_rural_area,

    -- Police attendance
    a.police_officer_attend_code,
    lkp_poa.label                                       as police_officer_attend,

    -- Derived columns
    case when a.accident_severity_code = 1 then true else false end
                                                        as is_fatal,
    case when a.day_of_week_code in (1, 7) then true else false end
                                                        as is_weekend

from accidents a

left join lkp_police_force            lkp_pf  on a.police_force_code::varchar              = lkp_pf.code
left join lkp_local_authority_district lkp_lad on a.local_authority_district_code::varchar   = lkp_lad.code
left join lkp_accident_severity       lkp_sev on a.accident_severity_code::varchar          = lkp_sev.code
left join lkp_day_of_week             lkp_dow on a.day_of_week_code::varchar                = lkp_dow.code
left join lkp_first_road_class        lkp_frc on a.first_road_class_code::varchar           = lkp_frc.code
left join lkp_road_type               lkp_rt  on a.road_type_code::varchar                  = lkp_rt.code
left join lkp_second_road_class       lkp_src on a.second_road_class_code::varchar          = lkp_src.code
left join lkp_junction_detail         lkp_jd  on a.junction_detail_code::varchar            = lkp_jd.code
left join lkp_junction_control        lkp_jc  on a.junction_control_code::varchar           = lkp_jc.code
left join lkp_ped_crossing_human      lkp_pch on a.ped_crossing_human_code::varchar         = lkp_pch.code
left join lkp_ped_crossing_physical   lkp_pcp on a.ped_crossing_physical_code::varchar      = lkp_pcp.code
left join lkp_light_conditions        lkp_lc  on a.light_conditions_code::varchar           = lkp_lc.code
left join lkp_weather_conditions      lkp_wc  on a.weather_conditions_code::varchar         = lkp_wc.code
left join lkp_road_surface            lkp_rs  on a.road_surface_conditions_code::varchar    = lkp_rs.code
left join lkp_special_conditions      lkp_sc  on a.special_conditions_code::varchar         = lkp_sc.code
left join lkp_carriageway_hazards     lkp_ch  on a.carriageway_hazards_code::varchar        = lkp_ch.code
left join lkp_urban_rural             lkp_ur  on a.urban_or_rural_area_code::varchar        = lkp_ur.code
left join lkp_police_officer_attend   lkp_poa on a.police_officer_attend_code::varchar      = lkp_poa.code
