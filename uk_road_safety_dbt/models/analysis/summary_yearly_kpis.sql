with accident_stats as (

    select
        accident_year,
        count(*)                                                    as total_accidents,
        sum(case when is_fatal then 1 else 0 end)                  as fatal_accidents,
        sum(case when accident_severity = 'Serious' then 1 else 0 end)
                                                                    as serious_accidents,
        sum(number_of_casualties)                                   as total_casualties,
        sum(number_of_vehicles)                                     as total_vehicles
    from {{ ref('mart_accidents') }}
    group by accident_year

),

casualty_stats as (

    select
        accident_year,
        sum(case when casualty_severity = 'Fatal' then 1 else 0 end)
                                                                    as total_fatalities,
        sum(case when casualty_severity = 'Serious' then 1 else 0 end)
                                                                    as total_serious_injuries
    from {{ ref('mart_casualties') }}
    group by accident_year

),

combined as (

    select
        a.accident_year,
        a.total_accidents,
        a.total_casualties,
        a.total_vehicles,
        c.total_fatalities,
        c.total_serious_injuries,
        a.fatal_accidents,
        a.serious_accidents,
        c.total_fatalities + c.total_serious_injuries               as ksi_count,
        round(a.total_casualties::float / nullif(a.total_accidents, 0), 2)
                                                                    as avg_casualties_per_accident,
        round(c.total_fatalities::float / nullif(a.total_casualties, 0) * 100, 2)
                                                                    as fatality_rate_pct,
        round((c.total_fatalities + c.total_serious_injuries)::float
              / nullif(a.total_casualties, 0) * 100, 2)
                                                                    as ksi_rate_pct
    from accident_stats a
    left join casualty_stats c on a.accident_year = c.accident_year

),

with_yoy as (

    select
        *,
        round(
            (total_accidents - lag(total_accidents) over (order by accident_year))::float
            / nullif(lag(total_accidents) over (order by accident_year), 0) * 100,
            2
        )                                                           as pct_change_accidents,
        round(
            (total_casualties - lag(total_casualties) over (order by accident_year))::float
            / nullif(lag(total_casualties) over (order by accident_year), 0) * 100,
            2
        )                                                           as pct_change_casualties,
        round(
            (total_fatalities - lag(total_fatalities) over (order by accident_year))::float
            / nullif(lag(total_fatalities) over (order by accident_year), 0) * 100,
            2
        )                                                           as pct_change_fatalities,
        round(
            ksi_rate_pct - lag(ksi_rate_pct) over (order by accident_year),
            2
        )                                                           as ksi_rate_change_pp
    from combined

)

select
    accident_year,
    total_accidents,
    total_casualties,
    total_vehicles,
    total_fatalities,
    total_serious_injuries,
    fatal_accidents,
    serious_accidents,
    ksi_count,
    avg_casualties_per_accident,
    fatality_rate_pct,
    ksi_rate_pct,
    pct_change_accidents,
    pct_change_casualties,
    pct_change_fatalities,
    ksi_rate_change_pp,

    -- ── Direction arrows for Tableau KPI cards ──────────────────
    case when pct_change_accidents < 0 then '▼'
         when pct_change_accidents > 0 then '▲'
    end                                                             as accidents_arrow,
    case when pct_change_casualties < 0 then '▼'
         when pct_change_casualties > 0 then '▲'
    end                                                             as casualties_arrow,
    case when pct_change_fatalities < 0 then '▼'
         when pct_change_fatalities > 0 then '▲'
    end                                                             as fatalities_arrow,
    case when ksi_rate_change_pp < 0 then '▼'
         when ksi_rate_change_pp > 0 then '▲'
    end                                                             as ksi_rate_arrow,

    -- ── Trend sentiment (green = improvement, red = worsening) ─
    case when pct_change_accidents <= 0 then 'green' else 'red'
    end                                                             as accidents_sentiment,
    case when pct_change_casualties <= 0 then 'green' else 'red'
    end                                                             as casualties_sentiment,
    case when pct_change_fatalities <= 0 then 'green' else 'red'
    end                                                             as fatalities_sentiment,
    case when ksi_rate_change_pp <= 0 then 'green' else 'red'
    end                                                             as ksi_rate_sentiment,

    -- ── Pre-formatted change labels (e.g. "▼ 2.45%") ──────────
    case when pct_change_accidents is not null then
        case when pct_change_accidents < 0 then '▼ ' else '▲ ' end
        || abs(pct_change_accidents)::varchar || '%'
    end                                                             as accidents_change_label,
    case when pct_change_casualties is not null then
        case when pct_change_casualties < 0 then '▼ ' else '▲ ' end
        || abs(pct_change_casualties)::varchar || '%'
    end                                                             as casualties_change_label,
    case when pct_change_fatalities is not null then
        case when pct_change_fatalities < 0 then '▼ ' else '▲ ' end
        || abs(pct_change_fatalities)::varchar || '%'
    end                                                             as fatalities_change_label,
    case when ksi_rate_change_pp is not null then
        case when ksi_rate_change_pp > 0 then '▲ +' else '▼ ' end
        || abs(ksi_rate_change_pp)::varchar || 'pp'
    end                                                             as ksi_rate_change_label

from with_yoy
order by accident_year
