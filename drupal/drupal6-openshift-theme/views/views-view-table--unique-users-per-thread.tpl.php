<?php
// This view is embedded inside the following template file:
//   views-view-table--og_ghp_thread_list--default.tpl.php
// It simply outputs the number of unique participants in each thread (not the number of comments).
// For more information, look in the template file listed above.
$participants = count($rows);
print format_plural($participants, '1 Person', '@count People');
?>