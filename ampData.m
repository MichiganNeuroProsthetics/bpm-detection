function [ampData] = ampData(data, fs, sSize)
%ampData takes in .wav or .m4a file data and outputs amplitude data for samples
%with size sSize
%   Detailed explanation goes here

%% Make a fft for each time sample and store in an array
for i = 1:(length(data) / sSize)
   % Much of the antics here are due to 1 indexing...
   sample = data([(((i - 1) * sSize) + 1):(i * sSize)], 1);
   [~, singleSided] = fftProcess(sample, length(sample), fs);
   ampData(:,i) = singleSided;
end

end