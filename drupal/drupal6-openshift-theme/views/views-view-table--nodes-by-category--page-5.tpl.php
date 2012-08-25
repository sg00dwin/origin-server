<?php
// $Id: views-view-table.tpl.php,v 1.8 2009/01/28 00:43:43 merlinofchaos Exp $
/**
 * @file views-view-table.tpl.php
 * Template to display a view as a table.
 *
 * - $title : The title of this group of rows.  May be empty.
 * - $header: An array of header labels keyed by field id.
 * - $fields: An array of CSS IDs to use for each field id.
 * - $class: A class or classes to apply to the table, based on settings.
 * - $row_classes: An array of classes to apply to each row, indexed by row
 *   number. This matches the index in $rows.
 * - $rows: An array of row items. Each row is an array of content.
 *   $rows are keyed by row number, fields within rows are keyed by field ID.
 * @ingroup views_templates
 */
//<h2>Videos</h2>
?>

<div class="<?php print $class; ?>">

<?php foreach ($rows as $count => $row): ?>
  <article class="video <?php print implode(' ', $row_classes[$count]); ?> view-row">
  <?php foreach ($row as $field_name => $value): ?>
    <?php if ($field_name == 'field_video_youku_duration'): ?>
      <?php
      $duration = explode(':', $value);
      $minutes = $duration[0];
      $seconds = $duration[1];
      if ($minutes > 0): ?>
      	<div class="<?php print $field_name; ?>"><?php print $minutes .' min, '. $seconds .' seconds'; ?></div><?php
      else: ?>
        <div class="<?php print $field_name; ?>"><?php print $seconds .' seconds'; ?></div><?php
      endif;
      ?>
    <?php elseif ($field_name == 'created'): ?>
      <div class="breadcrumb"><?php print $value; ?></div>
    <?php elseif ($field_name == 'title'): ?>
      <h2 class="<?php print $field_name; ?>"><?php print $value; ?></h2>
    <?php else: ?>
      <div class="<?php print $field_name; ?>"><?php print $value; ?></div>
    <?php endif; ?>
  <?php endforeach; ?>
    <div></div>
  </article>
<?php endforeach; ?>
</div>
