clc; clear all; close all;

%% Import data
Traindata = readtable('DailyDelhiClimateTrain.csv');
% Testdata = readtable('DailyDelhiClimateTest.csv');

%% Check missing values
% There are no missing values for both Train and Test data
missing_train = sum(ismissing(Traindata));
% missing_test = sum(ismissing(Testdata));

%% Visualization each variable(meantemp,humidity,wind_speed,meanpressure) over the time
% Meantemp over the time
figure;
subplot(2,2,1)
plot(Traindata.date,Traindata.meantemp)
title('Mean temperature over time')
ylabel('Mean temperature')

% Humidity over the time
subplot(2,2,2)
plot(Traindata.date,Traindata.humidity)
title('Humidity value over time')
ylabel('Humidity')

% Wind speed over the time
subplot(2,2,3)
plot(Traindata.date,Traindata.wind_speed)
title('Wind speed measured over time')
ylabel('Wind speed')

% Mean pressure over the time
subplot(2,2,4)
plot(Traindata.date,Traindata.meanpressure)
title('Pressure reading of weather over time')
ylabel('Mean pressure')

%% Distribution Plots using histograms
figure;
subplot(2,2,1)
histogram(Traindata.meantemp);
title('Distribution of Mean Temperature');

subplot(2,2,2)
histogram(Traindata.humidity);
title('Distribution of Humidity');

subplot(2,2,3)
histogram(Traindata.wind_speed);
title('Distribution of Wind Speed');

subplot(2,2,4)
histogram(Traindata.meanpressure);
title('Distribution of Mean Pressure');

%% Visualization each variables over the month
% Convert the 'Date' column to datetime format
Traindata.Date = datetime(Traindata.date, 'Format', 'yyyy-MM-dd');

% Extract month from the date
Traindata.Month = month(Traindata.Date);

% Group data by month and calculate the mean for each month
monthlyData = varfun(@mean, Traindata, 'GroupingVariables', 'Month');

% Plot data of each column over the month
figure;

% Temperature
subplot(2,2,1);
bar(monthlyData.Month, monthlyData.mean_meantemp);
title('Mean Temperature Over Months');
xlabel('Month');
ylabel('Mean Temperature');

% Humidity
subplot(2,2,2);
bar(monthlyData.Month, monthlyData.mean_humidity);
title('Humidity value Over Months')
xlabel('Month');
ylabel('Humidity');

% Wind speed
subplot(2,2,3);
bar(monthlyData.Month, monthlyData.mean_wind_speed);
title('Wind speed Over Months');
xlabel('Month');
ylabel('wind speed');

% Pressure
subplot(2, 2, 4);
bar(monthlyData.Month, monthlyData.mean_meanpressure);
title('Mean pressure Over Months');
xlabel('Month');
ylabel('Mean pressure');

%% Decompose the data into trend, seasonal, and residual components
% Mean Temperature
[LT_temp,ST_temp,R_temp] = trenddecomp(Traindata.meantemp, NumSeasonal=2);
figure;
subplot(3,1,1)
plot(LT_temp)
title('Trend of Mean Temperature');

subplot(3,1,2)
plot(ST_temp)
title('Seasonal of Mean Temperature');

subplot(3,1,3)
plot(R_temp)
title('Residual of Mean Temperature');

% humidity
[LT_humidity,ST_humidity,R_humidity] = trenddecomp(Traindata.humidity, NumSeasonal=2);
figure;
subplot(3,1,1)
plot(LT_humidity)
title('Trend of humidity');

subplot(3,1,2)
plot(ST_humidity)
title('Seasonal of humidity');

subplot(3,1,3)
plot(R_humidity)
title('Residual of humidity');

% Wind speed
[LT_wind,ST_wind,R_wind] = trenddecomp(Traindata.wind_speed, NumSeasonal=2);
figure;
subplot(3,1,1)
plot(LT_wind)
title('Trend of wind');

subplot(3,1,2)
plot(ST_wind)
title('Seasonal of wind');

subplot(3,1,3)
plot(R_wind)
title('Residual of wind');

% Pressure
[LT_pressure,ST_pressure,R_pressure] = trenddecomp(Traindata.meanpressure, NumSeasonal=2);
figure;
subplot(3,1,1)
plot(LT_pressure)
title('Trend of pressure');

subplot(3,1,2)
plot(ST_pressure)
title('Seasonal of pressure');

subplot(3,1,3)
plot(R_pressure)
title('Residual of pressure');

