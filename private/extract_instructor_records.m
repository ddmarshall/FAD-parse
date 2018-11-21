function rec = extract_instructor_records(fid, h, verbose)
%EXTRACT_INSTRUCTOR_RECORDS extracts a sequence of instructor records
%stopping when an empty line is reached

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

  % loop until get blank line
  rec = [];
  str = fgetl(fid);
  if(isnumeric(str))
    error('Unexpected end of file reached');
  end
  done = strcmp(str, ' ');
  while (~done)
    tmp.date       = h.date;
    tmp.campus     = h.campus;
    tmp.school     = h.school;
    tmp.department = h.department;
    tmp.quarter    = h.quarter;
    tmp.year       = h.year;
    
    % extract part 1
    str_ref = '                                                                           TSF    IAF                       OSF                                      IFF';
    if (~strcmp(str, str_ref))
      error('Unexpected line:\n-->%s<--', str);
    end
    str = fgetl(fid);
    if(isnumeric(str))
      error('Unexpected end of file reached');
    end
    if (str(1) ~= ' ')
      error('Unexpected line:\n-->%s<--', str);
    end
    tmp.ssn         = extract_ssn(str(2:12));
    tmp.id          = extract_empid(str(13:29));
    tmp.name        = extract_name(str(30:53));
    tmp.range_code  = extract_range_code(str(54:74));
    tmp.tsf         = extract_tsf(str(75:81));
    tmp.iaf         = extract_iaf(str(82:88));
    tmp.admin_level = extract_admin_level(str(89:106));
    tmp.osf         = extract_osf(str(107:113));
    tmp.split_info  = extract_split_appointment_info(str(114:140));
    tmp.iff         = extract_iff(str(141:end));
    if (length(tmp.split_info)+1 ~= length(tmp.iff))
      error('Invalid Split Appointment:\n-->%s--<', str(114:end));
    end

    totals.enrollment   = 0;
    totals.scu          = 0;
    totals.fch          = 0;
    totals.wtu.direct   = 0;
    totals.wtu.indirect = 0;
    totals.wtu.total    = 0;
    
    % extract part 2
    str_3ref = '                             ___                                                               ______  ____  _____   ____  _____';
    str = fgetl(fid);
    if(isnumeric(str))
      error('Unexpected end of file reached');
    end
    if (str(1) ~= ' ')
      error('Unexpected line:\n-->%s<--', str);
    end
    empty_course = strcmp(str, str_3ref);
    part2_done = (empty_course || strcmp(str, ' '));
    tmp.assigned_time = [];
    while (~part2_done)
      ata.description = extract_assigned_time_description(str(2:107));
      ata.wtu = extract_wtu(str(108:end));
      if (isempty(tmp.assigned_time))
        tmp.assigned_time = ata;
      else
        tmp.assigned_time(end+1) = ata;
      end
      totals.wtu.direct   = totals.wtu.direct   + ata.wtu.direct;
      totals.wtu.indirect = totals.wtu.indirect + ata.wtu.indirect;
      totals.wtu.total    = totals.wtu.total    + ata.wtu.total;
      
      str = fgetl(fid);
      if(isnumeric(str))
        error('Unexpected end of file reached');
      end
      if (str(1) ~= ' ')
        error('Unexpected line:\n-->%s<--', str);
      end
      part2_done = strcmp(str, ' ');
    end
    
    % extract part 3
    if (~empty_course)
      str = fgetl(fid);
      if(isnumeric(str))
        error('Unexpected end of file reached');
      end
    
      % check for joint appointment indicator
      if (strcmp(str(1:29),'  *** SEE PRIMARY SCHOOL/DEPT'))
        if (length(tmp.iff) == 1)
          error('Unexpected line:\n-->%s<--', str);
        end
        str = fgetl(fid);
        if(isnumeric(str))
          error('Unexpected end of file reached');
        end
        if (str(1) ~= ' ')
          error('Unexpected line:\n-->%s<--', str);
        end
        empty_course = strcmp(str, str_3ref);
      elseif (strcmp(str,' NOTE: D-WTU, I-WTU & T-WTU VALUES IMMEDIATELY BELOW DO NOT INCLUDE CONTRIBUTIONS FROM ASSIGN TIME ACTIVITIES WITHIN 2ND & 3RD'))
        if (length(tmp.iff) == 1)
          error('Unexpected line:\n-->%s<--', str);
        end
        str = fgetl(fid);
        if(isnumeric(str))
          error('Unexpected end of file reached');
        end
        if (str(1) ~= ' ')
          error('Unexpected line:\n-->%s<--', str);
        end
        str = fgetl(fid);
        if(isnumeric(str))
          error('Unexpected end of file reached');
        end
        if (str(1) ~= ' ')
          error('Unexpected line:\n-->%s<--', str);
        end
        str = fgetl(fid);
        if(isnumeric(str))
          error('Unexpected end of file reached');
        end
        if (str(1) ~= ' ')
          error('Unexpected line:\n-->%s<--', str);
        end
        empty_course = strcmp(str, str_3ref);
      end
      
      if (~empty_course)
        str_ref = '  COURSE ID   SECT HEGIS LVL ENR  LS CS A-CCU DAYS  BEG  END   TBA  FACL SPACE/TYPE GRP   TTF    SCU    FCH  D-WTU  I-WTU  T-WTU';
        if (strcmp(str, str_ref))
          str = fgetl(fid);
          if(isnumeric(str))
            error('Unexpected end of file reached');
          end
          if (str(1) ~= ' ')
            error('Unexpected line:\n-->%s<--', str);
          end
        else
          empty_course = true;
        end
      end
    end
    tmp.course = [];
    part3_done = strcmp(str, str_3ref);
    if (~part3_done && empty_course)
      error('Unexpected line:\n-->%s<--', str);
    end
    while (~part3_done)
      % catch case with multi-part sections
      multi_part_section = isempty(strtrim(str(2:32)));
      if (multi_part_section)
        cs.enrollment = 0;
        ls_prev = cs.ls;
        cs.ls         = extract_course_ls(str(33:36));
        if (cs.ls ~= (ls_prev + 2))
          error('Invalid Multi-Part Course Record:\n-->%s<--', str)
        end
      else
        cs.prefix     = extract_course_prefix(str(2:7));
        cs.number     = extract_course_number(str(8:11));
        cs.section    = extract_course_section(str(12:18));
        cs.hegis      = extract_course_hegis(str(19:25));
        cs.level      = extract_course_level(str(26:28));
        cs.enrollment = extract_course_enrollment(str(29:32));
        cs.ls         = extract_course_ls(str(33:36));
      end
      cs.cs         = extract_course_cs(str(37:39));
      cs.accu       = extract_course_accu(str(40:45));
      cs.days       = extract_course_days(str(46:50));
      cs.start_time = extract_course_time(str(53:56));
      if (str(57) ~= ' ')
        error('Invalid Course Times:\n-->%s<--', str(53:61));
      end
      cs.end_time   = extract_course_time(str(58:61));
      if (etime(datevec(cs.end_time), datevec(cs.start_time))<=0)
        error('Invalid Course Start and End Times:\n-->%s<--', str(53:61));
      end
      cs.tba        = extract_course_tba(str(62:66));
      cs.location   = extract_course_location(str(67:78));
      if (isempty(cs.days))
        if (~isempty(cs.location.building))
          error('Invalid Course Location:\n:-->%s<--', str(67:78));
        end
      elseif (~strcmp(cs.days, 'TBA'))
        if (isempty(cs.location.building))
          error('Invalid Course Location:\n-->%s<--', str(67:78));
        end
      end
      if (multi_part_section)
        % multi-part sections might have empty course type
        if (~isempty(strtrim(str(79:83))))
          cs.type = extract_course_type(str(79:83));
        end
      else
        cs.type       = extract_course_type(str(79:83));
      end
      cs.group      = extract_course_group(str(84:88));
      cs.ttf        = extract_course_ttf(str(89:95));
      cs.scu        = extract_course_scu(str(96:102));
      cs.fch        = extract_course_fch(str(103:108));
      idx = min(length(str), 122);
      cs.wtu = extract_wtu(str(109:idx));
      if (length(str)>122)
        twtu = extract_course_wtu(str(123:end));
      else
        twtu = 0;
      end
      if (twtu ~= cs.wtu.total)
        if (twtu ~= 0)
          error('Invalid Course Total WTU:\n-->%s<--', str(123:end));
        end
      end
    
      % append the current course and related information
      if (isempty(tmp.course))
        tmp.course = cs;
      else
        tmp.course(end+1) = cs;
      end
      totals.enrollment   = totals.enrollment   + cs.enrollment;
      totals.scu          = totals.scu          + cs.scu;
      totals.fch          = totals.fch          + cs.fch;
      totals.wtu.direct   = totals.wtu.direct   + cs.wtu.direct;
      totals.wtu.indirect = totals.wtu.indirect + cs.wtu.indirect;
      totals.wtu.total    = totals.wtu.total    + cs.wtu.total;
      
      % get the next line
      str = fgetl(fid);
      if(isnumeric(str))
        error('Unexpected end of file reached');
      end
      if (str(1) ~= ' ')
        error('Unexpected line:\n-->%s<--', str);
      end
      part3_done = strcmp(str, str_3ref);
    end
    
    % get the course totals and check
    if (verbose)
      str = fgetl(fid);
      if(isnumeric(str))
        error('Unexpected end of file reached');
      end
      if (str(1) ~= ' ')
        error('Unexpected line:\n-->%s<--', str);
      end
      tt = extract_course_enrollment(str(29:32));
      if (tt ~= totals.enrollment)
        fprintf(1, 'Warning: Total Enrollment of %d does not match sum of %d for %c. %s.\n', tt, totals.enrollment, tmp.name.fi, tmp.name.last);
      end
      tt = extract_course_scu(str(96:102));
      if (abs(tt - totals.scu) >= 5e-2)
        fprintf(1, 'Warning: Total SCU of %5.1f does not match sum of %5.1f for %c. %s.\n', tt, totals.scu, tmp.name.fi, tmp.name.last);
      end
      tt = extract_course_fch(str(103:108));
      if (abs(tt - totals.fch) >= 5e-2)
        fprintf(1, 'Warning: Total FCH of %5.1f does not match sum of %5.1f for %c. %s.\n', tt, totals.fch, tmp.name.fi, tmp.name.last);
      end
      if (length(str)<128)
        error('Invalid Course Summary:\n-->%s<--', str);
      end
      tt = extract_wtu(str(109:122));
      if (abs(tt.direct - totals.wtu.direct) >= 5e-2)
        fprintf(1, 'Warning: Total D-WTU of %5.1f does not match %5.1f for %c. %s.\n', tt.direct, totals.wtu.direct, tmp.name.fi, tmp.name.last);
      end
      if (abs(tt.indirect - totals.wtu.indirect) >= 5e-2)
        fprintf(1, 'Warning: Total I-WTU of %5.1f does not match %5.1f for %c. %s.\n', tt.indirect, totals.wtu.indirect, tmp.name.fi, tmp.name.last);
      end
      tt = extract_course_wtu(str(123:end));
      if (abs(tt - totals.wtu.total) >= 5e-2)
        fprintf(1, 'Warning: Total T-WTU of %5.1f does not match %5.1f for %c. %s.\n', tt, totals.wtu.total, tmp.name.fi, tmp.name.last);
      end
    end
    
    % get the row indicating end of record
    str = fgetl(fid);
    if(isnumeric(str))
      error('Unexpected end of file reached');
    end
    if (str(1) ~= ' ')
      error('Unexpected line:\n-->%s<--', str);
    end
    str_ref = ' ********************************************************************************************************************************************************';
    if (~strcmp(str, str_ref))
      error('Unexpected line:\n-->%s<--', str);
    end
    
    % final check of data
    is_valid = true;
    if (verbose)
      if (tmp.iaf > 0)
        if (isempty(tmp.admin_level))
          fprintf(1, 'Warning: Instructional Administration Fraction of %d does not have description for %c. %s.\n', tmp.iaf, tmp.name.fi, tmp.name.last);
        end
      else
        if (~isempty(tmp.admin_level))
          fprintf(1, 'Warning: Instructional Administration Fraction description of %s given for %c. %s without IAF fraction.\n', tmp.admin_level, tmp.name.fi, tmp.name.last);
        end
      end
      if (abs(tmp.tsf - (tmp.osf+sum(tmp.iff)+tmp.iaf))>=5e-4)
        fprintf(1, 'Warning: Assignment fractions %5.3f %5.3f %5.3f did not match reported total %5.3f for %c. %s.\n', tmp.osf, sum(tmp.iff), tmp.iaf, tmp.tsf, tmp.name.fi, tmp.name.last);
      end
    end
    
    % if checks have passed then append record
    if (is_valid)
      if (isempty(rec))
        rec = tmp;
      else
        rec(end+1) = tmp;
      end
    end
    
    % get next line
    str = fgetl(fid);
    if(isnumeric(str))
      error('Unexpected end of file reached');
    end
    done = (isempty(str) || strcmp(str, ' '));
  end
