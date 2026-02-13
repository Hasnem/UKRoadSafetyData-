# Dashboard Metrics Reference

**Fewer Crashes, Deadlier Outcomes**

UK Road Safety 2015–2018 | STATS19 | dbt → Snowflake → Tableau

Definitions, formulas, and key insight for every dashboard component in visual order.

---

## 1. KPI Scorecards

**Source:** summary_yearly_kpis ← mart_accidents + mart_casualties

| Metric | Formula |
|---|---|
| **Total Accidents** | Count of unique police-recorded accidents. |
| **Total Casualties** | Count of all people injured or killed across all accidents. |
| **Total Fatalities** | Casualties who died within 30 days of the accident. |
| **KSI Rate** | (Fatalities + Serious Injuries) ÷ Total Casualties × 100. |
| **% Change (counts)** | (Current Year − Previous Year) ÷ Previous Year × 100. |
| **pp Change (rates)** | Current Year Rate − Previous Year Rate. |

> **Insight:** All volume metrics are falling, but the KSI rate keeps rising. Fewer people crash, yet those who do face worse outcomes.

---

## 2. The KSI Paradox (Indexed Trend Chart)

**Source:** dashboard_trend_ksi_paradox ← summary_yearly_kpis

| Concept | Definition |
|---|---|
| **Index Formula** | (Value in Current Year ÷ Value in Base Year) × 100. Every metric starts at exactly 100 in the base year (2015). |
| **Above 100** | The metric has worsened compared to the base year. |
| **Below 100** | The metric has improved compared to the base year. |
| **Metrics Indexed** | Total Accidents, Total Casualties, Total Fatalities, and KSI Rate — all on one axis despite different scales. |

> **Insight:** Volume metrics trend below 100 while KSI Rate climbs well above it, making the paradox visually unmistakable on a single chart.

---

## 3. When Are Roads Deadliest? (Fatality Heatmap)

**Source:** dashboard_heatmap_hour_day ← summary_temporal ← mart_accidents

| Element | Definition |
|---|---|
| **Cell** | One hour-of-day (0–23) × day-of-week combination, aggregated across all four years. |
| **Fatality Rate** | Fatal Accidents ÷ Total Accidents × 100. This is an accident-level rate (was the crash fatal?). |
| **Colour Intensity** | Min–max normalisation: (Cell Rate − Min Rate) ÷ (Max Rate − Min Rate). Produces a 0–1 scale. Darker = deadlier. |

> **Insight:** Late-night and early-morning hours, especially on weekends, have the highest fatality rates. Rush hours are the opposite: frequent crashes but rarely fatal.

---

## 4. Conditions That Kill (Risk Ladder)

**Source:** dashboard_conditions_multiplier ← mart_accidents

| Element | Definition |
|---|---|
| **Condition Labels** | Each label combines filters on urban/rural area, lighting (Daylight, Dark-lit, Dark-unlit), and speed limit. Fog is filtered by weather regardless of other conditions. |
| **Fatality Rate** | Fatal Accidents ÷ Total Accidents × 100. Accident-level rate: given a crash happened under these conditions, was it fatal? |
| **Baseline** | Urban · Daylight · 30mph — the safest common driving scenario. |
| **Multiplier** | Condition Fatality Rate ÷ Baseline Fatality Rate. Shows how many times deadlier a condition is. |
| **Risk Category** | Extreme (≥4.0%), High (≥2.5%), Elevated (≥1.0%), Baseline (<1.0%). Drives bar colour on a traffic-light scale. |

> **Insight:** Rural, unlit, high-speed roads are the deadliest corridors. Conditions compound: each added risk factor (darkness, higher speed, no lighting) multiplies the fatality rate.

---

## 5. Who Is Most Vulnerable? (Vulnerability Profile)

**Source:** dashboard_vulnerability_profile ← mart_casualties

| Element | Definition |
|---|---|
| **Profiles** | Each profile filters casualties by road-user type (Pedestrian, Cyclist, Car Occupant) and optionally by age band (Over 75, 66–75, Child 0–15). |
| **Fatality Rate** | Fatal Casualties ÷ Total Casualties × 100. Casualty-level rate: given a person was hurt, did they die? |
| **Reference Line** | All Casualties (Average) — the overall fatality rate across every casualty regardless of type or age. |
| **Multiplier** | Profile Fatality Rate ÷ Overall Average Fatality Rate. Shows how many times more (or less) lethal the profile is vs the norm. |

> **Insight:** Elderly pedestrians are by far the most vulnerable group. Age-related frailty makes even low-speed collisions lethal, while vehicle safety systems protect car occupants below average.

---

## 6. Deprivation & Child Pedestrians (Double Bind)

**Source:** dashboard_deprivation_child ← mart_casualties

| Element | Definition |
|---|---|
| **IMD Decile** | Index of Multiple Deprivation. England's area-level deprivation score (income, employment, health, education, crime, housing). Decile 1 = most deprived 10%. |
| **Child Ped. Casualties (bars)** | Count of pedestrian casualties aged 0–15, grouped by the casualty's IMD decile. |
| **All Ped. Fatality Rate (line)** | Pedestrian Fatalities ÷ Total Pedestrian Casualties × 100, by IMD decile. Casualty-level rate across all ages. |
| **Deprivation Groups** | Most Deprived (Deciles 1–3), Middle (4–7), Least Deprived (8–10). Used for bar colour grouping. |

> **Insight:** Deprived areas have far more child pedestrian casualties (a volume problem from greater exposure), while affluent areas have higher fatality rates (a severity problem from higher speeds). Two different problems requiring two different interventions.

---

## 7. Police Force KSI Rates (Bubble Map)

**Source:** dashboard_police_force_map ← summary_geographic ← mart_accidents

| Element | Definition |
|---|---|
| **KSI Rate** | (Fatal + Serious Accidents) ÷ Total Accidents × 100, per police force for the latest year. |
| **KSI Change (pp)** | Latest Year KSI Rate − Baseline Year KSI Rate. Expressed in percentage points. |
| **Bubble Size** | Square root of total accidents. Ensures bubble area is proportional to volume without large forces overwhelming the map. |
| **Bubble Colour** | KSI rate thresholds: ≥30% red, ≥20% orange, ≥15% amber, <15% green. |
| **Vs National Average** | Each force's KSI rate compared to the mean across all forces. Above or below. |
| **Trend Category** | Classifies each force by KSI change since baseline: Large Increase (>10pp), Moderate (5–10pp), Slight (0–5pp), or Decrease. |
| **Map Coordinates** | Average latitude and longitude of all accidents in each force area. |

> **Insight:** Nearly every force saw KSI rates rise since 2015, with only a handful showing any decrease. The paradox plays out geographically: forces with fewer accidents still see worsening severity.

---

## Glossary

| Term | Definition |
|---|---|
| **KSI** | Killed or Seriously Injured. The UK government's primary road safety measure. |
| **Fatal (30-day rule)** | A casualty who died within 30 days of the accident. |
| **Serious Injury** | Hospitalised with fractures, internal injuries, severe burns, crushing, concussion, or loss of limb. |
| **STATS19** | UK police-reported road accident dataset. The source for all data in this dashboard. |
| **IMD** | Index of Multiple Deprivation. England's area-level deprivation measure. |
| **pp** | Percentage points. The absolute difference between two percentages. |
| **Speed Limit** | The posted limit on the road, not the vehicle's actual speed. |
| **Accident Severity** | Determined by the worst casualty outcome: Fatal > Serious > Slight. |

---

*Built by Hassan Nammari | dbt → Snowflake → Tableau*
