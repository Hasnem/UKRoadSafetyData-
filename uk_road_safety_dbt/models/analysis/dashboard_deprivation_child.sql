-- ════════════════════════════════════════════════════════════════
-- Deprivation Double Bind: Child Pedestrian Casualties
-- Shows: deprived areas have MORE casualties, affluent areas
--        have HIGHER fatality rates — two different problems.
-- Tableau: decile_label → Rows, child_ped_casualties → Bars,
--          all_ped_fatality_rate_pct → Line/Dual Axis
-- ════════════════════════════════════════════════════════════════

with child_ped as (

    select
        casualty_imd_decile                                         as imd_decile,
        count(*)                                                    as total_child_ped_casualties,
        sum(case when casualty_severity = 'Fatal'
            then 1 else 0 end)                                      as child_ped_fatalities
    from {{ ref('mart_casualties') }}
    where age_band_of_casualty in ('0 - 5', '6 - 10', '11 - 15')
      and casualty_type = 'Pedestrian'
      and casualty_imd_decile is not null
    group by casualty_imd_decile

),

all_ped as (

    select
        casualty_imd_decile                                         as imd_decile,
        count(*)                                                    as total_ped_casualties,
        sum(case when casualty_severity = 'Fatal'
            then 1 else 0 end)                                      as ped_fatalities
    from {{ ref('mart_casualties') }}
    where casualty_type = 'Pedestrian'
      and casualty_imd_decile is not null
    group by casualty_imd_decile

),

combined as (

    select
        c.imd_decile,
        c.total_child_ped_casualties,
        c.child_ped_fatalities,
        round(c.child_ped_fatalities::float
              / nullif(c.total_child_ped_casualties, 0) * 100, 2)   as child_ped_fatality_rate_pct,
        a.total_ped_casualties,
        a.ped_fatalities,
        round(a.ped_fatalities::float
              / nullif(a.total_ped_casualties, 0) * 100, 2)         as all_ped_fatality_rate_pct
    from child_ped c
    join all_ped a on c.imd_decile = a.imd_decile

)

select
    imd_decile,
    imd_decile                                                      as sort_order,
    'Decile ' || imd_decile::varchar                                as decile_label,

    -- ── Deprivation grouping ──────────────────────────────────
    case
        when imd_decile between 1 and 3 then 'Most Deprived (1-3)'
        when imd_decile between 4 and 7 then 'Middle (4-7)'
        when imd_decile between 8 and 10 then 'Least Deprived (8-10)'
    end                                                             as deprivation_group,
    case
        when imd_decile between 1 and 3 then 1
        when imd_decile between 4 and 7 then 2
        when imd_decile between 8 and 10 then 3
    end                                                             as deprivation_group_order,

    -- ── Child pedestrian metrics (volume story) ───────────────
    total_child_ped_casualties,
    child_ped_fatalities,
    child_ped_fatality_rate_pct,

    -- ── All pedestrian metrics (severity story) ───────────────
    total_ped_casualties,
    ped_fatalities,
    all_ped_fatality_rate_pct,

    -- ── Color intensity (1 = most deprived) ───────────────────
    round((11 - imd_decile)::float / 10, 2)                         as deprivation_color_intensity,

    -- ── Bar color for child casualties ────────────────────────
    case
        when imd_decile between 1 and 3 then '#B81D13'
        when imd_decile between 4 and 7 then '#FFB020'
        when imd_decile between 8 and 10 then '#008450'
    end                                                             as bar_color_hex,

    -- ── Tooltip ───────────────────────────────────────────────
    'IMD Decile ' || imd_decile::varchar
        || ' (' || case
            when imd_decile between 1 and 3 then 'Most Deprived'
            when imd_decile between 4 and 7 then 'Middle'
            when imd_decile between 8 and 10 then 'Least Deprived'
        end || ')'
        || ' | Child Ped. Casualties: '
        || total_child_ped_casualties::varchar
        || ' | All Ped. Fatality Rate: '
        || all_ped_fatality_rate_pct::varchar || '%'                as tooltip_text

from combined
order by imd_decile