end

function ssn = extract_ssn(str)
  if (~strcmp(str(1:5), 'XXXXX'))
    error('Invalid SSN:\n-->%s<--', str);
  end
  if (~isnumber(str(6:9)))
    error('Invalid SSN:\n-->%s<--', str);
  end
  ssn = str(1:9);
end

function empid = extract_empid(str)
  empid = strtrim(str);
  if (~isnumber(empid))
    error('Invalid Employee ID:\n-->%s<--', str);
  end
end

function name = extract_name(str)
  if ((length(str) < 6) || (str(2) ~= ' ') || (str(4) ~= ' '))
    error('Invalid name:\n-->%s<--', str);
  end
  if (~isletter(str(1)))
    error('Invalid first initial:\n-->%c<--', str(1));
  end
  name.fi   = str(1);
  if (~isletter(str(3)) && (str(3) ~= ' '))
    error('Invalid first initial:\n-->%c<--', str(3));
  end
  name.mi   = strtrim(str(3));
  name.last = strtrim(str(5:end));
end

function rc = extract_range_code(str)
  rc = strtrim(str);
end

function tsf = extract_tsf(str)
  tsf = str2double(str);
  if ((tsf < 0) || (tsf > 1))
    error('Invalid TSF:\n-->%s<--', str);
  end
