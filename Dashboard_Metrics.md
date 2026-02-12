# Dashboard Metrics

**Fewer Crashes, Deadlier Outcomes**

Definitions, formulas, and grouping logic for every metric and classification in the dashboard.

---

## Core Metrics

Base counts shown in the KPI scorecards that feed into all calculated rates.

| Metric | Definition |
|--------|------------|
| Total Accidents | Count of unique police-recorded road traffic accidents. |
| Total Casualties | Count of all people injured or killed across all accidents. One accident can produce multiple casualties. |
| Total Fatalities | Count of casualties who died within 30 days of the accident (UK 30-day rule). |
| Total Serious Injuries | Count of casualties hospitalised with fractures, internal injuries, severe burns, crushing, concussion, or loss of limb. |

## Rates

The dashboard uses two denominator levels depending on the question being asked.

| Rate | Formula & Usage |
|------|-----------------|
| Fatality Rate (accident-level) | Fatal Accidents / Total Accidents x 100. Asks: given a crash happened, was it fatal? Used in Heatmap and Conditions charts. |
| Fatality Rate (casualty-level) | Fatal Casualties / Total Casualties x 100. Asks: given a person was hurt, did they die? Used in KPIs, Vulnerability, and Deprivation charts. |
| KSI Rate | (Fatalities + Serious Injuries) / Total Casualties x 100. KSI = Killed or Seriously Injured. The UK government's primary road safety target metric. Used in KPIs, Trend, and Police Map. |

## Change Metrics

Shown in the KPI scorecards to indicate year-over-year direction.

| Metric | Formula |
|--------|---------|
| % Change (counts) | (Current Year - Previous Year) / Previous Year x 100. Applied to accident, casualty, and fatality counts. Negative = improving. |
| pp Change (rates) | Current Year Rate - Previous Year Rate. Expressed in percentage points (pp). Applied to KSI Rate and Fatality Rate. Positive = worsening. |

## Index (Trend Chart)

Rebases multiple metrics to a common starting point so they can be compared on one chart despite different scales.

| Concept | How It Works |
|---------|--------------|
| Index Formula | (Value in Current Year / Value in Base Year) x 100. Every metric starts at exactly 100 in the base year. |
| Above 100 | The metric has worsened compared to the base year. |
| Below 100 | The metric has improved compared to the base year. |

## Multipliers

Express how much deadlier one group or condition is relative to a reference point.

| Chart | How the Multiplier Is Calculated |
|-------|----------------------------------|
| Conditions That Kill | Condition Fatality Rate / Baseline Fatality Rate. Baseline = Urban, Daylight, 30 mph, the safest common driving scenario. |
| Who Is Most Vulnerable? | Profile Fatality Rate / Overall Average Fatality Rate. Average = fatality rate across all casualties regardless of type or age. |

## Groups & Classifications

How categories and colour-coded groups are constructed.

| Group | How It Is Defined |
|-------|-------------------|
| Condition Labels | Each condition combines three filters on accident data: Urban vs Rural area, Lighting (Daylight, Dark-lit, Dark-unlit), and Speed limit. Fog is filtered by weather field regardless of other conditions. |
| Risk Category | Assigned by fatality rate thresholds: Extreme, High, Elevated, and Baseline. Used for bar colour in the Conditions chart. |
| Vulnerability Profiles | Each profile filters casualties by type (Pedestrian, Cyclist, Car Occupant) and optionally by age band (Over 75, 66-75, Child). All ages combined where not specified. |
| IMD Decile | Index of Multiple Deprivation. England's official area-level deprivation score combining income, employment, health, education, crime, housing, and living environment. Areas ranked into ten equal groups. Lowest decile = most deprived. |
| Deprivation Group | Three-tier grouping of IMD deciles for colour coding: Most Deprived (lowest deciles, red), Middle (amber), Least Deprived (highest deciles, green). |
| Heatmap Cells | Each cell is one hour-of-day x day-of-week combination. Colour intensity represents the fatality rate for that time slot, darker = deadlier. |
| Vs National Avg (Map) | Each police force's KSI rate compared to the national average. Above average = darker red. Below average = lighter. |
| Trend Category (Map) | Classifies each police force by how much its KSI rate changed since the base year: Decrease, Slight Increase, Moderate Increase, Large Increase. |

## Visual Scaling

Techniques applied to make visualisations readable.

| Technique | How & Why |
|-----------|-----------|
| Bubble Size (Map) | Square-root of total accidents. Without scaling, the largest force would visually overwhelm all others. Square-root ensures bubble area is proportional to data volume. |
| Colour Intensity (Heatmap) | Min-max normalisation: (cell rate - minimum) / (maximum - minimum). Produces a zero-to-one scale mapped to the colour gradient. Lightest = safest, darkest = deadliest. |

## Glossary

| Term | Definition |
|------|------------|
| KSI | Killed or Seriously Injured. The UK government's primary road safety measure. |
| Fatal (30-day rule) | A casualty who died within 30 days of the accident. UK and international standard. |
| Serious Injury | Hospitalised with fractures, internal injuries, severe burns, crushing, concussion, or loss of limb/sight. |
| Slight Injury | Any injury not Fatal or Serious — sprains, bruises, whiplash not requiring hospital stay. |
| pp | Percentage points. The absolute difference between two percentages. |
| IMD | Index of Multiple Deprivation. England's official neighbourhood deprivation measure. |
| STATS19 | UK police-reported road accident dataset. The source for all data in this dashboard. |
| Speed Limit | The posted speed limit on the road where the accident occurred, not the vehicle's speed of travel. |
| Accident Severity | Determined by the worst casualty outcome in the accident: Fatal > Serious > Slight. |
