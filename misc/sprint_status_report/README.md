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

1. Stories that need QE means they **DO NOT** have the `no-qe` tag
1. Design stories never require QE
1. Stories that have QE notes means that there is some text in the notes section like, `[libra-qe]`, `tcms`, or `QE`
1. Dcut is currently defined as day 8 and can be changed in `config/rally.yml`

Target Audiences
----------------
These are the reports that can be run and who will receive emails.
<table>
  <tr>
    <th>Target</th>
    <th>Email</th>
    <th>Nag</th>
  </tr>
  <tr>
    <td>Dev</td>
    <td>libra-devel</td>
    <td>true</td>
  </tr>
  <tr>
    <td>QE</td>
    <td>libra-qe</td>
    <td>false</td>
  </tr>
</table>

Queries That Are Run
--------------------

<table>
  <tr>
    <th>Target</th>
    <th>Report Title</th>
    <th>First Day Run</th>
    <th>Includes</th>
  </tr>
  <tr>
    <th>Dev</th>
    <td>User Stories Without Tasks</td>
    <td>2</td>
    <td>Any stories without tasks</td>
  </tr>
  <tr>
    <th></th>
    <td>Blocked User Stories</td>
    <td>*</td>
    <td>Any stories marked as blocked</td>
  </tr>
  <tr>
    <th></th>
    <td>Test Cases Needing Development Approval</td>
    <td>5</td>
    <td>Any stories that need QE, have QE notes</td>
  </tr>
  <tr>
    <th></th>
    <td>User Stories to be Completed by DCUT</td>
    <td>dcut</td>
    <td>Any stories that have the os-DevCut tag that are not complete</td>
  </tr>
  <tr>
    <th>QE</th>
    <td>User Stories Requiring Test Cases</td>
    <td>4</td>
    <td>Any stories that need QE and do not have QE notes</td>
  </tr>
  <tr>
    <th>Dev, QE</th>
    <td>Test Cases Needing QE Re-submission</td>
    <td>*</td>
    <td>Any stories that need QE and have the TC-rejected tag</td>
  </tr>
</table>


Any problems
============
Contact Fotios Lindiakos <fotios@redhat.com>