end

function iaf = extract_iaf(str)
  iaf = str2double(str);
  if ((iaf < 0) || (iaf > 1))
    error('Invalid IAF:\n-->%s<--', str);
  end
end

function al = extract_admin_level(str)
  al = strtrim(str);
end

function osf = extract_osf(str)
  osf = str2double(str);
  if ((osf < 0) || (osf > 1))
    error('Invalid OSF:\n-->%s<--', str);
  end
end

function si = extract_split_appointment_info(str)
  if (isempty(strtrim(str)))
    si = [];
  else
    if (~strcmp(str(1:10), 'SPLIT APPT'))
      error('Invalid Split Assignment:\n-->%s<--', str);
    end
    si.school     = str(12:13);
    si.department = str(14:16);
    if (~isempty(strtrim(str(18:22))))
      si(2).school     = str(18:19);
      si(2).department = str(20:22);
    end
    if (~strcmp(str(24:27), 'IFF='))
      error('Invalid Split Assignment:\n-->%s<--', str);
    end
  end
end

function iff = extract_iff(str)
  strsp = strsplit(strtrim(str));
  n = length(strsp);
  iff = zeros(n,1);
  for (i=1:n)
    iff(i) = str2double(strsp{i});
    if ((iff(i) < 0) || (iff(i) > 1))
      error('Invalid IFF:\n-->%s<--', strsp{i});
    end
  end
