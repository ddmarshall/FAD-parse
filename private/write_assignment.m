function write_assignment(fid, assignment, output_type)
%WRITE_ASSIGNMENT write out the assignment to the given file ID in the
%specified format

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
    write_assignment_csv(fid, assignment, char(9));
  elseif (strcmp(output_type, 'CSV'))
    write_assignment_csv(fid, assignment, ',');
  else
    error('Invalid output type:\n-->%s<--', output_type);
  end
end

function write_assignment_csv(fid, a, sep)
  % write out the instructor info
  if (isempty(a.name.mi))
    fprintf(fid, '%c %s\n', a.name.fi, a.name.last);
  else
    fprintf(fid, '%c %c %s\n', a.name.fi, a.name.mi, a.name.last);
  end
  fprintf(fid, '%cSSN%c%s\n', sep, sep, a.ssn);
  fprintf(fid, '%cEmployee ID%c%s\n', sep, sep, a.id);
  fprintf(fid, '%cTitle%c%s\n', sep, sep, a.range_code);
  fprintf(fid, '%cCampus%c%s\n', sep, sep, a.campus);
  fprintf(fid, '%cSchool%c%s\n', sep, sep, a.school);
  fprintf(fid, '%cDepartment%c%s\n', sep, sep, a.department);
  fprintf(fid, '\n');
  fprintf(fid, '%cReport Date%c%s\n', sep, sep, a.date);
  fprintf(fid, '%cAcademic Date%c%s\n', sep, sep, sprintf('%4d %s', a.year, a.quarter));
  fprintf(fid, '\n');
  fprintf(fid, '%cInstructional Faculty Fraction', sep);
  for (i=1:length(a.iff))
    fprintf(fid, '%c%.3f', sep, a.iff(i));
  end
  fprintf(fid, '\n');
  fprintf(fid, '%cInstructional Administrative Fraction%c%.3f', sep, sep, a.iaf);
  if (~isempty(a.admin_level))
    fprintf(fid, '%c%s', sep, a.admin_level);
  end
  fprintf(fid, '\n');
  fprintf(fid, '%cOther Support Fraction%c%5.3f\n', sep, sep, a.osf);
%  fprintf(fid, '%cTotal Support Fraction%c%5.3f\n', sep, sep, a.iff+a.iaf+a.osf);
  
  % write out the assignment headers
  if ((length(a.course)+length(a.assigned_time))>0)
    fprintf(fid, '\n');
    fprintf(fid, '%c%s', sep, 'Assignment');
    fprintf(fid, '%c%s', sep, 'HEGIS');
    fprintf(fid, '%c%s', sep, 'Level');
    fprintf(fid, '%c%s', sep, 'Enrollment');
    fprintf(fid, '%c%s', sep, 'Line Sequence Number');
    fprintf(fid, '%c%s', sep, 'Course Classification Number');
    fprintf(fid, '%c%s', sep, 'Credits');
    fprintf(fid, '%c%s', sep, 'Days');
    fprintf(fid, '%c%s', sep, 'Start Time');
    fprintf(fid, '%c%s', sep, 'End Time');
    fprintf(fid, '%c%s', sep, 'TBA Hours');
    fprintf(fid, '%c%s', sep, 'Location');
    fprintf(fid, '%c%s', sep, 'Type');
    fprintf(fid, '%c%s', sep, 'Group Code');
    fprintf(fid, '%c%s', sep, 'Team Teaching Fraction');
    fprintf(fid, '%c%s', sep, 'Student Credit Units');
    fprintf(fid, '%c%s', sep, 'Faculty Contact Hours');
    fprintf(fid, '%c%s', sep, 'Direct Weighted Teaching Units');
    fprintf(fid, '%c%s', sep, 'Indirect Weighted Teaching Units');
    fprintf(fid, '\n');
  end
  
  % write out the courses
  for (i=1:length(a.course))
    fprintf(fid, '%c%s %s-%s', sep, a.course(i).prefix, a.course(i).number, a.course(i).section);
    fprintf(fid, '%c%s', sep, a.course(i).hegis);
    fprintf(fid, '%c%s', sep, a.course(i).level);
    fprintf(fid, '%c%d', sep, a.course(i).enrollment);
    fprintf(fid, '%c%s', sep, a.course(i).ls);
    fprintf(fid, '%c%s', sep, a.course(i).cs);
    fprintf(fid, '%c%.1f', sep, a.course(i).accu);
    fprintf(fid, '%c%s', sep, a.course(i).days);
    fprintf(fid, '%c%s', sep, a.course(i).start_time);
    fprintf(fid, '%c%s', sep, a.course(i).end_time);
    fprintf(fid, '%c%.1f', sep, a.course(i).tba); 
    fprintf(fid, '%c', sep);
    if (~isempty(a.course(i).location.building))
      fprintf(fid, '%s-%s', a.course(i).location.building, a.course(i).location.room);
    end
    fprintf(fid, '%c%s', sep, a.course(i).type);
    fprintf(fid, '%c%s', sep, a.course(i).group);
    fprintf(fid, '%c%.3f', sep, a.course(i).ttf);
    fprintf(fid, '%c%.1f', sep, a.course(i).scu);
    fprintf(fid, '%c%.1f', sep, a.course(i).fch);
    fprintf(fid, '%c', sep);
    if (a.course(i).wtu.direct>0)
      fprintf(fid, '%.1f', a.course(i).wtu.direct);
    end
    fprintf(fid, '%c', sep);
    if (a.course(i).wtu.indirect>0)
      fprintf(fid, '%.1f', a.course(i).wtu.indirect);
    end
    fprintf(fid, '\n');
  end
  
  % write out the assigned time
  for (i=1:length(a.assigned_time))
    fprintf(fid, '%c%s', sep, a.assigned_time(i).description);
    fprintf(fid, '%c', sep);
    fprintf(fid, '%c', sep);
    fprintf(fid, '%c', sep);
    fprintf(fid, '%c', sep);
    fprintf(fid, '%c', sep);
    fprintf(fid, '%c', sep);
    fprintf(fid, '%c', sep);
    fprintf(fid, '%c', sep);
    fprintf(fid, '%c', sep);
    fprintf(fid, '%c', sep);
    fprintf(fid, '%c', sep);
    fprintf(fid, '%c', sep);
    fprintf(fid, '%c', sep);
    fprintf(fid, '%c', sep);
    fprintf(fid, '%c', sep);
    fprintf(fid, '%c', sep);
    fprintf(fid, '%c', sep);
    if (a.assigned_time(i).wtu.direct>0)
      fprintf(fid, '%.1f', a.assigned_time(i).wtu.direct);
    end
    fprintf(fid, '%c', sep);
    if (a.assigned_time(i).wtu.indirect>0)
      fprintf(fid, '%.1f', a.assigned_time(i).wtu.indirect);
    end
    fprintf(fid, '\n');
  end
end
