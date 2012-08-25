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
?>
<div class="<?php print $class; ?>">
<?php foreach ($rows as $count => $row): ?>
  <div class="<?php print implode(' ', $row_classes[$count]); ?>">
    <div id="kb-title-<?php print $count; ?>" class="kb-title"><h3><?php print $row['field_kb_code_value'];?></h3> <?php print $row['title']; ?></div>
    <div id="kb-toggle-<?php print $count; ?>" class="kb-toggle">
      <?php unset($row['title']); ?>
      <?php unset($row['field_kb_code_value']); ?>
      <?php foreach ($row as $field => $content): ?>
      <div class="views-field views-field-<?php print $fields[$field]; ?>"><h4><?php print $header[$field]; ?></h4><?php print $content; ?></div>
      <?php endforeach; ?>
    </div>
  </div>
<?php endforeach; ?>
</div>
