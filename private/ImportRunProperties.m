function rp = ImportRunProperties(filename, startRow, endRow)
%IMPORTFILE1 Import numeric data from a text file as a matrix.
%   RUN1 = IMPORTFILE1(FILENAME) Reads data from text file FILENAME for the
%   default selection.
%
%   RUN1 = IMPORTFILE1(FILENAME, STARTROW, ENDROW) Reads data from rows
%   STARTROW through ENDROW of text file FILENAME.
%
% Example:
%   run1 = importfile1('run.properties', 1, 324);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2019/09/24 15:04:52

%% Initialize variables.
delimiter = {' : '};
if nargin<=2
    startRow = 1;
    endRow = inf;
end

%% Format for each line of text:
%   column1: text (%q)
%	column2: text (%q)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%q%q%[^\n\r]';

%% Open the text file.
if ~exist(filename)
    error('rp file %s DNE. Terminal',filename)
end
fileID = fopen(filename,'r');

%% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'TextType', 'char', 'HeaderLines', startRow(1)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'TextType', 'string', 'HeaderLines', startRow(block)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Create output variable
rp = table(dataArray{1:end-1}, 'VariableNames', {'Key','Value'});
%f=fields(rp);
