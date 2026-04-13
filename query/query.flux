# 1. Get temperature (degrees) from coyote_creek in a time range, and return 3 records.

from(bucket: "noaa")
    |> range(start: -7d, stop: now()) 
    |> filter(fn: (r) => r["_measurement"] == "average_temperature")
    |> filter(fn: (r) => r["_field"] == "degrees")
    |> filter(fn: (r) => r["location"] == "coyote_creek")
    |> limit(n:3)
    |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
    |> yield(name: "coyote_creek degrees")

# 2. Get 3 temperature records from coyote_creek, then keep only those above 80.

from(bucket: "noaa")
    |> range(start: -7d, stop: now()) 
    |> filter(fn: (r) => r["_measurement"] == "average_temperature")
    |> filter(fn: (r) => r["_field"] == "degrees")
    |> filter(fn: (r) => r["location"] == "coyote_creek")
    |> limit(n:3)
    |> filter(fn: (r) => r["_value"] > 80)
    |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
    |> yield(name: "coyote_creek degrees anove 80")

# 3. Get temperature data (degrees) for coyote_creek and santa_monica, and return the first 3 records for each location

from(bucket: "noaa")
    |> range(start: -7d, stop: now()) 
    |> filter(fn: (r) => r["_measurement"] == "average_temperature")
    |> filter(fn: (r) => r["_field"] == "degrees")
    |> filter(fn: (r) => r["location"] == "coyote_creek" or r["location"] == "santa_monica")
    |> limit(n:3)
    |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
    |> yield(name: "Degrees in all locations")

# 4. From two locations, take 3 records each, then keep values > 80 for coyote_creek and < 80 for santa_monica

from(bucket: "noaa")
    |> range(start: -7d, stop: now()) 
    |> filter(fn: (r) => r["_measurement"] == "average_temperature")
    |> filter(fn: (r) => r["_field"] == "degrees")
    |> filter(fn: (r) => r["location"] == "coyote_creek" or r["location"] == "santa_monica")
    |> limit(n:3)
    |> filter(fn: (r) => if r["location"] == "coyote_creek" then r["_value"] > 80 else r["_value"] < 80 )
    |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
    |> yield(name: "Conditional Degrees in all locations")

# 5. Take 3 records per location, then calculate the average (mean) for each location.

from(bucket: "noaa")
    |> range(start: -7d, stop: now()) 
    |> filter(fn: (r) => r["_measurement"] == "average_temperature")
    |> filter(fn: (r) => r["_field"] == "degrees")
    |> filter(fn: (r) => r["location"] == "coyote_creek" or r["location"] == "santa_monica")
    |> limit(n:3)
    |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
    |> mean(column: "degrees")
    |> yield(name: "Avg Degrees in all locations")

# 6. Take 3 temperature values from coyote_creek, then calculate mean, max, and min and return all three results.

query = from(bucket: "noaa")
            |> range(start: -7d, stop: now()) 
            |> filter(fn: (r) => r["_measurement"] == "average_temperature")
            |> filter(fn: (r) => r["_field"] == "degrees")
            |> filter(fn: (r) => r["location"] == "coyote_creek")
            |> limit(n:3)
            |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
            
query |> mean(column: "degrees")
      |> yield(name: "Avg Degree in coyote_creek")

query |> max(column: "degrees")
      |> yield(name: "Max Degree in coyote_creek")

query |> min(column: "degrees")
      |> yield(name: "Min Degree in coyote_creek")

# 7. Get 4 raw temperature records, return them, then also group them into 12-minute windows and return their averages

query = from(bucket: "noaa")
            |> range(start: -7d, stop: now()) 
            |> filter(fn: (r) => r["_measurement"] == "average_temperature")
            |> filter(fn: (r) => r["_field"] == "degrees")
            |> filter(fn: (r) => r["location"] == "coyote_creek" or r["location"] == "santa_monica")
            |> limit(n:4)
            |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")

query |> yield(name: "Raw Degrees")

query |> aggregateWindow(every: 12m, fn: mean, column: "degrees", createEmpty: false)
      |> yield(name: "Avg Degrees")

# 8. Widnow + mean fn

query = from(bucket: "noaa")
            |> range(start: -7d, stop: now()) 
            |> filter(fn: (r) => r["_measurement"] == "average_temperature")
            |> filter(fn: (r) => r["_field"] == "degrees")
            |> filter(fn: (r) => r["location"] == "coyote_creek" or r["location"] == "santa_monica")
            |> limit(n:4)
            |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")

query |> yield(name: "Raw Degrees")

query |> window(every: 12m)
      |> mean(column: "degrees")
      |> yield(name: "12m Time Window")

# 9. Get 3 records per location, show them first, then merge both locations into one group based only on measurement.

query = from(bucket: "noaa")
            |> range(start: -7d, stop: now()) 
            |> filter(fn: (r) => r["_measurement"] == "average_temperature")
            |> filter(fn: (r) => r["_field"] == "degrees")
            |> filter(fn: (r) => r["location"] == "coyote_creek" or r["location"] == "santa_monica")
            |> limit(n:3)
            |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
            |> group(columns: ["_measurement"])

query |> yield(name: "Degrees per location")

# 10. Take 3 temperature values from two locations, merge them into one group, then calculate one overall average.

query = from(bucket: "noaa")
            |> range(start: -7d, stop: now()) 
            |> filter(fn: (r) => r["_measurement"] == "average_temperature")
            |> filter(fn: (r) => r["_field"] == "degrees")
            |> filter(fn: (r) => r["location"] == "coyote_creek" or r["location"] == "santa_monica")
            |> limit(n:3)
            |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
            |> group(columns: ["_measurement"])

query |> yield(name: "All Degrees in 1 Group")

query |> mean(column: "degrees")
      |> yield(name: "Avg Degree")

# 11. Take 3 temperature records from two locations, then regroup the data based on measurement, field, and time window metadata.

query = from(bucket: "noaa")
            |> range(start: -7d, stop: now()) 
            |> filter(fn: (r) => r["_measurement"] == "average_temperature")
            |> filter(fn: (r) => r["_field"] == "degrees")
            |> filter(fn: (r) => r["location"] == "coyote_creek" or r["location"] == "santa_monica")
            |> limit(n:3)
            |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
            |> group(columns: ["_measurement", "degrees", "_time", "location"])
            |> yield(name: "All Metadata in each group")

# 12. Get temperature from two locations, reshape data into columns, then calculate the difference between them per timestamp.

query = from(bucket: "noaa")
            |> range(start: -7d, stop: now()) 
            |> filter(fn: (r) => r["_measurement"] == "average_temperature")
            |> filter(fn: (r) => r["_field"] == "degrees")
            |> filter(fn: (r) => r["location"] == "coyote_creek" or r["location"] == "santa_monica")
            |> limit(n:3)
            |> group(columns: ["_time"])
            |> pivot(rowKey:["_time"], columnKey: ["location"], valueColumn: "_value")
            |> map(fn: (r) => ({
                r with _difference: r.coyote_creek - r.santa_monica
            }))
            |> yield(name: "Diff Degree between 2 locations")