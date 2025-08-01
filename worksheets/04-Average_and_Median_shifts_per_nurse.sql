-- KPI: Number of shifts per nurse (average and median) by hospital and state.

-- If I understand the ask for this KPI, it is asking:
--
-- "How may shifts, on average and median, did each nurse work
-- in a given period?" 
--
-- In order to calculate this, we need more granular data that identifies
-- nurses specifically by id or something similar.  We only have 
-- aggregated hours per day in fact_provider_daily_staffing, so there's no
-- way to tell which nurse worked those hours or how many individual nurses
-- worked that day.
--
-- Therefore, THIS KPI CANNOT BE COMPUTED DIRECTLY FROM THE GIVEN DATA
