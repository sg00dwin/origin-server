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
<?php
//echo '<pre>';
//print_r($rows);
//echo '</pre>';
//<h2>Blogs</h2>
?>
<div class="<?php print $class; ?>">
<?php if (!empty($title)) : ?>
<?php endif; ?>

<?php foreach ($rows as $count => $row): ?>
  <article class="blog <?php print implode(' ', $row_classes[$count]); ?> view-row">
  <?php foreach ($row as $field_name => $value): ?>
    <?php if ($field_name == 'comment_count'): ?>
      <?php //Here should be some validation to add singular/plural forms of the word 'comment' ?>
    <?php elseif ($field_name == 'title'): ?>
      <h2 class="<?php print $field_name; ?>"><?php print $value; ?></h2>
    <?php elseif ($field_name == 'title_1'): ?>
      <div class="breadcrumb"><span class="creator"><?php print $value; ?></span> <span class="divider">/</span> <span class="created"><?php print $row['created']; ?></span></div>
    <?php elseif ($field_name == 'teaser'): ?>
      <div class="<?php print $field_name; ?>">
        <?php print $value; ?>
        <?php if (isset($row['nid'])): ?>
          <div class="nid action-more"><?php print $row['nid']; ?></div>
        <?php endif; ?>
      </div>
    <?php elseif ($field_name == 'created' || $field_name == 'nid'): ?>
    <?php else: ?>
      <div class="<?php print $field_name; ?>"><?php print $value; ?></div>
    <?php endif; ?>
  <?php endforeach; ?>
  </article>
<?php endforeach; ?>
</div>
