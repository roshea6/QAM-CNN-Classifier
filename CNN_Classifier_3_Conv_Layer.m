%Ryan O'Shea
%CNN Classifier

%Training and testing data are stored in the local directories "Data" and
%"Testing. This data could also be split up manually using [trainingSet,validationSet] = splitEachLabel(imageDataStore,percent to put in trainingSet,'randomize');
%Two different directories were made manually so I could easily show
%examples of the spectrograms and the features extracted from them for a
%better understanding of what the prrogram is actually doing

%Define directories where training data is stored
DataDir = fullfile('Data')
ValDir = fullfile('Testing')

% |imageDatastore| recursively scans the directory tree containing the images. Folder names are automatically used as labels for each image.
trainingSet = imageDatastore(DataDir, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');

validationSet = imageDatastore(ValDir, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');

%Uncomment this if all data is going to be stored in one directory instead
%of split manually between training and testing
%[trainingSet,validationSet] = splitEachLabel(trainingSet,.9,'randomize');

%Show the breakdown of the Data directory
labelCount = countEachLabel(trainingSet)

%Get the size of the images
img = readimage(trainingSet,1);
imgSize = size(img)

%Define the layers of the CNN
layers = [
    imageInputLayer(imgSize)
    
    convolution2dLayer(3,8,'Padding',3)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,16,'Padding',3)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,32,'Padding',3)
    batchNormalizationLayer
    reluLayer
    
    fullyConnectedLayer(3)
    softmaxLayer
    classificationLayer];



%Specify the training options. The validationSet will be used to validate
%the model

%Reducing the MiniBatchSize to 64 was necessary to prevent my GTX 1070 from
%running out of memory during training
options = trainingOptions('sgdm', ...
    'InitialLearnRate',0.01, ...
    'MaxEpochs',4, ...
    'Shuffle','every-epoch', ...
    'ValidationData',validationSet, ...
    'ValidationFrequency',30, ...
    'Verbose',false, ...
    'MiniBatchSize',64, ...
    'Plots','training-progress');

%Create the model
net = trainNetwork(trainingSet,layers,options);

%Test the accuracy of the model
YPred = classify(net,validationSet);
YValidation = validationSet.Labels;

accuracy = sum(YPred == YValidation)/numel(YValidation)

%To save the trained Network call "save net" or set a variable such as
%TrainedNet = to net and then call "save TrainedNet"

%To load the trained network into a workspace call "load TrainedNet_3Conv"

%To use the trained network to classify spectrogram images call
%classify(TrainedNet, imread("nameOfLocalFile.jpg")) or classify(TrainedNet, readimage(YourImageDataStore, indexOfImage))
