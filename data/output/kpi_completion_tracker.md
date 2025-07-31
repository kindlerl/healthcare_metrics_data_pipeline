# KPI Completion Tracker

| #  | KPI Description                                                                 | Status            | Notes                                                                                           |
|----|----------------------------------------------------------------------------------|-------------------|-------------------------------------------------------------------------------------------------|
| 1  | Number of shifts per nurse (average and median) by hospital and state          | ❌ Not feasible    | No individual nurse identifiers or shift-level data available                                  |
| 2  | Top 10 hospitals with the highest patient throughput                            | ⚠️ Snapshot only   | Calculated using single-day census; true throughput requires multiple dates                    |
| 3  | Facilities with the lowest staffing levels compared to patient load            | ✅ Completed       | Used nurse hours per patient day as a valid proxy                                              |
| 4  | Patient satisfaction scores by hospital                                         | ✅ Completed       | Used overall, short-stay, and long-stay quality ratings as proxies                             |
| 5  | Average length of stay (ALOS) by department and state                           | ❌ Not feasible    | No admission/discharge data or department info                                                 |
| 6  | Readmission rates within 30 days by hospital, state, and diagnosis category     | ⚠️ Proxy only      | Used CMS risk-standardized readmission rates at facility level; no diagnosis/patient data      |
| 7  | Patient-to-nurse complaint ratio                                                | ✅ Completed       | Used substantiated complaints per 100 patients based on census snapshot                        |
| 8  | Correlation between nurse staffing levels and readmission rates                | ❌ Not feasible    | No time-aligned data to compute correlation; readmission and staffing periods are mismatched   |
| 9  | Total payroll costs for nurses by hospital and state                            | ❌ Not feasible    | No salary, wage, or cost data available                                                        |
| 10 | Average cost per patient stay by hospital and state                             | ❌ Not feasible    | No financial or patient-level stay data available                                              |
| 11 | Cost of overtime hours as a percentage of total payroll costs                   | ❌ Not feasible    | Overtime hours can be estimated, but no payroll or wage data is available                     |
| 12 | Comparison of hospital revenue vs. payroll expenses                             | ❌ Not feasible    | No revenue or payroll expense data exists                                                      |
| 13 | Shift utilization rates by time of day (morning, afternoon, night)              | ❌ Not feasible    | No shift-level timestamps or time-of-day granularity                                           |
| 14 | Peak staffing hours for each hospital and department                            | ❌ Not feasible    | No hourly timestamps or departmental breakdowns in data                                        |
| 15 | Ratio of permanent staff to temporary/contract staff                            | ✅ Completed       | Calculated using employee vs. contractor nurse hours                                           |
| 16 | Trend analysis of nurse attrition rates                                         | ❌ Not feasible    | No employment history, hire/termination data, or staff-level identifiers                       |
| 17 | [Reserved – If Applicable]                                                      | —                 | —                                                                                              |
| 18 | [Reserved – If Applicable]                                                      | —                 | —                                                                                              |
| 19 | Shift utilization rates by time of day                                          | ❌ Not feasible    | Duplicate of KPI #13                                                                            |
| 20 | Peak staffing hours for each hospital and department                            | ❌ Not feasible    | Duplicate of KPI #14                                                                            |
| 21 | Ratio of permanent staff to temporary/contract staff                            | ✅ Completed       | Same as KPI #15                                                                                 |
| 22 | Trend analysis of nurse attrition rates                                         | ❌ Not feasible    | Same as KPI #16                                                                                 |
