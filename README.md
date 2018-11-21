# FAD-parse
Unofficial code to parse FAD (Faculty Activity by Department) reports issued by the California State University system.

# Summary
Within the California State University (CSU) system, instructional activities (and instructionally related activities) are tracked and reported every quarter in a Faculty Activity by Department (FAD) report. These reports are used by administrators to track department workloads, efficiencies, etc.

It appears that these reports originate as text dumps of a database. These text dumps are then manually edited to remove and re-arrange records. The edited text files are then imported into MS Word. Once in MS Word, the document is then exported as a PDF using Adobe Distiller. It is these PDF documents that are then distributed to departments.

Attempting to recreate the text files from the PDF file is a difficult process because the original text layout has been destroyed in the conversion steps. This project circumvents this difficulty by using the text from the MS Word document as the FAD report contents. Attempts to reconstruct the FAD text from the PDF have been met with only limited success using such tools as [pdftotext from Poppler](https://poppler.freedesktop.org/) and various PDF viewers.

This package is written in Matlab, sorry but that was the language that I thought had the most likelihood of re-use, and requires a Matlab interpreter, Matlab and Octave have been tested, to parse the text version of the FAD report into an internal representation organized by department. This internal representation can then be written out as CSV files (one per instructor assignment as well as one per department assignment summary). Future output formats will be considered as the need arises.

# Motivation
To ensure that the FAD data correctly represents my department's activities, I needed a way to compare the FAD data to the output of the scheduling software from Lantiv, [Lantiv Scheduling Studio](https://scheduling-studio.lantiv.com/), that we use. Lantiv can produce CSV files containing each instructor's assignment for the quarter. Comparing a PDF version (or event text version) of a FAD with the Lantiv CSV data was manually intensive, prone to error, and an inefficient use of resources. This project is the result of this work.

# Other Existing Project(s)
John Clements published a FAD parser in December 2016, [csu-fad-parser](https://github.com/jbclements/csu-fad-parser) written in Racket that appears to still be actively developed. From the documentation it appears that it produces text files that can be imported into PostgreSQL. Not knowing Racket and having started on a parser before finding John's work, I decided that the quickest path for me was to continue the development of this work. You may decide otherwise.

# FAD File Format
There appears to be no openly available documentation on the FAD file format, so this parser was created by reverse-engineering the format from existing FAD reports as well as using online resources, such as this and this, to interpret the data. Most unexpected data will result in an error. Hopefully the error is caught close to where the format discrepancy occurred.

Unfortunately, any actual FAD data needs to be obtained from the CSU, so no test files exist. Perhaps future versions of this project will include test data.

# License
This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation,| either version 3 of the License, or (at your option) any later version. See the [LICENSE.md](file://./LICENSE.md) file in the project root for full license information.

# Document Format
The FAD report is composed of two sections: (1) Instructional Assignments and (2) Assignment Summaries. The first section provides individual instructional (and instructionally related) assignments organized by department. Instructors with multiple departmental assignments show up once for each departmental assignment. The second section provides a summary of assignments by department. Each section type has a corresponding header record that appears before one or more specific records.

## Instructor Assignment Section
There are two types of records associated with instructor assignments. One is the header record that provides information about the department and other general information associated with the group of instructor assignments to follow. The other is the detailed assignment record.

### Instructor Header Record
The instructor header record is preceded by a line with `1` in the first column. These headers appear before the first instructor record for a new department. They also appear every 4-6 instructor records in what appears to be a page header in the original text report.

#### Line 1
One line with following format:

|                 |       |      |        |         |         |
| ---------------:|:-----:|:----:|:------:|:-------:|:-------:|
| **Descr.** | space | Date | Title  | `PAGE`  | Page #  |
| **Col. No.**  | 1     | 2-18 | 19-109 | 110-113 | 114-end |

#### Line 2
One line with following format:

|                 |       |       |        |       |            |                          |        |       |        |
| ---------------:|:-----:|:-----:|:------:|:-----:|:----------:|:------------------------:|:------:|:-----:|:------:|
| **Descr.** | space | `JOB` | Job ID | `PGM` | Program ID | `FACULTY ASSIGNMENTS...` | Quarter| Year  | Campus |
| **Col. No.**  | 1     | 2-4   | 5-13   | 14-16 | 17-33      | 34-71                    | 72-78  | 79-83 | 84-end |

#### Line 3
One blank line

#### Line 4
One line with following format:

|                 |       |            |           |             |                |               |                 |
| ---------------:|:-----:|:----------:|:---------:|:-----------:|:--------------:|:-------------:|:---------------:|
| **Descr.** | space | `SCHOOL -` | School ID | School Name | `DEPARTMENT -` | Department ID | Department Name |
| **Col. No.**  | 1     | 2-9        | 10-13     | 14-49       | 50-62          | 63-66         | 67-end          |

#### Line 5
One blank line

#### Line 6
One line of column headers for instructor information

#### Line 7
One line of column headers for assigned time activities

### Instructor Assignment Record
The instructor assignment record has up to three sections, depending on the assignments associated with the instructor. The first section is the instructor information. The second section is the assigned time activity. If there is no assigned time activity for the instructor then this section is omitted. The third section is the assigned courses.

#### Section 1
One line with following format:

|                 |       |      |             |       |            |       |       |        |         |         |
| ---------------:|:-----:|:----:|:-----------:|:-----:|:----------:|:-----:|:-----:|:------:|:-------:|:-------:|
| **Descr.** | space | SSN  | Employee ID | Name  | Range Code | TSF   | IAF   | ADM-LVL| OSF     | IFF     |
| **Col. No.**  | 1     | 2-12 | 5-13        | 30-53 | 54-74      | 75-81 | 82-88 | 89-106 | 107-113 | 114-end |

#### Section 2
Zero or more lines with the following format:

|                 |       |                        |         |         |
| --------------- |:-----:|:----------------------:|:-------:|:-------:|
| **Descr.** | space | Assigned Time Activity | D-WTU   | I-WTU   |
| **Col. No.**  | 1     | 2-107                  | 108-113 | 114-121 |

#### Section 3a
If no courses to report this section will be empty. Otherwise one line of column headers for course information followed by
one or more lines with following format:

|                 |       |           |         |       |       |            |       |       |       |       |            |          |           |          |        |       |       |       |        |         |         |         |        |
| ---------------:|:-----:|:---------:|:-------:|:-----:|:-----:|:----------:|:-----:|:-----:|:-----:|:-----:|:----------:|:--------:|:---------:|:--------:|:------:|:-----:|:-----:|:-----:|:------:|:-------:|:-------:|:-------:|:------:|
| **Descr.** | space | Course ID | Section | HEGIS | Level | Enrollment | LS    | CS    | A-CCU | Days  | Begin Time | End Time | TBA Hours | Building | Space  | Type  | Group | TTF   | SCU    | FCH     | D-WTU   | I-WTU   | T-WTU  |
| **Col. No.**  | 1     | 2-11      | 12-18   | 19-25 | 26-28 | 29-32      | 33-36 | 37-39 | 40-45 | 46-52 | 53-56      | 57-61    | 62-66     | 67-72    |  73-78 | 79-83 | 84-88 | 89-94 | 95-101 | 102-107 | 108-114 | 115-121 | 122-end|

#### Section 3b
One line of formatted text to separate courses from assignment sums

#### Section 3c
One line with the following format

|                 |       |                    |        |       |        |          |         |         |         |         |         |         |         |         |
| ---------------:|:-----:|:------------------:|:------:|:-----:|:------:|:--------:|:-------:|:-------:|:-------:|:-------:|:-------:|:-------:|:-------:|:-------:|
| **Descr.** | space | `TOTAL INDIVIDUAL` | spaces | `___` | spaces | `______` | spaces  | `____`  | spaces  | `_____` | spaces  | `____`  | spaces  | `_____` |
| **Col. No.**  | 1     | 2-17               | 18-29  | 30-32 | 33-95  | 96-101   | 102-103 | 104-107 | 108-109 | 110-114 | 115-117 | 118-121 | 122-123 | 124-128 |


## Assignment Summary Section
There are two types of records associated with assignment summaries. One is the header record that provides information about the department and other general information associated with the group of instructor assignments being summarized. The other is the assignment summary record.

### Summary Header Record
The summary header record is preceded by a line with `1` in the first column. These headers appear before each department summary.

#### Line 1
One line with following format:

|                 |       |      |        |
| --------------- |:-----:|:----:|:------:|
| **Descr.** | space | Date | Title  |
| **Col. No.**  | 1     | 2-18 | 19-109 |

#### Line 2
One line with following format:

|                 |       |       |        |       |            |                          |        |       |        |         |         |
| ---------------:|:-----:|:-----:|:------:|:-----:|:----------:|:------------------------:|:------:|:-----:|:------:|:-------:|:-------:|
| **Descr.** | space | `JOB` | Job ID | `PGM` | Program ID | `FACULTY ASSIGNMENTS...` | Quarter| Year  | Campus | `PAGE`  | Page #  |
| **Col. No.**  | 1     | 2-4   | 5-13   | 14-16 | 17-34      | 35-71                    | 72-78  | 79-83 | 84-133 | 134-137 | 138-end |

#### Line 3
One blank line

#### Line 4
One line with following format:

|                 |       |            |           |             |                |               |                 |
| ---------------:|:-----:|:----------:|:---------:|:-----------:|:--------------:|:-------------:|:---------------:|
| **Descr.** | space | `SCHOOL -` | School ID | School Name | `DEPARTMENT -` | Department ID | Department Name |
| **Col. No.**  | 1     | 2-9        | 10-13     | 14-49       | 50-62          | 63-66         | 67-end          |

Note: For the school summary record, the last 3 columns are not present.

#### Line 5
One blank line

### Summary Assignment Record
The summary assignment record summarizes assignments by employment time (part-time, full-time, & other) and by position title (Range Code item in Instructor Assignment Record). These two summaries are separated by one line of text.

#### Summary by Employment Time
Two lines of formatted text representing the column headers followed by zero or more lines with following format:

|                 |       |                 |                     |       |                   |                 |            |              |           |                 |                   |           |         |          |        |
| ---------------:|:-----:|:---------------:|:-------------------:|:-----:|:-----------------:|:---------------:|:----------:|:------------:|:---------:|:---------------:|:-----------------:|:---------:|:-------:|:--------:|:------:|
| **Descr.** | space | Employment Type | No. of Appointments | FTEF  | Instructional WTU | Supervision WTU | Direct WTU | Indirect WTU | Total WTU | Direct WTU/FTEF | Indirect WTU/FTEF | Total SCU | FTES    | SCU/FTEF | SFR    |
| **Col. No.**  | 1     | 2-20            | 21-26               | 27-34 | 35-44             | 45-56           | 57-66      | 67-77        | 78-86     | 87-96           | 97-105            | 106-114   | 115-125 | 126-135  | 136-end|

Note: One or two subtotal lines may appear

This summary is ended by a line of totals followed by a blank line.

#### Summary by Position Title
This summary starts with a line of text followed by zero or more lines with the following format:

|                 |       |                |                     |       |                   |                 |            |              |           |                 |                   |           |         |          |        |
| ---------------:|:-----:|:--------------:|:-------------------:|:-----:|:-----------------:|:---------------:|:----------:|:------------:|:---------:|:---------------:|:-----------------:|:---------:|:-------:|:--------:|:------:|
| **Descr.** | space | Position Title | No. of Appointments | FTEF  | Instructional WTU | Supervision WTU | Direct WTU | Indirect WTU | Total WTU | Direct WTU/FTEF | Indirect WTU/FTEF | Total SCU | FTES    | SCU/FTEF | SFR    |
| **Col. No.**  | 1     | 2-20           | 21-26               | 27-34 | 35-44             | 45-56           | 57-66      | 67-77        | 78-86     | 87-96           | 97-105            | 106-114   | 115-125 | 126-135  | 136-end|

Note: One or two subtotal lines may appear

This summary is ended by a line of totals followed by a blank line.

## Additional References and Terminology
[This](https://content-calpoly-edu.s3.amazonaws.com/ir/1/publications_reports/fad/glossary.pdf) and [this](https://ir.calpoly.edu/content/publications_reports/fad/glossary for more details on the terminology) were used for definitions and descriptions of various items within the FAD report.

### Instructor Information
  * SSN - Social security number (format XXXXXnnnn)
  * Range Code - Title/Position Category
  * IFF - Instructional faculty fraction
  * IAF - Instructional administration fraction
  * ADM-LVL - Description of instructional administration assignment
  * OSF - Other support fraction
  * TSF - Total support fraction

### Assigned Time Information
  * Assigned Time Activity - Description of instructionally related activity
  * WTU - Amount of direct or indirect WTUs associated with this activity

### Course Information
  * Course ID - Identification information about course
  * Sect - Course section number
  * HEGIS - Higher Education General Education Information Survey code
  * LVL - Course level
    * LD - Lower division course
    * UD - Upper division course
    * GD - Graduate course
  * ENR - Course enrollment
  * LS - Line sequence number
  * CS - Course classification number
  * A-CCU - Adjusted course credit units
  * Days - Course meeting days
  * BEG - Course start time
  * END - Course end time
  * TBA - Number of weekly contact hours needed to be arranged
  * FACL - Building identifier for course meeting
  * SPACE - Room identifier for course meeting
  * TYPE - Course Type
    * LAB - Lab course
    * LECT - Lecture course
    * NCAP - Non-capacity constrained course
    * ASYN - Asynchronous course meeting schedule
  * TTF - Team teaching fraction
  * SCU - Student credit unit
  * FCH - Faculty contact hours
  * WTU - Weighted teaching unit

### Summary Information
  * FTEF - Full time equivalent faculty
  * FTES - Full time equivalent student
  * SFT - Student-to-faculty ratio