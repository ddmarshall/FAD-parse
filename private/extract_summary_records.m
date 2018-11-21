function rec = extract_summary_records(fid, h, verbose)
%EXTRACT_SUMMARY_RECORDS extracts a sequence of course instruction summary
%records stopping when the complete record is read

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

  % initialize record
  rec.date       = h.date;
  rec.campus     = h.campus;
  rec.school     = h.school;
  rec.department = h.department;
  rec.quarter    = h.quarter;
  rec.year       = h.year;
  rec.by_time  = [];
  rec.by_title = [];

  % extract header rows
  str = fgetl(fid);
  if(isnumeric(str))
    error('Unexpected end of file reached');
  end
  str_ref = ' FACULTY            NO. OF    APPT     CLASS    SUPERVSN    DIRECT   INDIRECT    TOTAL   DIRECT   TOTAL      TOTAL      TOTAL  SCU/FTEF  SFR';
  if (~strcmp(str, str_ref))
    error('Unexpected end of record reached');
  end
  str = fgetl(fid);
  if(isnumeric(str))
    error('Unexpected end of file reached');
  end
  str_ref = '  TYPE               APPTS    FTEF      WTU        WTU       WTU       WTU        WTU   WTU/FTEF WTU/FTEF     SCU       FTES';
  if (~strcmp(str, str_ref))
    error('Unexpected end of record reached');
  end
  str = fgetl(fid);
  if(isnumeric(str))
    error('Unexpected end of file reached');
  end
  if (~strcmp(str, ' '))
    error('Unexpected end of record reached');
  end
  
  % extract rows by time (ignore subtotal lines and stop when have total)
  done = false;
  while (~done)
    str = fgetl(fid);
    if(isnumeric(str))
      error('Unexpected end of file reached');
    end
    br = extract_summary_row(str, rec.department, verbose);
    if (~strcmp(br.type, 'SUBTOTAL'))
      if (strcmp(br.type, 'TOTAL'))
        done = true;
      else
        if (isempty(rec.by_time))
          rec.by_time = br;
        else
          rec.by_time(end+1) = br;
        end
      end
    end
  end

  if (~strcmp(br.type, 'TOTAL'))
    error('Invalid Summary Row:\n-->%s<--', str);
  end

  % get next 3 rows of static text
  str = fgetl(fid);
  if(isnumeric(str))
    error('Unexpected end of file reached');
  end
  if (~strcmp(str, ' '))
    error('Invalid Summary Row:\n-->%s<--', str);
  end
  str = fgetl(fid);
  if(isnumeric(str))
    error('Unexpected end of file reached');
  end
  if (~strcmp(str, ' SALARY RANGE TITLE'))
    error('Invalid Summary Row:\n-->%s<--', str);
  end
  str = fgetl(fid);
  if(isnumeric(str))
    error('Unexpected end of file reached');
  end
  if (~strcmp(str, ' '))
    error('Invalid Summary Row:\n-->%s<--', str);
  end
  
  % extract rows by title (ignore subtotal lines and stop when have total)
  done = false;
  while (~done)
    str = fgetl(fid);
    if (isnumeric(str))
      error('Unexpected end of file reached');
    end
    br = extract_summary_row(str, rec.department, verbose);
    if (~strcmp(br.type, 'SUBTOTAL'))
      if (strcmp(br.type, 'TOTAL'))
        done = true;
      else
        if (isempty(rec.by_title))
          rec.by_title = br;
        else
          rec.by_title(end+1) = br;
        end
      end
    end
  end

  if (~strcmp(br.type, 'TOTAL'))
    error('Invalid Summary Row:\n-->%s<--', str);
  end

  str = fgetl(fid);
  if (isnumeric(str))
    error('Unexpected end of file reached');
  end
  if ((~isempty(str)) && (~strcmp(str, ' ')))
    error('Unexpected Summary Row:\n-->%s<--', str);
  end

end

