function [F, columnsn, rowsm, minx, maxx, miny, maxy, minf, maxf]=readSRF_ASCIIgrid(fnamegrid)
% function for Surfer ASCII grid (DSAA) input
% input into the function: is only the filename of the ASCII SRF gid
% output from the function: F(matrix with the reader grid), columnsn, rowsm, minx, maxx, miny, maxy, minf, maxf
%
% Original Author: Roman Pasteka (October 2024)
% Included in this repository with the permission of the author.
% This file is distributed under the MIT License (see LICENSE file).

fid = fopen(fnamegrid,'r');
% reading of the GS ASCII grid header (rows, columns, minx, maxx, miny, maxy, minf, maxf)
tline = fgetl(fid); row1 = tline;
tline = fgetl(fid); row2 = tline; [token,rem] = strtok(row2);
rowsm = str2double(token); columnsn = str2double(rem);
tline = fgetl(fid); row3 = tline; [token,rem] = strtok(row3);
minx = str2double(token); maxx = str2double(rem);
tline = fgetl(fid); row4 = tline; [token,rem] = strtok(row4);
miny = str2double(token); maxy = str2double(rem);
tline = fgetl(fid); row5 = tline; [token,rem] = strtok(row5);
minf = str2double(token); maxf = str2double(rem);
% reading of the main field of the grid - into the matrix A
[A,count] = fscanf(fid,'%f',[rowsm,columnsn]);
status = fclose(fid);
F = A';
% size of the readed matrix: columnsn x rowsm
[columnsn,rowsm] = size(A);




