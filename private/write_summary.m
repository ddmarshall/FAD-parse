function write_summary(fid, summary, output_type)
%WRITE_ASSIGNMENT write out the summary assignments to the given file ID
%in the specified format

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

  if (strcmp(output_type, 'TSV'))
    write_summary_csv(fid, summary, char(9));
  elseif (strcmp(output_type, 'CSV'))
    write_summary_csv(fid, summary, ',');
  else
    error('Invalid output type:\n-->%s<--', output_type);
  end
end

function write_summary_csv(fid, b, sep)
%WRITE_SUMMARY writes the summary information for department/school

  % write out the department info
  fprintf(fid, 'Campus%c%s\n', sep, b.campus);
  fprintf(fid, 'School%c%s\n', sep, b.school);
  fprintf(fid, 'Department%c%s\n', sep, b.department);
  fprintf(fid, '\n');
  fprintf(fid, 'Report Date%c%s\n', sep, b.date);
  fprintf(fid, 'Academic Date%c%s\n', sep, sprintf('%4d %s', b.year, b.quarter));
  fprintf(fid, '\n');

  % write out totals by time
  if (~isempty(b.by_time))
    fprintf(fid, '\n');
    fprintf(fid, '%c%s', sep, 'Employment Type');
    fprintf(fid, '%c%s', sep, 'Number of Appointments');
    fprintf(fid, '%c%s', sep, 'FTEF');
    fprintf(fid, '%c%s', sep, 'Class WTUs');
    fprintf(fid, '%c%s', sep, 'Supervision WTUs');
    fprintf(fid, '%c%s', sep, 'Direct WTUs');
    fprintf(fid, '%c%s', sep, 'Indirect WTUs');
    fprintf(fid, '%c%s', sep, 'Total WTUs');
    fprintf(fid, '%c%s', sep, 'Direct WTUs per FTEF');
    fprintf(fid, '%c%s', sep, 'Total WTUs per FTEF');
    fprintf(fid, '%c%s', sep, 'SCUs');
    fprintf(fid, '%c%s', sep, 'FTES');
    fprintf(fid, '%c%s', sep, 'SCU per FTEF');
    fprintf(fid, '%c%s', sep, 'Student faculty Ratio');
    fprintf(fid, '\n');
    for (i=1:length(b.by_time))
      write_summary_row(fid, b.by_time(i), sep);
    end
  end
  
  % write out totals by title
  if (~isempty(b.by_title))
    fprintf(fid, '\n');
    fprintf(fid, '%c%s', sep, 'Employment Title');
    fprintf(fid, '%c%s', sep, 'Number of Appointments');
    fprintf(fid, '%c%s', sep, 'FTEF');
    fprintf(fid, '%c%s', sep, 'Class WTUs');
    fprintf(fid, '%c%s', sep, 'Supervision WTUs');
    fprintf(fid, '%c%s', sep, 'Direct WTUs');
    fprintf(fid, '%c%s', sep, 'Indirect WTUs');
    fprintf(fid, '%c%s', sep, 'Total WTUs');
    fprintf(fid, '%c%s', sep, 'Direct WTUs per FTEF');
    fprintf(fid, '%c%s', sep, 'Total WTUs per FTEF');
    fprintf(fid, '%c%s', sep, 'SCUs');
    fprintf(fid, '%c%s', sep, 'FTES');
    fprintf(fid, '%c%s', sep, 'SCU per FTEF');
    fprintf(fid, '%c%s', sep, 'Student faculty Ratio');
    fprintf(fid, '\n');
    for (i=1:length(b.by_title))
      write_summary_row(fid, b.by_title(i), sep);
    end
  end
end

function write_summary_row(fid, br, sep)
  fprintf(fid, '%c%s', sep, br.type);
  fprintf(fid, '%c%d', sep, br.appts);
  fprintf(fid, '%c%.2f', sep, br.ftef);
  fprintf(fid, '%c%.1f', sep, br.direct_wtu);
  fprintf(fid, '%c%.1f', sep, br.supervision_wtu);
  fprintf(fid, '%c%.1f', sep, br.direct_wtu);
  fprintf(fid, '%c%.1f', sep, br.indirect_wtu);
  fprintf(fid, '%c%.1f', sep, br.total_wtu);
  fprintf(fid, '%c%.2f', sep, br.direct_wtu_per_ftef);
  fprintf(fid, '%c%.2f', sep, br.total_wtu_per_ftef);
  fprintf(fid, '%c%.1f', sep, br.scu);
  fprintf(fid, '%c%.1f', sep, br.ftes);
  fprintf(fid, '%c%.2f', sep, br.scu_per_ftef);
  fprintf(fid, '%c%.2f', sep, br.student_per_ftef);
  fprintf(fid, '\n');
end
