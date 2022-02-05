function [BPM1, BPM2, BPM3] = BPMCalculate(data, fs, sSize, threshold, setting)
%BPMCalculate reads in a song in a .wav file and calculates its BPM 
%   Detailed explanation goes here

%% Process Data
if setting == 1
    ampValues = ampData(data,fs,sSize);

else
    for i = 1:(length(data) / sSize)
        % Much of the antics here are due to 1 indexing...
        sample = data([(((i - 1) * sSize) + 1):(i * sSize)], 1);
        sample = abs(sample);
        ampValues(:,i) = sample;
    end
end

sample2Time = sSize / fs;

%% Find Peaks
sumVec = sum(ampValues, 1);

sumChangeVec = zeros(length(sumVec),1);
for i = 2:length(sumVec)
    sumChangeVec(i) = sumVec(i) - sumVec(i - 1);
end

peaks = zeros(length(sumChangeVec));
for i = 1:length(sumChangeVec)
    if sumChangeVec(i) > threshold
        peaks(i) = 1;
    end
end

peakIndices = find(peaks);
if isempty(peakIndices) || length(peakIndices) == 1 || length(peakIndices) == 2
    BPM1 = nan;
    BPM2 = nan;
    BPM3 = nan;
    return;
end

extraDistance = 0;
nextIndex = 1;
for i = 2:length(peakIndices)
    % Special case where distance between is 1
    if peakIndices(i) - peakIndices(i-1) == 1
        extraDistance = extraDistance + 1;
        continue
    end
    
    % Special case where extra distance needs to be added on
    if extraDistance ~= 0
        % Add on extra distance from previous 1s
        peakIndices(i) = peakIndices(i) + extraDistance;
        peakSampleDist(nextIndex) = peakIndices(i) - peakIndices(i-1);

        % Remove that extra distance so it doesn't affect future points
        peakIndices(i) = peakIndices(i) - extraDistance;
        extraDistance = 0;
        nextIndex = nextIndex + 1;
        continue
    end

    peakSampleDist(nextIndex) = peakIndices(i) - peakIndices(i-1);
    nextIndex = nextIndex + 1;
end

%% Convert peakSampleDist to peakBPMs
peakTimeDist = peakSampleDist .* sample2Time;

peakBPMs = zeros(length(peakTimeDist),1);
for i = 1:length(peakTimeDist)
    peakBPMs(i) = (peakTimeDist(i) ^ (-1)) * 60;
end

% Convert BPMs to BPMs between 75 and 150
i = 1;
while i < length(peakBPMs) + 1
    if peakBPMs(i) > 150
        peakBPMs(i) = peakBPMs(i) / 2;

    elseif peakBPMs(i) < 75
        peakBPMs(i) = peakBPMs(i) * 2;

    else
        i = i + 1;
    end
end

BPM1 = mean(peakBPMs);
BPM2 = median(peakBPMs);
BPM3 = mode(peakBPMs);

end