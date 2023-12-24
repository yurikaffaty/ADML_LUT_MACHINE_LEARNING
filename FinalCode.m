clc;
clear all;
close all;
%% Load data
Traindata = readtable('DailyDelhiClimateTrain.csv');
Testdata = readtable('DailyDelhiClimateTest.csv');

tempData_Train = Traindata.meantemp;
tempData_Test = Testdata.meantemp;
%% Check missing values
% There are no missing values for both Train and Test data
missing_train = sum(ismissing(Traindata));
% missing_test = sum(ismissing(Testdata));

%% Data preparation
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

maxEpochs = 200;
miniBatchSize = 64;
learnRate = 1e-3; 
%% LSTM
% LSTM model layers
numChannels = 1;
layers_LSTM = [
    sequenceInputLayer(1) 
    lstmLayer(150) 
    fullyConnectedLayer(1)
    regressionLayer];

options_LSTM = trainingOptions("adam", ...
    'MaxEpochs', maxEpochs, ...
    'MiniBatchSize', miniBatchSize, ...
    'InitialLearnRate', learnRate, ...
    'SequencePaddingDirection', 'left', ...
    'Shuffle', 'never', ... 
    'Plots', 'training-progress', ...
    'Verbose', 0);

% Train LSTM model
tic
net1 = trainNetwork(XTrain_norm', YTrain_norm', layers_LSTM, options_LSTM);
toc

% Prediction for test and training data
YTestHat    = predict(net1, XTest_norm');
YCalHat     = predict(net1, XTrain_norm');

% Plot prediction for test and training data
figure; 
subplot(2,1,1)
%nexttile;
plot(YTest_norm);
hold on 
plot(YTestHat);
hold off
title("Test patition one-ahead predictions");
subplot(2,1,2)
%figure;
%nexttile;
plot(YTrain_norm);
hold on 
plot(YCalHat);
hold off
title("Training patition one-ahead predictions");

%% RMSE for test and train data

% Calculate RMSE for test data
rmseTest = sqrt(mean((YTestHat - YTest_norm').^2));

% Calculate RMSE for training data
rmseTrain = sqrt(mean((YCalHat - YTrain_norm').^2));

% Display RMSE values
disp(['RMSE for Test Data: ' num2str(rmseTest)]);
disp(['RMSE for Training Data: ' num2str(rmseTrain)]);
%% Transform NN 
sequenceLength = 300;
% Parameters
numChannels = 1;
embeddingOutputSize = 1;
maxPosition = sequenceLength+20;

numHeads = 4;

numKeyChannels = numHeads*embeddingOutputSize;
 
% Layer Definition
layers_TNN = [ 
    sequenceInputLayer(numChannels,Name="input")
    positionEmbeddingLayer(embeddingOutputSize,maxPosition,PositionDimension="temporal", Name="positional-embedding");
    additionLayer(2,Name="add")
    selfAttentionLayer(numHeads,numKeyChannels)
    fullyConnectedLayer(1)
    regressionLayer('Name', 'output')];

options_TNN = trainingOptions('adam', ...
    'MaxEpochs', maxEpochs, ...
    'MiniBatchSize', miniBatchSize, ...
    'InitialLearnRate', learnRate, ...
    'SequenceLength', sequenceLength, ...
    'Plots', 'training-progress', ...
    'LearnRateDropFactor', 0.01, ...      
    'LearnRateDropPeriod', 10, ...       
    'Shuffle', 'never', ...              
    'Verbose', 0);

lgraph = layerGraph(layers_TNN);

lgraph = connectLayers(lgraph,"input","add/in2");

figure;
plot(lgraph)

% Train the Transformer model
tic
net = trainNetwork(XTrain_norm', YTrain_norm', lgraph, options_TNN);
toc

% Make predictions on a test sequence
yPrednorm = predict(net, XTest_norm');
yPred = yPrednorm*XTest_sigma+YTest_mu;

figure;
title("Test patition one-ahead predictions");
plot(yPred);
hold on 
plot(YTest);
hold off
legend('Predicted','measured')
xlabel('Days')
ylabel('Temperature');

% Performance
rmse_Transformer_Test_2 = rmse(yPred',YTest)


