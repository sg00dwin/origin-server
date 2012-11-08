BEGIN:VCALENDAR
VERSION:2.0
METHOD:PUBLISH
PRODID:-//Drupal iCal API//EN
<?php
foreach ($themed_rows as $count => $row):
foreach ($row as $field => $content):
?>
<?php print strip_tags($content); ?>

<?php endforeach; ?>
<?php endforeach; ?>
END:VCALENDAR
<?php
header("Content-Type: text/Calendar");
header("Content-Disposition: inline; filename=feed.ics");
header("Cache-Control: no-cache, must-revalidate"); // HTTP/1.1
header("Expires: Sat, 01 Jan 2000 05:00:00 GMT"); // Date in the past
?>
