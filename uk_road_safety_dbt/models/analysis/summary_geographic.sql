select
    accident_year,
    police_force,
    count(*)                                                        as total_accidents,
    sum(number_of_casualties)                                       as total_casualties,
    sum(case when is_fatal then 1 else 0 end)                       as fatal_accidents,
    sum(case when accident_severity = 'Serious' then 1 else 0 end)  as serious_accidents,
    round(
        sum(case when is_fatal then 1 else 0 end)::float
        / nullif(count(*), 0) * 100,
        2
    )                                                               as fatality_rate_pct,
    round(
        sum(case when is_fatal or accident_severity = 'Serious'
            then 1 else 0 end)::float
        / nullif(count(*), 0) * 100,
        2
    )                                                               as ksi_rate_pct,
    round(sum(number_of_casualties)::float / nullif(count(*), 0), 2)
                                                                    as avg_casualties_per_accident,
    round(avg(latitude)::float, 4)                                  as avg_latitude,
    round(avg(longitude)::float, 4)                                 as avg_longitude
from {{ ref('mart_accidents') }}
where police_force is not null
group by 1, 2
order by 1, 2