function br = extract_summary_row(str, dept, verbose)
  full_time_student = 15;
  
  br.type                = strtrim(str(2:20));
  br.appts               = str2double(str(21:26));
  br.ftef                = str2double(str(27:34));
  br.instructional_wtu   = str2double(str(35:44));
  br.supervision_wtu     = str2double(str(45:56));
  br.direct_wtu          = str2double(str(57:66));
  br.indirect_wtu        = str2double(str(67:77));
  br.total_wtu           = str2double(str(78:86));
  br.direct_wtu_per_ftef = str2double(str(87:96));
  br.total_wtu_per_ftef  = str2double(str(97:105));
  br.scu                 = str2double(str(106:114));
  br.ftes                = str2double(str(115:125));
  br.scu_per_ftef        = str2double(str(126:135));
  br.student_per_ftef    = str2double(str(136:end));
  
  % check data
  if (verbose)
    if (isempty(dept))
      dept = 'SCHOOL';
    end
    if (abs(br.direct_wtu - (br.instructional_wtu + br.supervision_wtu)) >= 5e-2)
      fprintf(1, 'Warning: Summary of D-WTU (%.1f) did not match Instr. WTU (%.1f) + Superv. WTU (%.1f)\n', ...
                  br.direct_wtu, br.instructional_wtu, br.supervision_wtu);
      fprintf(1, '         Difference of %.1f WTUs for %s\n', ...
                 br.direct_wtu - (br.instructional_wtu + br.supervision_wtu), ...
                 dept);
    end
    if (abs(br.total_wtu - (br.indirect_wtu + br.direct_wtu)) >= 5e-2)
      fprintf(1, 'Warning: Summary of Total WTU did not match Direct WTU + Indirect WTU\n');
      fprintf(1, '                      %6.1f                    %6.1f + %.1f\n', ...
                  br.total_wtu, br.direct_wtu, br.indirect_wtu);
      fprintf(1, '         Difference of %.1f WTUs for %s\n', ...
                 br.total_wtu - (br.direct_wtu + br.indirect_wtu), ...
                 dept);
    end
    calc_wtu_per_ftef = 0;
    if (br.ftef > 0)
      calc_wtu_per_ftef = br.direct_wtu/br.ftef;
    end
    if (abs(calc_wtu_per_ftef - br.direct_wtu_per_ftef) >= 5e-2)
      fprintf(1, 'Warning: Reported Direct WTU per FTEF (%.2f) does not match calculated value of (%.2f)\n',...
                 br.direct_wtu_per_ftef, calc_wtu_per_ftef);
    end
    calc_wtu_per_ftef = 0;
    if (br.ftef > 0)
      calc_wtu_per_ftef = br.total_wtu/br.ftef;
    end
    if (abs(calc_wtu_per_ftef - br.total_wtu_per_ftef) >= 5e-2)
      fprintf(1, 'Warning: Reported Total WTU per FTEF (%.2f) does not match calculated value of (%.2f)\n',...
                 br.total_wtu_per_ftef, calc_wtu_per_ftef);
    end
    if (abs(full_time_student - br.scu/br.ftes) >= 1e-1)
      fprintf(1, 'Warning: Calclated full-time student SCU (%.2f) from Total SCU (%.1f) / Total FTES (%.1f)\n',...
                 br.scu/br.ftes, br.scu, br.ftes);
      fprintf(1, '         does not match expected value of %.1f\n', full_time_student);
    end
    calc_scu_per_ftef = 0;
    if (br.ftef > 0)
      calc_scu_per_ftef = br.scu/br.ftef;
    end
    if (abs(calc_scu_per_ftef - br.scu_per_ftef) >= 5e-3)
      fprintf(1, 'Warning: Reported Total SCU per FTEF (%.2f) does not match calculated value of (%.2f)\n',...
                 br.scu_per_ftef, calc_scu_per_ftef);
    end
    calc_sfr = 0;
    if (br.ftef > 0)
      calc_sfr = br.ftes/br.ftef;
    end
    if (abs(calc_sfr - br.student_per_ftef) >= 5e-3)
      fprintf(1, 'Warning: Reported Student-to-Faculty ratio (%.2f) does not match calculated value of (%.2f)\n',...
                 br.student_per_ftef, calc_sfr);
    end
  end
end
