Setup
=====
Make sure to run `bundle install`, since this project needs a few gems we don't normally use.

Run
===

	./sprint_status_report

Use `--help` for more options

Reports
================
Below are the reports that are defined, as well as the default settings for who to send the report to and whether to "nag" the story owners with individual emails.

The following assumptions are made

1. Design stories never require QE
1. Stories that need QE means they **DO NOT** have the `no-qe` tag
1. Stories that "have QE notes" means that there is some text in the notes section like, `[libra-qe]`, `tcms`, or `QE`

Target Audiences
----------------
These are the reports that can be run and who will receive emails.

| Target | Email       | Nag   |
| ------ | -----       | ---   |
| Dev    | libra-devel | true  |
| QE     | libra-qe    | false |

Queries That Are Run
--------------------
The due date is the date that the report is first included in the
report (relative to the sprint start date).

| Target  | Report Title                            | Includes Stories...                               | Due Date      | Override    |
| ------  | ------------                            | -------------------                               | ------------- | --------    |
| Dev     | User Stories Without Tasks              | without tasks                                     | 2             | needs_tasks |
|         | Test Cases Needing Development Approval | that need QE, have QE notes                       | 5             | tc_approved |
|         | User Stories to be Completed by DCUT    | that have the os-DevCut tag that are not complete | 9             | dcut        |
| QE      | User Stories Requiring Test Cases       | that need QE and do not have QE notes             | 4             | needs_tc    |

The following reports are always included if there are matching stories.

| Target  | Report Title                            | Includes Stories...                               |
| ------  | ------------                            | -------------------                               |
|         | Blocked User Stories                    | marked as blocked                                 |
| Dev, QE | Test Cases Needing QE Re-submission     | that need QE and have the TC-rejected tag         |


Environment Pushes
==================

| Environment | Push Date               | Override |
| ----------- | ---------               | -------- |
| INT         | First Friday of Sprint  | INT      |
| STG         | Thursday before PROD    | STG      |
| PROD        | Monday after Sprint END | PROD     |


Overriding Dates
================
The dates for queries and environment pushes can be overridden by
speficying the value in the `Override` column in the notes for the
iteration.
This will work if you specify it in any of the iterations, and will only
accept the first date for a given key.
This value is case insensitive and must have a `:` separating the date
and key.

For example:

  ```
  DCUT: YYYY-MM-DD
  ```

Adding Notes
============
Similarly to DCUT, other notes in the iterations will be included in the
emails as well.

Any problems
============
Contact Fotios Lindiakos <fotios@redhat.com>
