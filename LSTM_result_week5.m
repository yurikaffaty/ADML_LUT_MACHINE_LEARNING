clc;
clear all;
close all;

%% Import data
Traindata = readtable('DailyDelhiClimateTrain.csv');
Testdata = readtable('DailyDelhiClimateTest.csv');

tempData_Train = Traindata.meantemp;
tempData_Test = Testdata.meantemp;

%% LSTM model 
% Data preprocessing for training data
XTrain = tempData_Train(1:end-1);
YTrain = tempData_Train(2:end);
[XTrain_norm, XTrain_mu, XTrain_sigma] = zscore(XTrain);
[YTrain_norm, YTrain_mu, YTrain_sigma] = zscore(YTrain);

% Data preprocessing for test data 
XTest = tempData_Test(1:end-1);
YTest = tempData_Test(2:end);
[XTest_norm, XTest_mu, XTest_sigma] = zscore(XTest);
[YTest_norm, YTest_mu, YTest_sigma] = zscore(YTest);


% LSTM model layers
numChannels = 1;
layers = [
    sequenceInputLayer(1) 
    lstmLayer(150)
    fullyConnectedLayer(1)
    regressionLayer];

% Training options
options = trainingOptions("adam", ...
    'MaxEpochs', 250, ...
    'SequencePaddingDirection', 'left', ...
    'Shuffle', 'every-epoch', ...
    'Plots', 'training-progress', ...
    'Verbose', 0);

% Train LSTM model
tic
net = trainNetwork(XTrain_norm', YTrain_norm', layers, options);
toc

% Prediction for test and training data
YTestHat    = predict(net, XTest_norm');
YCalHat     = predict(net, XTrain_norm');

% Plot prediction for test and training data
figure; 
nexttile;
plot(YTest_norm);
hold on 
plot(YTestHat);
title("Test patition one-ahead predictions");

nexttile;
plot(YTrain_norm);
hold on 
plot(YCalHat);
title("Training patition one-ahead predictions");

%% RMSE for test and train data

% Calculate RMSE for test data
rmseTest = sqrt(mean((YTestHat - YTest_norm').^2));

% Calculate RMSE for training data
rmseTrain = sqrt(mean((YCalHat - YTrain_norm').^2));

% Display RMSE values
disp(['RMSE for Test Data: ' num2str(rmseTest)]);
disp(['RMSE for Training Data: ' num2str(rmseTrain)]);



