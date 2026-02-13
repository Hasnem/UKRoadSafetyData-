-- ════════════════════════════════════════════════════════════════
-- Police Force Map: Geographic KSI Analysis (latest year)
-- Tableau: avg_longitude → Columns, avg_latitude → Rows,
--          latest_ksi_rate_pct → Color, bubble_size → Size
-- ════════════════════════════════════════════════════════════════

with latest as (

    select *
    from {{ ref('summary_geographic') }}
    where accident_year = (
        select max(accident_year)
        from {{ ref('summary_geographic') }}
    )

),

baseline as (

    select *
    from {{ ref('summary_geographic') }}
    where accident_year = (
        select min(accident_year)
        from {{ ref('summary_geographic') }}
    )

),

national_avg as (

    select
        round(avg(ksi_rate_pct)::float, 2)                          as avg_ksi_rate,
        round(avg(fatality_rate_pct)::float, 2)                     as avg_fatality_rate
    from latest

)

select
    l.police_force,
    l.accident_year                                                 as latest_year,
    l.total_accidents,
    l.total_casualties,
    l.fatal_accidents,
    l.serious_accidents,
    l.fatality_rate_pct,
    l.ksi_rate_pct                                                  as latest_ksi_rate_pct,
    l.avg_casualties_per_accident,

    -- ── Baseline comparison ───────────────────────────────────
    b.ksi_rate_pct                                                  as baseline_ksi_rate_pct,
    round(l.ksi_rate_pct - coalesce(b.ksi_rate_pct, 0), 2)         as ksi_rate_change_pp,
    b.total_accidents                                               as baseline_total_accidents,
    round((l.total_accidents - b.total_accidents)::float
          / nullif(b.total_accidents, 0) * 100, 1)                  as accident_change_pct,

    -- ── National average reference ────────────────────────────
    n.avg_ksi_rate                                                  as national_avg_ksi_rate,
    n.avg_fatality_rate                                             as national_avg_fatality_rate,

    -- ── Vs national average ───────────────────────────────────
    case
        when l.ksi_rate_pct > n.avg_ksi_rate then 'Above Average'
        else 'Below Average'
    end                                                             as vs_national_avg,

    -- ── Trend category ────────────────────────────────────────
    case
        when l.ksi_rate_pct - coalesce(b.ksi_rate_pct, 0) > 10 then 'Large Increase (>10pp)'
        when l.ksi_rate_pct - coalesce(b.ksi_rate_pct, 0) > 5  then 'Moderate Increase (5-10pp)'
        when l.ksi_rate_pct - coalesce(b.ksi_rate_pct, 0) > 0  then 'Slight Increase (0-5pp)'
        when l.ksi_rate_pct - coalesce(b.ksi_rate_pct, 0) = 0  then 'No Change'
        else 'Decrease'
    end                                                             as trend_category,
    case
        when l.ksi_rate_pct - coalesce(b.ksi_rate_pct, 0) > 10 then 4
        when l.ksi_rate_pct - coalesce(b.ksi_rate_pct, 0) > 5  then 3
        when l.ksi_rate_pct - coalesce(b.ksi_rate_pct, 0) > 0  then 2
        else 1
    end                                                             as trend_category_order,

    -- ── Map coordinates ───────────────────────────────────────
    l.avg_latitude,
    l.avg_longitude,

    -- ── Bubble size (sqrt-scaled for proportional area) ───────
    round(sqrt(l.total_accidents::float), 2)                        as bubble_size,

    -- ── Color ─────────────────────────────────────────────────
    case
        when l.ksi_rate_pct >= 30 then '#B81D13'
        when l.ksi_rate_pct >= 20 then '#EF7D00'
        when l.ksi_rate_pct >= 15 then '#FFB020'
        else '#008450'
    end                                                             as marker_color_hex,

    -- ── KSI change arrow ──────────────────────────────────────
    case
        when l.ksi_rate_pct > coalesce(b.ksi_rate_pct, 0) then '▲'
        when l.ksi_rate_pct < coalesce(b.ksi_rate_pct, 0) then '▼'
        else '—'
    end                                                             as ksi_change_arrow,

    -- ── Tooltip ───────────────────────────────────────────────
    l.police_force
        || ' | KSI Rate: ' || l.ksi_rate_pct::varchar || '%'
        || ' (was ' || coalesce(b.ksi_rate_pct::varchar, 'N/A') || '%)'
        || ' | Change: '
        || case when l.ksi_rate_pct > coalesce(b.ksi_rate_pct, 0) then '+' else '' end
        || round(l.ksi_rate_pct - coalesce(b.ksi_rate_pct, 0), 1)::varchar || 'pp'
        || ' | Accidents: ' || l.total_accidents::varchar           as tooltip_text

from latest l
left join baseline b on l.police_force = b.police_force
cross join national_avg n
order by l.ksi_rate_pct desc
