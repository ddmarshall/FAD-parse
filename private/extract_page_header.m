function h = extract_page_header(fid)
%EXTRACT_PAGE_HEADER extracts the header information
%
% h - header structure
% fid - file id for FAD file

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

  %% LINE 1
  str = fgetl(fid);
  if(isnumeric(str))
    error('Unexpected end of file reached');
  end
  if (str(1) ~= ' ')
    error('Unexpected line:\n-->%s<--', str);
  end
  h.date = extract_date(str(2:18));
  if (length(str)<110)
    h.summary = true;
    h.title = strtrim(str(19:end));
  else
    h.summary = false;
    h.title = strtrim(str(19:109));
    h.page = extract_page(str(110:end));
  end
  
  %% LINE 2
  str = fgetl(fid);
  if(isnumeric(str))
    error('Unexpected end of file reached');
  end
  if (str(1) ~= ' ')
    error('Unexpected line:\n-->%s<--', str);
  end
  h.job = extract_job(str(2:13));
  if (h.summary)
    h.pgm = extract_pgm(str(14:34));
    if (~strcmp(str(35:71), 'SUMMARY BY FACULTY TYPE AND RANK FOR '))
      error('Invalid text:\n-->%s<--', str(35:71));
    end
  else
    h.pgm = extract_pgm(str(14:33));
    if (~strcmp(str(34:71), 'FACULTY ASSIGNMENTS BY DEPARTMENT FOR '))
      error('Invalid text:\n-->%s<--', str(34:71));
    end
  end
  h.quarter = extract_quarter(str(72:78));
  h.year    = extract_year(str(79:83));
  if (h.summary)
    h.campus = extract_campus(str(84:133));
    h.page   = extract_page(str(134:end));
  else
    h.campus = extract_campus(str(84:end));
  end
  
  %% LINE 3
  str = fgetl(fid);
  if(isnumeric(str))
    error('Unexpected end of file reached');
  end
  if ((length(str) > 1) || (str(1) ~= ' '))
    error('Unexpected line:\n-->%s<--', str);
  end

  %% LINE 4
  str = fgetl(fid);
  if(isnumeric(str))
    error('Unexpected end of file reached');
  end
  if (str(1) ~= ' ')
    error('Unexpected line:\n-->%s<--', str);
  end
  h.school = extract_school(str(2:49));
  if (h.summary)
    dpt_idx = 51;
  else
    dpt_idx = 50;
  end
  h.department = extract_department(str(dpt_idx:end));
  
  %% LINE 5
  str = fgetl(fid);
  if(isnumeric(str))
    error('Unexpected end of file reached');
  end
  if ((length(str) > 1) || (str(1) ~= ' '))
    error('Unexpected line:\n-->%s<--', str);
  end
  
  if (~h.summary)
    %% LINE 6
    str = fgetl(fid);
    if(isnumeric(str))
      error('Unexpected end of file reached');
    end
    str_ref = '   SSN        EMPLOYEE ID     NAME                   RANGE CODE            TSF    IAF     ADM-LVL           OSF                                      IFF';
    if (~strcmp(str, str_ref))
      error('Unexpected line:\n-->%s<--', str);
    end
    
    %% LINE 7
    str = fgetl(fid);
    if(isnumeric(str))
      error('Unexpected end of file reached');
    end
    str_ref = '        ASSIGNED TIME ACTIVITY';
    if (~strcmp(str, str_ref))
      error('Unexpected line:\n-->%s<--', str);
    end
  end
end

function dt = extract_date(str)
  tmp = strsplit(strtrim(str));
  month = tmp{1};
  da = sscanf(tmp{2}, '%d,');
  yr = str2double(tmp{3});

  if (strcmp(month, 'JANUARY'))
    mo = 1;
  elseif (strcmp(month, 'FEBRUARY'))
    mo = 2;
  elseif (strcmp(month, 'MARCH'))
    mo = 3;
  elseif (strcmp(month, 'APRIL'))
    mo = 4;
  elseif (strcmp(month, 'MAY'))
    mo = 5;
  elseif (strcmp(month, 'JUNE'))
    mo = 6;
  elseif (strcmp(month, 'JULY'))
    mo = 7;
  elseif (strcmp(month, 'AUGUST'))
    mo = 8;
  elseif (strcmp(month, 'SEPTEMBER'))
    mo = 9;
  elseif (strcmp(month, 'OCTOBER'))
    mo = 10;
  elseif (strcmp(month, 'NOVEMBER'))
    mo = 11;
  elseif (strcmp(month, 'DECEMBER'))
    mo = 12;
  else
   error('Invalid month:\n-->%s<--');
  end
  
  dt = datestr(datenum(sprintf('%2d.%2d.%4d', mo, da, yr), 'mm.dd.yyyy'), 1);
end

function pg = extract_page(str)
  if (~strcmp(str(1:4), 'PAGE'))
    error('Invalid page:\n-->%s<--',str);
  end
  pg = str2double(str(5:end));
end

function jb = extract_job(str)
  if (~strcmp(str(1:3), 'JOB'))
    error('Invalid page:\n-->%s<--',str);
  end
  jb = sscanf(str(4:end), '%s', 1);
end

function pgm = extract_pgm(str)
  if (~strcmp(str(1:3), 'PGM'))
    error('Invalid pgm:\n-->%s<--',str);
  end
  pgm = sscanf(str(4:end), '%s', 1);
end

function q = extract_quarter(str)
  if (strcmp(str, 'FALL   '))
    q = '08 - Fall';
  elseif (strcmp(str, 'WINTER '))
    q = '02 - Winter';
  elseif (strcmp(str, 'SPRING '))
    q = '04 - Spring';
  elseif (strcmp(str, 'SUMMER '))
    q = '06 - Summer';
  else
    error('Inalide quarter:\n-->%s<--', str);
  end
end

function y = extract_year(str)
  y = str2double(str);
end

function cmp = extract_campus(str)
  cmp = strtrim(str);
end

function sc = extract_school(str)
  if (~strcmp(str(1:8), 'SCHOOL -'))
    error('Invalid school:\n-->%s<--', str);
  end
  sc = strtrim(str(9:end));
end

function dpt = extract_department(str)
  if (isempty(strtrim(str)))
    dpt = [];
    return;
  end
  
  if (~strcmp(str(1:13), 'DEPARTMENT - '))
    error('Invalid department:\n-->%s<--', str);
  end
  dpt = strtrim(str(14:end));
end
