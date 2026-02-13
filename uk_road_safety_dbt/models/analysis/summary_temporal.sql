select
    accident_year,
    accident_month,
    day_of_week,
    case day_of_week
        when 'Monday' then 1 when 'Tuesday' then 2
        when 'Wednesday' then 3 when 'Thursday' then 4
        when 'Friday' then 5 when 'Saturday' then 6
        when 'Sunday' then 7
    end                                                            as day_of_week_order,
    extract(hour from accident_time)                                as accident_hour,
    is_weekend,
    accident_severity                                               as severity,
    count(*)                                                        as total_accidents,
    sum(number_of_casualties)                                       as total_casualties,
    sum(case when is_fatal then number_of_casualties else 0 end)    as casualties_in_fatal_accidents,
    sum(case when is_fatal then 1 else 0 end)                       as fatal_accidents
from {{ ref('mart_accidents') }}
where accident_time is not null
group by 1, 2, 3, 4, 5, 6, 7
order by 1, 2, 4, 5, 7
