clear; close all;
% Optimal Setting: Threshold: 0.0920 Resolution: 960

% %% Resolution Test 1
% [data, fs] = audioread("102ByAndBy.m4a");
% actBPM = 102;
% 
% resolutions = [1080, 1200, 1320, 1440, 1560, 1680, 1800, 2040, 2160, 2280, 2400];
% for j = 1:length(resolutions)
%
% Setting 1
%    ampValues = ampData(data,fs,sSize);
% 
% Setting 2
%     ampValues = zeros(resolutions(j), floor(length(data) / resolutions(j)));
%     for i = 1:(length(data) / resolutions(j))
%         % Much of the antics here are due to 1 indexing...
%         sample = data([(((i - 1) * resolutions(j)) + 1):(i * resolutions(j))], 1);
%         sample = abs(sample);
%         ampValues(:,i) = sample;
%     end
% 
%     % Data Processing
%     sumVec = sum(ampValues, 1);
% 
%     sumChangeVec = zeros(length(sumVec),1);
%     for i = 2:length(sumVec)
%         sumChangeVec(i) = sumVec(i) - sumVec(i - 1);
%     end
% 
%     sample2Time = resolutions(j) / fs;
%     sampleTimeVec = [1:size(ampValues, 2)] .* sample2Time;
% 
%     % This is solely for testing and not part of the actual algorithm
%     sampleBPMVec = sampleTimeVec .* actBPM ./ 60;
% 
%     figure();
%     plot(sampleBPMVec, sumChangeVec);
%     axis([2.5, 12, 0, 20]);
% end

%% Resolution Test 2
resolutions = [1080, 1200, 1320, 1440, 1560, 1680, 1800, 2040, 2160, 2280, 2400];
songList = ["75LeanOnMe", "77Power", "78NoWoman", "82Hopeless", "86Blinding", ...
    "98TheMan", "102ByAndBy", "104InMyLife", "107Snow", "114Rainbow", ...
    "116IceIceBaby", "120ProveIt", "121Talk", "128September", "137LetItBe", ...
    "140RadioNW", "142AllLights"];
numSongs = length(songList);
for i = 1:numSongs
    songList(i) = songList(i) + ".m4a";
end

% Threshold Vector
starts = [3, 2, 2, 2, 2, 2, 4, 4, 4, 4, 4];
ends = [8, 8, 8, 12, 10, 10, 12, 15, 12, 12, 12];
numThreshValues = 11;
threshold = zeros(numThreshValues, length(resolutions));
for j = 1:numThreshValues
    for k = 1:length(resolutions)
        threshold(j, k) = starts(k) + ((ends(k) - starts(k)) * (j - 1) / (numThreshValues - 1));
    end
end

meanExpBPM = zeros(numSongs,numThreshValues,length(resolutions));
medExpBPM = meanExpBPM;
modeExpBPM = medExpBPM;

% Actual BPM Vector
actBPM = zeros(numSongs, numThreshValues, length(resolutions));
actBPMplane = zeros(numSongs,numThreshValues);
for j = 1:numThreshValues
    actBPMplane(:,j) = [75, 77, 78, 82, 86, 98, 102, 104, 107, 114, 116, 120, 121, 128, 137, 140, 142];
end

for j = 1:length(resolutions)
    actBPM(:,:,j) = actBPMplane;
end

for i = 1:numSongs
    [data, fs] = audioread(songList(i));
    %data = data(1:2000000);
    for j = 1:numThreshValues
        for k = 1:length(resolutions)
            [meanExpBPM(i,j,k), medExpBPM(i,j,k), modeExpBPM(i,j,k)] = ...
                BPMCalculate(data, fs, resolutions(k), threshold(j, k), 1);
        end
    end
end

%% Data Analysis
[meanError, medError, modeError, meanBigError, medBigError, modeBigError, ...
    settingTest, averageError, difficulty] = ...
    dataAnalysis(meanExpBPM, medExpBPM, modeExpBPM, actBPM);
