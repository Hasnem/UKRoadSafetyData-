-- ════════════════════════════════════════════════════════════════
-- KSI Paradox Trend Chart (indexed to 2015 = 100)
-- Tableau: accident_year → Columns, index_2015 → Rows,
--          metric_name → Color (use color_hex)
-- ════════════════════════════════════════════════════════════════

with base as (

    select * from {{ ref('summary_yearly_kpis') }}

),

base_yr as (

    select *
    from base
    where accident_year = (select min(accident_year) from base)

),

unpivoted as (

    select
        b.accident_year,
        'Total Accidents' as metric_name,
        1 as metric_sort,
        b.total_accidents as raw_value,
        round(b.total_accidents::float
              / nullif(y.total_accidents, 0) * 100, 1)              as index_2015,
        '#4E79A7' as color_hex
    from base b cross join base_yr y

    union all

    select
        b.accident_year,
        'Total Casualties',
        2,
        b.total_casualties,
        round(b.total_casualties::float
              / nullif(y.total_casualties, 0) * 100, 1),
        '#76B7B2'
    from base b cross join base_yr y

    union all

    select
        b.accident_year,
        'Total Fatalities',
        3,
        b.total_fatalities,
        round(b.total_fatalities::float
              / nullif(y.total_fatalities, 0) * 100, 1),
        '#F28E2B'
    from base b cross join base_yr y

    union all

    select
        b.accident_year,
        'KSI Rate (%)',
        4,
        b.ksi_rate_pct,
        round(b.ksi_rate_pct::float
              / nullif(y.ksi_rate_pct, 0) * 100, 1),
        '#E15759'
    from base b cross join base_yr y

)

select
    accident_year,
    metric_name,
    metric_sort,
    raw_value,
    index_2015,
    color_hex,
    case
        when index_2015 > 100 then 'Above 2015 Baseline'
        when index_2015 < 100 then 'Below 2015 Baseline'
        else 'At 2015 Baseline'
    end                                                             as vs_baseline,
    100 as reference_line_value
from unpivoted
order by metric_sort, accident_year