%% Autocorrelation
figure;
subplot(2,2,1)
autocorr(Traindata.meantemp);
title('Autocorrelation of Mean Temperature');

subplot(2,2,2)
autocorr(Traindata.humidity);
title('Autocorrelation of Humidity');

subplot(2,2,3)
autocorr(Traindata.wind_speed);
title('Autocorrelation of Wind speed');

subplot(2,2,4)
autocorr(Traindata.meanpressure);
title('Autocorrelation of Mean Pressure');

%% Correlation Matrix
correlation_matrix = corrcoef(Traindata{:, {'meantemp', 'humidity', 'wind_speed', 'meanpressure'}});
figure;
heatmap({'Mean Temperature', 'Humidity', 'Wind Speed', 'Mean Pressure'}, {'Mean Temperature', 'Humidity', 'Wind Speed', 'Mean Pressure'}, correlation_matrix, 'Colormap', parula, 'ColorLimits', [-1 1], 'Title', 'Correlation Matrix');

%% Rolling Mean
window_size = 7; % We assume that our data has daily frequency
Traindata.meantemp_rolling = movmean(Traindata.meantemp, window_size);
Traindata.humidity_rolling = movmean(Traindata.humidity, window_size);
Traindata.wind_rolling = movmean(Traindata.wind_speed, window_size);
Traindata.pressure_rolling = movmean(Traindata.meanpressure, window_size);

% Plotting the Rolling Mean
figure;
subplot(2,2,1)
plot(Traindata.date, Traindata.meantemp, 'LineWidth', 1.5, 'DisplayName', 'Mean Temperature');
hold on;
plot(Traindata.date, Traindata.meantemp_rolling, 'r', 'LineWidth', 2, 'DisplayName', 'Rolling Mean');
title('Mean Temperature and Rolling Mean');
xlabel('Date');
ylabel('Mean Temperature');
legend('show');

subplot(2,2,2)
plot(Traindata.date, Traindata.humidity, 'LineWidth', 1.5, 'DisplayName', 'Humidity');
hold on;
plot(Traindata.date, Traindata.humidity_rolling, 'r', 'LineWidth', 2, 'DisplayName', 'Rolling Mean');
title('Humidity and Rolling Mean');
xlabel('Date');
ylabel('Humidity');
legend('show');

subplot(2,2,3)
plot(Traindata.date, Traindata.wind_speed, 'LineWidth', 1.5, 'DisplayName', 'Wind speed');
hold on;
plot(Traindata.date, Traindata.wind_rolling, 'r', 'LineWidth', 2, 'DisplayName', 'Rolling Mean');
title('Wind speed and Rolling Mean');
xlabel('Date');
ylabel('Wind speed');
legend('show');

subplot(2,2,4)
plot(Traindata.date, Traindata.meanpressure, 'LineWidth', 1.5, 'DisplayName', 'Mean Pressure');
hold on;
plot(Traindata.date, Traindata.pressure_rolling, 'r', 'LineWidth', 2, 'DisplayName', 'Rolling Mean');
title('Mean Pressure and Rolling Mean');
xlabel('Date');
ylabel('Mean Pressure');
legend('show');

%% K-Means Clustering
% We assume that one year has 4 quarters, so we decided to use k=4.
k = 4;
[idx_temp, centroids_temp] = kmeans(Traindata.meantemp,k);
[idx_humidity, centroids_humidity] = kmeans(Traindata.humidity,k);
[idx_wind, centroids_wind] = kmeans(Traindata.wind_speed,k);
[idx_pressure, centroids_pressure] = kmeans(Traindata.meanpressure,k);

figure;
subplot(2,2,1)
scatter(Traindata.date, Traindata.meantemp, 20, idx_temp, 'filled');
title('Clustering of Mean Temperature');
xlabel('Time');
ylabel('Mean Temperature');
colormap(lines(4));
colorbar

subplot(2,2,2)
scatter(Traindata.date, Traindata.humidity, 20, idx_humidity, 'filled');
title('Clustering of Humidity');
xlabel('Time');
ylabel('Humidity');
colormap(lines(4));
colorbar

subplot(2,2,3)
scatter(Traindata.date, Traindata.wind_speed, 20, idx_wind, 'filled');
title('Clustering of Wind');
xlabel('Time');
ylabel('Wind');
colormap(lines(4));
colorbar

subplot(2,2,4)
scatter(Traindata.date, Traindata.meanpressure, 20, idx_pressure, 'filled');
title('Clustering of Mean Pressure');
xlabel('Time');
ylabel('Mean Pressure');
colormap(lines(4));
colorbar



