-- ════════════════════════════════════════════════════════════════
-- Conditions Risk Ladder (how conditions compound fatality risk)
-- Tableau: condition_label → Rows (sort by sort_order),
--          fatality_rate_pct → Columns, bar_color_hex → Color
-- ════════════════════════════════════════════════════════════════

with condition_groups as (

    -- 1. National Average (reference)
    select
        'National Average' as condition_label,
        1 as sort_order,
        count(*) as total_accidents,
        sum(case when is_fatal then 1 else 0 end) as fatal_accidents
    from {{ ref('mart_accidents') }}

    union all

    -- 2. Urban · Daylight · 30mph (safest common baseline)
    select 'Urban · Daylight · 30mph', 2, count(*),
        sum(case when is_fatal then 1 else 0 end)
    from {{ ref('mart_accidents') }}
    where urban_or_rural_area = 'Urban'
      and light_conditions = 'Daylight'
      and speed_limit = 30

    union all

    -- 3. Urban · Dark · 30mph (add darkness in urban)
    select 'Urban · Dark · 30mph', 3, count(*),
        sum(case when is_fatal then 1 else 0 end)
    from {{ ref('mart_accidents') }}
    where urban_or_rural_area = 'Urban'
      and light_conditions like 'Darkness%'
      and speed_limit = 30

    union all

    -- 4. Fog · Any Road
    select 'Fog · Any Road', 4, count(*),
        sum(case when is_fatal then 1 else 0 end)
    from {{ ref('mart_accidents') }}
    where weather_conditions ilike '%fog%'

    union all

    -- 5. Rural · Daylight · 60mph
    select 'Rural · Daylight · 60mph', 5, count(*),
        sum(case when is_fatal then 1 else 0 end)
    from {{ ref('mart_accidents') }}
    where urban_or_rural_area = 'Rural'
      and light_conditions = 'Daylight'
      and speed_limit = 60

    union all

    -- 6. Rural · Dark (lit) · 60mph
    select 'Rural · Dark (lit) · 60mph', 6, count(*),
        sum(case when is_fatal then 1 else 0 end)
    from {{ ref('mart_accidents') }}
    where urban_or_rural_area = 'Rural'
      and light_conditions = 'Darkness - lights lit'
      and speed_limit = 60

    union all

    -- 7. Rural · Dark (unlit) · 60mph (deadliest corridor)
    select 'Rural · Dark (unlit) · 60mph', 7, count(*),
        sum(case when is_fatal then 1 else 0 end)
    from {{ ref('mart_accidents') }}
    where urban_or_rural_area = 'Rural'
      and light_conditions = 'Darkness - no lighting'
      and speed_limit = 60

),

with_rates as (

    select
        condition_label,
        sort_order,
        total_accidents,
        fatal_accidents,
        round(fatal_accidents::float
              / nullif(total_accidents, 0) * 100, 2)                as fatality_rate_pct
    from condition_groups

),

baseline as (

    select fatality_rate_pct as baseline_rate
    from with_rates
    where condition_label = 'Urban · Daylight · 30mph'

)

select
    w.condition_label,
    w.sort_order,
    w.total_accidents,
    w.fatal_accidents,
    w.fatality_rate_pct,
    b.baseline_rate                                                 as baseline_fatality_rate_pct,
    round(w.fatality_rate_pct
          / nullif(b.baseline_rate, 0), 1)                          as multiplier_vs_baseline,

    -- ── Pre-formatted labels ──────────────────────────────────
    w.fatality_rate_pct::varchar || '%'                              as rate_label,
    round(w.fatality_rate_pct
          / nullif(b.baseline_rate, 0), 1)::varchar || 'x'          as multiplier_label,

    -- ── Bar color (traffic-light scale) ───────────────────────
    case
        when w.fatality_rate_pct >= 4.0 then '#B81D13'
        when w.fatality_rate_pct >= 2.5 then '#EF7D00'
        when w.fatality_rate_pct >= 1.0 then '#FFB020'
        else '#008450'
    end                                                             as bar_color_hex,

    -- ── Risk category ─────────────────────────────────────────
    case
        when w.fatality_rate_pct >= 4.0 then 'Extreme Risk'
        when w.fatality_rate_pct >= 2.5 then 'High Risk'
        when w.fatality_rate_pct >= 1.0 then 'Elevated Risk'
        else 'Baseline'
    end                                                             as risk_category,

    -- ── Flags ─────────────────────────────────────────────────
    case when w.condition_label = 'Urban · Daylight · 30mph'
         then true else false
    end                                                             as is_baseline,
    case when w.condition_label = 'National Average'
         then true else false
    end                                                             as is_national_avg,

    -- ── Tooltip ───────────────────────────────────────────────
    w.condition_label
        || ' | Fatality Rate: ' || w.fatality_rate_pct::varchar || '%'
        || ' | ' || round(w.fatality_rate_pct
                          / nullif(b.baseline_rate, 0), 1)::varchar
        || 'x baseline'
        || ' | Accidents: ' || w.total_accidents::varchar           as tooltip_text

from with_rates w
cross join baseline b
order by w.sort_order
