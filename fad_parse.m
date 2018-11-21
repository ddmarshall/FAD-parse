function fad_parse(input_name, output_option)
% FAD_PARSE() parses the FAD file
%
% input_name - name of FAD file
% output_options - set of options to control how the FAD data is written
%                  out after processing

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
  
  % need to set the input file name
  if (nargin < 1)
    input_name    = 'sample.fad';
  end
  if (nargin < 2)
    output_option = fad_parse_options();
  end

  % parse the output options
  output = parse_output_option(input_name, output_option);

  % open the input and output files
  [fid_in, msg] = fopen(input_name, 'r');
  if (fid_in < 0)
    error(msg);
  end

  % process the file
  department_record = [];
  done = false;
% FIX: Can have variety of stopping criteria such as:
%        - read only one department assignment
%        - read all department assignments
%        - read only one department summary
%        - read all department summaries
%        - read only one department assignment and summary
%        - read all department assignments and summaries
  while (~done)
    % get next line
    str = fgetl(fid_in);
    while (isempty(str))
      if(isnumeric(str))
        assert(str == -1);
        done = true;
        break;
      end
      str = fgetl(fid_in);
    end
    if(isnumeric(str))
      assert(str == -1);
      done = true;
    end
    
    if (~done)
      % should be getting a header block next from file
      if (str(1) ~= '1')
        error('Expected header block identified line received:\n-->%s<--', str);
      end

      rec = read_records(fid_in, output.verbose);

%       done = strcmp(rec(1).department, '132 ALL SCHOOL');
%       done = strcmp(rec(1).department, '176 CIVIL/ENV ENG');
%       done = strcmp(rec(1).department, '189 COMPUTER SCIENCE');
%       done = strcmp(rec(1).department, '224 BIOMEDICAL ENGINEERING');
%       done = strcmp(rec(1).department, '247 ELECTRICAL ENGINEERING');
%       done = strcmp(rec(1).department, '363 IND ENG');
%       done = strcmp(rec(1).department, '490 MECHANICAL ENG');
%       done = strcmp(rec(1).department, '770 WELDING AND METALLURGICAL ENGINEERING');
        
      % merge these records with the existing assignment or summary records
      if (~done)
        department_record = merge_records(department_record, rec);
      end
    end
  end

  % close files
  fclose(fid_in);
  
  % report records
  [~, ~, ~] = mkdir(output.name);
  
  for (i=1:length(department_record))
    % write out the assignment information
    for (j=1:length(department_record(i).assignment))
      outname = sprintf('%s - %s - %s %c', ...
                        department_record(i).assignment(j).school, ...
                        strrep(department_record(i).assignment(j).department, '/', '+'), ...
                        department_record(i).assignment(j).name.last, ...
                        department_record(i).assignment(j).name.fi);
      if (~isempty(department_record(i).assignment(j).name.mi))
        outname = sprintf('%s %c', outname, department_record(i).assignment(j).name.mi);
      end
      outname = fullfile(output.name, sprintf('%s%s', outname, output.ext));
      fid_out = fopen(outname, 'w');
      write_assignment(fid_out, department_record(i).assignment(j), output.type);
      fclose(fid_out);
    end
    
    % write out the summary information
    outname = sprintf('%s', department_record(i).summary.school);
    if (~isempty(department_record(i).summary.department))
      outname = sprintf('%s - %s', outname, strrep(department_record(i).summary.department, '/', '+'));
    end
    outname = sprintf('%s - Summary', outname);
    outname = fullfile(output.name, sprintf('%s%s', outname, output.ext));
    fid_out = fopen(outname, 'w');
    write_summary(fid_out, department_record(i).summary, output.type);
    fclose(fid_out);
  end
end

function rec = merge_records(rec, rec_add)

  for (i = 1:length(rec_add))
    % get the department for record to add
    dept = rec_add(i).department;

    % find the department in current records (or create new department)
    idx = length(rec)+1;
    for (j = 1:length(rec))
      if (strcmp(dept, rec(j).department))
        idx = j;
        break;
      end
    end

    % append the current record to the department
    if (isempty(rec))
      rec.department = dept;
      if (isfield(rec_add, 'by_time'))
        rec.summary    = rec_add(i);
        rec.assignment = [];
      else
        rec.summary    = [];
        rec.assignment = rec_add(i);
      end
    else
      rec(idx).department = dept;
      if (isfield(rec_add, 'by_time'))
        rec(idx).summary = rec_add(i);
        if (~isfield(rec, 'assignment'))
          rec.assignment = [];
        end
      else
        rec(idx).assignment(end+1) = rec_add(i);
      end
    end
  end
end

function output = parse_output_option(input_name, out_opt)
% parse_output_option parse the output parameters
%
% output - result of this should be output structure with the following elements
%   * to_directory - true if output should be to a directory structure
%   * ext - file extension of output files
%   * type - output file type
%   * name - name of output file or directory
% out_opt - output options to be parsed
% input_name - name of the input file
  
  oo = fad_parse_options();

  % check that a valid output option has been specified and process options
  switch (out_opt.layout)
    case (oo.layout_flag.DIRECTORY_TREE)
      output.to_directory = true;
    case (oo.layout_flag.SINGLE_FILE)
      output.to_directory = false;
    otherwise
      error('Invalid output option flag provided');
  end
  
  % check that ta valid output file format has been specified
  switch (out_opt.output_file_type)
    case (oo.output_file_type_flag.TSV)
      output.ext  = '.tsv';
      output.type = 'TSV';
    case (oo.output_file_type_flag.CSV)
      output.ext  = '.csv';
      output.type = 'CSV';
    otherwise
      error('Invalid output file format provided');
  end
  
  % need to set the output file or directory (depending on output option)
  if (isfield(out_opt, 'output_name'))
    output.name = out_opt.output_name;
  else
    [op, on, ~] = fileparts(input_name);
    if (output.to_directory)
      output.name = fullfile(op, on);
    else
      output.name = fullfile(op, on, output.ext);
    end
  end
  
  % capture the verbose flag
  if (isfield(out_opt, 'verbose'))
    output.verbose = out_opt.verbose;
  else
    output.verbose = oo.verbose;
  end
end