end

function desc = extract_assigned_time_description(str)
  desc = strtrim(str);
end

function wtu = extract_wtu(str)
  idx = min(length(str), 7);
  if (isempty(strtrim(str(1:idx))))
    wtu.direct = 0;
  else
    wtu.direct = str2double(str(1:idx));
  end
  if ((length(str)<7) || isempty(strtrim(str(8:end))))
    wtu.indirect = 0;
  else
    wtu.indirect = str2double(str(8:end));
  end
  wtu.total=wtu.direct+wtu.indirect;

  if ((wtu.direct < 0) || (wtu.indirect < 0) || (wtu.total<0))
    error('Invalid WTUs:\n-->%s--<', str);
  end
end

function p = extract_course_prefix(str)
  p = strtrim(str);
  if (~isletter(p))
    error('Invalid Course Prefix:\n-->%s<--', str);
  end
end

function n = extract_course_number(str)
  n = strtrim(str);
  if (~isnumber(n))
    error('Invalid Course Number:\n-->%s<--', str);
  end
  if (length(n) ~= 4)
    error('Invalid Course Number:\n-->%s<--', str);
  end
end

function s = extract_course_section(str)
  s = strtrim(str);
  if (~isnumber(s))
    error('Invalid Course Section:\n-->%s<--', str);
  end
  if (length(s) ~= 2)
    error('Invalid Course Section:\n-->%s<--', str);
  end
