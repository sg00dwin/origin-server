BEGIN:VCALENDAR
VERSION:2.0
METHOD:PUBLISH
X-WR-CALNAME:OpenShift Events
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
drupal_set_header("Content-Type: text/calendar");
drupal_set_header("Content-Type: text/calendar");
drupal_set_header("Content-Disposition: attachment; filename=feed.ics");
drupal_set_header("Cache-Control: no-cache, must-revalidate"); // HTTP/1.1
drupal_set_header("Expires: Sat, 01 Jan 2000 05:00:00 GMT"); // Date in the past
?>
