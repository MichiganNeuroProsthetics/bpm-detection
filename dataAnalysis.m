function [meanError, medError, modeError, meanBigError, medBigError, modeBigError, settingTest, averageError, difficulty] = dataAnalysis(meanExpBPM, medExpBPM, modeExpBPM, actBPM)
%dataAnalysis Takes experimental and theoretical BPM data for various
%settings and returns analysis on data
%   Detailed explanation goes here
%% Calculate Error
% Row: song
% Column: Threshold
% Plane: Resolution

meanDifferences = meanExpBPM - actBPM;
medDifferences = medExpBPM - actBPM;
modeDifferences = modeExpBPM - actBPM;

meanError = 100 .* abs(meanDifferences) ./ actBPM;
medError = 100 .* abs(medDifferences) ./ actBPM;
modeError = 100 .* abs(modeDifferences) ./ actBPM;

% Adjust Error that is for values twice too big
for i = 1:size(meanError, 1)
    for j = 1:size(meanError, 2)
        for k = 1:size(meanError, 3)
            if meanError(i,j,k) > 80
                meanExpBPM(i,j,k) = 0.5 * meanExpBPM(i,j,k);
                meanDifferences(i,j,k) = meanExpBPM(i,j,k) - actBPM(i,j,k);
                meanError(i,j,k) = 100 .* abs(meanDifferences(i,j,k)) ./ actBPM(i,j,k);
            end

            if medError(i,j,k) > 80
                medExpBPM(i,j,k) = 0.5 * medExpBPM(i,j,k);
                medDifferences(i,j,k) = medExpBPM(i,j,k) - actBPM(i,j,k);
                medError(i,j,k) = 100 .* abs(medDifferences(i,j,k)) ./ actBPM(i,j,k);
            end

            if modeError(i,j,k) > 80
                modeExpBPM(i,j,k) = 0.5 * modeExpBPM(i,j,k);
                modeDifferences(i,j,k) = modeExpBPM(i,j,k) - actBPM(i,j,k);
                modeError(i,j,k) = 100 .* abs(modeDifferences(i,j,k)) ./ actBPM(i,j,k);
            end
        end
    end
end

%% Find Where the Function was innaccurate or Failed
% Row: song
% Column: Threshold
% Plane: Resolution

meanBigError = zeros(size(meanError, 1), size(meanError, 2), size(meanError, 3));
medBigError = meanBigError;
modeBigError = meanBigError;
bigErrorPercent = 5;

for i = 1:size(meanError, 1)
    for j = 1:size(meanError, 2)
        for k = 1:size(meanError, 3)
            if meanError(i, j, k) > bigErrorPercent || isnan(meanError(i, j, k))
                meanBigError(i, j, k) = 1;
            end
            if medError(i, j, k) > bigErrorPercent || isnan(medError(i, j, k))
                medBigError(i, j, k) = 1;
            end
            if modeError(i, j, k) > bigErrorPercent || isnan(modeError(i, j, k))
                modeBigError(i, j, k) = 1;
            end
        end
    end
end

%% Count the NaN Values for Each Resolution & Threshold
% Row: Threshold
% Column: Resolution
% Plane 1: Mean
% Plane 2: Median
% Plane 3: Mode

nanCounts = zeros(size(meanError, 2), size(meanError, 3), 3);
for j = 1:size(meanError, 2)
    for k = 1:size(meanError, 3)
        nanCount1 = 0;
        nanCount2 = 0;
        nanCount3 = 0;

        for i = 1:size(meanError, 1)
            if isnan(meanError(i, j, k))
                nanCount1 = nanCount1 + 1;
            end
            if isnan(medError(i, j, k))
                nanCount2 = nanCount2 + 1;
            end
            if isnan(modeError(i, j, k))
                nanCount3 = nanCount3 + 1;
            end
        end
        nanCounts(j, k, 1) = nanCount1;
        nanCounts(j, k, 2) = nanCount2;
        nanCounts(j, k, 3) = nanCount3;
    end
end

%% Find Percent of Time that Song Failed
% Row: Song
% Column 1: Mean Errors
% Column 2: Median Errors
% Column 3: Mode Errors

difficulty = zeros(size(meanError, 1), 3);
for i = 1:size(meanError, 1)
    difficulty(i, 1) = 100 * sum(sum(meanBigError(i, :, :))) / (size(meanError, 2) * size(meanError, 3));
    difficulty(i, 2) = 100 * sum(sum(medBigError(i, :, :))) / (size(meanError, 2) * size(meanError, 3));
    difficulty(i, 3) = 100 * sum(sum(modeBigError(i, :, :))) / (size(meanError, 2) * size(meanError, 3));
end

%% Find Average Error and Test Each Setting
% Row: Threshold
% Column: Resolution
% Plane 1: Mean
% Plane 2: Median
% Plane 3: Mode

settingTest = zeros(size(meanError, 2), size(meanError, 3), 3);
averageError = settingTest;
for i = 1:size(meanError, 2)
    for j = 1:size(meanError, 3)
        settingTest(i, j, 1) = sum(meanBigError(:, i, j));
        settingTest(i, j, 2) = sum(medBigError(:, i, j));
        settingTest(i, j, 3) = sum(modeBigError(:, i, j));
        averageError(i, j, 1) = sum(meanError(:, i, j), 'omitnan') / (size(meanError, 1) - nanCounts(i, j, 1));
        averageError(i, j, 2) = sum(medError(:, i, j), 'omitnan') / (size(medError, 1) - nanCounts(i, j, 2));            
        averageError(i, j, 3) = sum(modeError(:, i, j), 'omitnan') / (size(modeError, 1) - nanCounts(i, j, 3));
    end
end

% %% Find the Optimal Setting for each Song
% % Row: Song
% % Column 1: Threshold
% % Column 2: Resolution
% % Column 3: Percent Error
% % Plane 1: Mean Error
% % Plane 2: Median Error
% % Plane 3: Mode Error
% 
% bestSetting = zeros(size(meanError, 1), 3, 3);
% for i = 1:size(meanError, 1)
%     bestError = 100;
%     for j = 1:size(meanError, 2)
%         for k = 1:size(meanError, 3)
%             if meanError(i, j, k) < bestError
%                 bestSetting(i, 1, 1) = j;
%                 bestSetting(i, 2, 1) = k;
%                 bestSetting(i, 3, 1) = meanError(i, j, k);
%                 bestError = meanError(i, j, k);
%             end
% 
%             if medError(i, j, k) < bestError
%                 bestSetting(i, 1, 2) = j;
%                 bestSetting(i, 2, 2) = k;
%                 bestSetting(i, 3, 2) = medError(i, j, k);
%                 bestError = medError(i, j, k);
%             end
% 
%             if modeError(i, j, k) < bestError
%                 bestSetting(i, 1, 3) = j;
%                 bestSetting(i, 2, 3) = k;
%                 bestSetting(i, 3, 3) = modeError(i, j, k);
%                 bestError = modeError(i, j, k);
%             end
%         end
%     end
% end
% 
end