end

function hegis = extract_course_hegis(str)
  hegis = strtrim(str);
  if (~isnumber(hegis))
    error('Invalid Course HEGIS:\n-->%s<--', str);
  end
  if (length(hegis) ~= 5)
    error('Invalid Course HEGIS:\n-->%s<--', str);
  end
end

function lvl = extract_course_level(str)
  lvl = strtrim(str);
  if ((~strcmp(lvl, 'LD')) && (~strcmp(lvl, 'UD')) && (~strcmp(lvl, 'GD')))
    error('Invalid Course Level:\n-->%s<--', str);
  end
end

function enr = extract_course_enrollment(str)
  enr = str2double(str);
end

function ls = extract_course_ls(str)
  ls = strtrim(str);
  if (~isnumber(ls))
    error('Invalid Course Line Sequence Number:\n-->%s<--', str);
  end
  if (length(ls) ~= 2)
    error('Invalid Course Line Sequence Number:\n-->%s<--', str);
  end
end

function cs = extract_course_cs(str)
  cs = strtrim(str);
  if (~isnumber(cs))
    error('Invalid Course Classification Number:\n-->%s<--', str);
  end
  if (length(cs) ~= 2)
    error('Invalid Course Classification Number:\n-->%s<--', str);
  end
end

function accu = extract_course_accu(str)
  accu = str2double(str);
  if (accu < 0)
    error('Invalid Adjusted Course Credit Units:\n-->%s<--', str);
  end
end

function days = extract_course_days(str)
  days = strtrim(str);
  % TODO: parse this into more convenient format to process
end

function t = extract_course_time(str)
  if (isempty(strtrim(str)))
    t = [];
  else
    sh = str(1:2);
    if (~isnumber(sh))
      error('Invalid Course Time:\n-->%s<--', str);
    end
    tmp = str2double(sh);
    if ((tmp<0) || (tmp>23))
      error('Invalid Course Time:\n-->%s<--', str);
    end
    sm = str(3:4);
    if (~isnumber(sm))
      error('Invalid Course Time:\n-->%s<--', str);
    end
    tmp = str2double(sm);
    if ((tmp<0) || (tmp>59))
      error('Invalid Course Time:\n-->%s<--', str);
    end
    t = sprintf('%s:%s', sh, sm);
  end
end

function tba = extract_course_tba(str)
  tba = str2double(str);
  if (tba < 0)
    error('Invalid Course TBA Hours:\n-->%s<--', str);
  end
end

function loc = extract_course_location(str)
  loc.building = strtrim(str(1:6));
  loc.room     = strtrim(str(7:12));
end

function t = extract_course_type(str)
  t = strtrim(str); 
  if (~strcmp(t, 'LECT') && ~strcmp(t, 'LAB') && ~strcmp(t, 'NCAP') && ~strcmp(t, 'ASYN'))
    error('Invalid Course Type:\n-->%s<--', str);
  end
end

function g = extract_course_group(str)
  g = strtrim(str);
end

function ttf = extract_course_ttf(str)
  ttf = str2double(str);
  if ((ttf<0) || (ttf>1))
    error('Invalid Course Total Teaching Fraction:\n-->%s<--', str);
  end
end

function scu = extract_course_scu(str)
  scu = str2double(str);
  if (scu<0)
    error('Invalid Course SCU:\n-->%s<--', str);
  end
end

function fch = extract_course_fch(str)
  fch = str2double(str);
  if (fch<0)
    error('Invalid Course Faculty Contact Hours:\n-->%s<--', str);
  end
end

function wtu = extract_course_wtu(str)
  wtu = str2double(str);
  if (wtu<0)
    error('Invalid Course WTU:\n-->%s<--', str);
  end
end
