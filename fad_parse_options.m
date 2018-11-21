function opts = fad_parse_options()
% FAD_PARSE_OPTIONS() returns the default options structure

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

  % output option flag values
  opts.layout_flag.DIRECTORY_TREE = 1;
  opts.layout_flag.SINGE_FILE = 2;
  opts.output_file_type_flag.TSV = 1;
  opts.output_file_type_flag.CSV = 2;

  % build option structure
  opts.output_file_type = opts.output_file_type_flag.TSV;
  opts.layout = opts.layout_flag.DIRECTORY_TREE;
  opts.verbose = true;
end

