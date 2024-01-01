function [t, chanels] = readRigolBin(inputFilename)
%% Входной параметр имя файла, возвращает кортеж из вектора времени и каналов (матрица где в строках каналы, в столбцах - значения каналов)

% based on https://www.mathworks.com/matlabcentral/fileexchange/11854-agilent-scope-waveform-bin-file-binary-reader

if (~exist(inputFilename))
    error('inputFilename missing.');
end

fileId = fopen(inputFilename, 'r');
% read file header
fileCookie = fread(fileId, 2, 'char'); % первые два байта/символа - обозначение кто записал файл, RG - наш осцилограф
fileVersion = fread(fileId, 2, 'char'); % версия файла, у нас всегда 01
fileSize = fread(fileId, 1, 'int32');
nWaveforms = fread(fileId, 1, 'int32');
fprintf("В фаиле %s %d каналов", inputFilename, nWaveforms)

% проверка что это и правда данные с осцилографа, а не просто какой-то случайный файл
fileCookie = char(fileCookie');
if (~strcmp(fileCookie, 'RG'))
    fclose(fileId);
    error('Unrecognized file format.');
end

for waveformIndex = 1:nWaveforms
    % read waveform header
    headerSize = fread(fileId, 1, 'int32');
    bytesLeft = headerSize - 4;
    waveformType = fread(fileId, 1, 'int32'); bytesLeft = bytesLeft - 4;
    nWaveformBuffers = fread(fileId, 1, 'int32'); bytesLeft = bytesLeft - 4;
    nPoints = fread(fileId, 1, 'int32'); bytesLeft = bytesLeft - 4;
    count = fread(fileId, 1, 'int32');  bytesLeft = bytesLeft - 4;
    xDisplayRange = fread(fileId, 1, 'float32');  bytesLeft = bytesLeft - 4;
    xDisplayOrigin = fread(fileId, 1, 'double');  bytesLeft = bytesLeft - 8;
    xIncrement = fread(fileId, 1, 'double');  bytesLeft = bytesLeft - 8;
    xOrigin = fread(fileId, 1, 'double');  bytesLeft = bytesLeft - 8;
    xUnits = fread(fileId, 1, 'int32');  bytesLeft = bytesLeft - 4;
    yUnits = fread(fileId, 1, 'int32');  bytesLeft = bytesLeft - 4;
    dateString = fread(fileId, 16, 'char'); bytesLeft = bytesLeft - 16;
    timeString = fread(fileId, 16, 'char'); bytesLeft = bytesLeft - 16;
    frameString = fread(fileId, 24, 'char'); bytesLeft = bytesLeft - 24;
    waveformString = fread(fileId, 16, 'char'); bytesLeft = bytesLeft - 16;
    timeTag = fread(fileId, 1, 'double'); bytesLeft = bytesLeft - 8;
    segmentIndex = fread(fileId, 1, 'uint32'); bytesLeft = bytesLeft - 4;
    % skip over any remaining data in the header
    fseek(fileId, bytesLeft, 'cof');
    % generate time vector from xIncrement and xOrigin values
    t = (xIncrement * [0:(nPoints-1)]') + xOrigin; % допущение - все каналы имеют одинаковое время

    for bufferIndex = 1:nWaveformBuffers
        % read waveform buffer header
        headerSize = fread(fileId, 1, 'int32');
        bytesLeft = headerSize - 4;
        bufferType = fread(fileId, 1, 'int16'); bytesLeft = bytesLeft - 2;
        bytesPerPoint = fread(fileId, 1, 'int16'); bytesLeft = bytesLeft - 2;
        bufferSize = fread(fileId, 1, 'int32'); bytesLeft = bytesLeft - 4;
        % skip over any remaining data in the header
        fseek(fileId, bytesLeft, 'cof');
        if ((bufferType == 1) | (bufferType == 2) | (bufferType == 3))
            % bufferType is PB_DATA_NORMAL, PB_DATA_MIN, or PB_DATA_MAX (float)
            voltageVector(:, bufferIndex) = fread(fileId, nPoints, 'float');
        elseif (bufferType == 4)
            % bufferType is PB_DATA_COUNTS (int32)
            voltageVector(:, bufferIndex) = fread(fileId, nPoints, '*int32');
        elseif (bufferType == 5)
            % bufferType is PB_DATA_LOGIC (int8)
            voltageVector(:, bufferIndex) = fread(fileId, nPoints, '*uint8');
        else
            % unrecognized bufferType read as unformated bytes
            voltageVector(:, bufferIndex) = fread(fileId, bufferSize, '*uint8');
        end
        chanels (:, waveformIndex) = voltageVector;
    end
end
fclose(fileId);