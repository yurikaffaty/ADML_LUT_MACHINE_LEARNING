clc; clear all; close all;

%% Import data
Traindata = readtable('DailyDelhiClimateTrain.csv');
% Testdata = readtable('DailyDelhiClimateTest.csv');

%% Ensure the data is continuous measurements with the same frequency

Traindata_timetable = table2timetable(Traindata, 'RowTimes', 'date');

% Check for Regular Time Steps
timeDiffs = diff(Traindata_timetable.date);
isRegular = all(timeDiffs == mode(timeDiffs)); % logical 1 means all time differences are the same

% Define 'daily' as the frequency
desiredFrequency = 'daily';
Traindata_resampled = retime(Traindata_timetable, desiredFrequency, 'linear');

% Check if the frequency is consistent with days
freq_consistent = all(diff(Traindata_resampled.date) == days(1));

if freq_consistent
    disp('The data has continuous measurements with the same frequency.');
else
    disp('The data does not have continuous measurements with the same frequency.');
end

%% check the data synchronous across all the variables
uniqueDates = unique(Traindata_timetable.date);
datesAreUnique = length(uniqueDates) == height(Traindata_timetable);

%% Check missing values
missingValues = sum(ismissing(Traindata_timetable));
noMissingValues = all(missingValues == 0);

if datesAreUnique && noMissingValues
    disp('The data is synchronous across all variables.');
else
    disp('The data is not synchronous across all variables.');
end

%% The STL decomposition to spot and eliminate possible outliers

% Mean Temperature
[LT_temp,ST_temp,R_temp] = trenddecomp(Traindata.meantemp, NumSeasonal=2);

outlierThreshold = mean(R_temp) + 2 * std(R_temp);
outliers_Temperature = abs(R_temp) > outlierThreshold;

% Replacing outliers with NaNs in Mean Temperature
cleanedData_temp = Traindata.meantemp;
cleanedData_temp(outliers_Temperature) = NaN;

figure;
% Original Time Series
subplot(4,1,1);
plot(Traindata.date, Traindata.meantemp);
title('Original Time Series');
ylabel('Temperature');

% Trend Component
subplot(4,1,2);
plot(Traindata.date, LT_temp);
title('Trend Component');
ylabel('Trend');

% Seasonal Component
subplot(4,1,3);
plot(Traindata.date, ST_temp);
title('Seasonal Component');
ylabel('Seasonality');

% Data with Outliers Removed
subplot(4,1,4);
plot(Traindata.date, cleanedData_temp);
title('Data with Outliers Removed');
ylabel('Temperature');

xlabel('Date');

% Humidity
[LT_humidity,ST_humidity,R_humidity] = trenddecomp(Traindata.humidity, NumSeasonal=2);

outlierThreshold = mean(R_humidity) + 2 * std(R_humidity);
outliers_humidity = abs(R_humidity) > outlierThreshold;

% Replacing outliers with NaNs in humidity
cleanedData_humidity = Traindata.humidity;
cleanedData_humidity(outliers_humidity) = NaN;

figure;
% Original Time Series
subplot(4,1,1);
plot(Traindata.date, Traindata.humidity);
title('Original Time Series');
ylabel('Humidity');

% Trend Component
subplot(4,1,2);
plot(Traindata.date, LT_humidity);
title('Trend Component');
ylabel('Trend');

% Seasonal Component
subplot(4,1,3);
plot(Traindata.date, ST_humidity);
title('Seasonal Component');
ylabel('Seasonality');

% Data with Outliers Removed
subplot(4,1,4);
plot(Traindata.date, cleanedData_humidity);
title('Data with Outliers Removed');
ylabel('Humidity');

xlabel('Date');


% Wind speed
[LT_wind,ST_wind,R_wind] = trenddecomp(Traindata.wind_speed, NumSeasonal=2);

outlierThreshold = mean(R_wind) + 2 * std(R_wind);
outliers_wind = abs(R_wind) > outlierThreshold;

% Replacing outliers with NaNs in wind speed
cleanedData_wind = Traindata.wind_speed;
cleanedData_wind(outliers_wind) = NaN;

figure;
% Original Time Series
subplot(4,1,1);
plot(Traindata.date, Traindata.wind_speed);
title('Original Time Series');
ylabel('Wind Speed');

% Trend Component
subplot(4,1,2);
plot(Traindata.date, LT_wind);
title('Trend Component');
ylabel('Trend');

% Seasonal Component
subplot(4,1,3);
plot(Traindata.date, ST_wind);
title('Seasonal Component');
ylabel('Seasonality');

% Data with Outliers Removed
subplot(4,1,4);
plot(Traindata.date, cleanedData_wind);
title('Data with Outliers Removed');
ylabel('Wind Speed');

xlabel('Date');

% Pressure
[LT_pressure,ST_pressure,R_pressure] = trenddecomp(Traindata.meanpressure, NumSeasonal=2);

outlierThreshold = mean(R_pressure) + 2 * std(R_pressure);
outliers_pressure = abs(R_pressure) > outlierThreshold;

% Replacing outliers with NaNs in pressure
cleanedData_pressure = Traindata.meanpressure;
cleanedData_pressure(outliers_wind) = NaN;

figure;
% Original Time Series
subplot(4,1,1);
plot(Traindata.date, Traindata.meanpressure);
title('Original Time Series');
ylabel('Mean Pressure');

% Trend Component
subplot(4,1,2);
plot(Traindata.date, LT_pressure);
title('Trend Component');
ylabel('Trend');

% Seasonal Component
subplot(4,1,3);
plot(Traindata.date, ST_pressure);
title('Seasonal Component');
ylabel('Seasonality');

% Data with Outliers Removed
subplot(4,1,4);
plot(Traindata.date, cleanedData_pressure);
title('Data with Outliers Removed');
ylabel('Mean Pressure');

xlabel('Date');

