function [freqVec, singleSided] = fftProcess(data, recordLength, fs)
%fftProcess Takes in sound data and returns fast fourier transformed data
dataFFT = fft(data);
twoSided = abs(dataFFT ./ recordLength); % Two sided spectrum
singleSided = twoSided(1:floor(recordLength/2 + 1)); % Remove negative frequency peaks
singleSided(2:(end - 1)) = 2 .* singleSided(2:(end - 1));

freqVec = fs .* (0:recordLength/2) / recordLength;
end