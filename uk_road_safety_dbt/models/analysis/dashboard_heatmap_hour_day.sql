-- ════════════════════════════════════════════════════════════════
-- Hour × Day-of-Week Fatality Heatmap (aggregated across all years)
-- Tableau: accident_hour → Rows, day_of_week → Columns
--          (sort by day_of_week_order), fatality_rate_pct → Color
-- ════════════════════════════════════════════════════════════════

with hourly_day as (

    select
        day_of_week,
        max(day_of_week_order) as day_of_week_order,
        accident_hour,
        sum(total_accidents)   as total_accidents,
        sum(total_casualties)  as total_casualties,
        sum(fatal_accidents)   as fatal_accidents
    from {{ ref('summary_temporal') }}
    group by day_of_week, accident_hour

),

with_rates as (

    select
        *,
        round(fatal_accidents::float
              / nullif(total_accidents, 0) * 100, 2)                as fatality_rate_pct
    from hourly_day

),

stats as (

    select
        min(fatality_rate_pct) as min_rate,
        max(fatality_rate_pct) as max_rate,
        avg(fatality_rate_pct) as avg_rate
    from with_rates

)

select
    h.day_of_week,
    h.day_of_week_order,
    h.accident_hour,
    lpad(h.accident_hour::varchar, 2, '0') || ':00'                 as hour_label,
    h.total_accidents,
    h.total_casualties,
    h.fatal_accidents,
    h.fatality_rate_pct,

    -- ── Color intensity (0 to 1, for continuous color scale) ───
    round((h.fatality_rate_pct - s.min_rate)
          / nullif(s.max_rate - s.min_rate, 0), 4)                  as color_intensity,

    -- ── Risk level category ───────────────────────────────────
    case
        when h.fatality_rate_pct >= 3.0 then 'Extreme'
        when h.fatality_rate_pct >= 2.0 then 'High'
        when h.fatality_rate_pct >= 1.0 then 'Moderate'
        else 'Low'
    end                                                             as risk_level,
    case
        when h.fatality_rate_pct >= 3.0 then 4
        when h.fatality_rate_pct >= 2.0 then 3
        when h.fatality_rate_pct >= 1.0 then 2
        else 1
    end                                                             as risk_level_order,

    -- ── Weekend flag ──────────────────────────────────────────
    case when h.day_of_week_order in (6, 7) then true
         else false
    end                                                             as is_weekend,

    -- ── Average reference for Tableau reference line ──────────
    round(s.avg_rate, 2)                                            as avg_fatality_rate_pct,

    -- ── Tooltip text ──────────────────────────────────────────
    h.day_of_week || ' ' || lpad(h.accident_hour::varchar, 2, '0') || ':00'
        || ' | Accidents: ' || h.total_accidents::varchar
        || ' | Fatal: ' || h.fatal_accidents::varchar
        || ' | Rate: ' || h.fatality_rate_pct::varchar || '%'       as tooltip_text

from with_rates h
cross join stats s
order by h.day_of_week_order, h.accident_hour
