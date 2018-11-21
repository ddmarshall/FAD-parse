function rec = read_records(fid, verbose)
% READ_RECORDS reads a block of records from the FAD file and return
% records along with other information about the records
%
% rec - vector of records
% eof - true if at the end of the input file
% fid - file id for the input file
% verbose - flag indicating whether additional data checks should be
%           reported

% Copyright (c) 2018 David D. Marshall <ddmarsha@calpoly.edu>
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Lesser General Public License for more details.
% 
% You should have received a copy of the GNU Leser General Public License
% along with this software.  If not, see <http://www.gnu.org/licenses/>.

  % extract header information
  h = extract_page_header(fid);
  
  % continue to extract records until get blank line
  if (h.summary)
    rec = extract_summary_records(fid, h, verbose);
  else
    rec = extract_instructor_records(fid, h, verbose);
  end
end
