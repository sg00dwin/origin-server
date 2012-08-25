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

<table class="table <?php print $class; ?>">
  <?php if (!empty($title)) : ?>
    <caption><?php print $title; ?></caption>
  <?php endif; ?>
  <thead>
    <tr>
      <th class="views-header views-header-forum">Forum</th>
      <th class="views-header views-header-stats">Stats</th>
      <th class="views-header views-header-last-post">Last Post</th>
      <!--<th class="views-header views-header-membership">Membership</th>-->
    </tr>
  </thead>
  <tbody>
    <?php foreach ($rows as $count => $row): ?>
    <tr class="<?php print implode(' ', $row_classes[$count]); ?>">
      <td class="first-cell">
        <?php if($row['nid'] != 128): ?>
        <div class="views-field views-field-rss"><a href="<?php print base_path() .'forums/feeds/'. $row['nid']; ?>"><img src="<?php print base_path() . path_to_theme() .'/images/rss-icon.gif' ?>" alt="<?php print strip_tags($row['title']); ?> RSS" /></a></div>
        <?php endif; ?>
        <div class="views-field views-field-title"><?php print $row['title']; ?></div>
        <div class="views-field views-field-description"><?php print $row['description']; ?></div>
      </td>
      <td class="middle-cell">
        <div class="views-field views-field-thread-count"><?php print $row['post_count']; ?> threads</div>
        <div class="views-field views-field-pageviews"><?php print $row['totalcount']; ?> views</div>
      </td>
      <td class="last-cell">
        <?php print views_embed_view('threads_by_popularity', 'block_4', $row['nid']); ?>
      </td>
      <!--
      <td class="last-cell">
        <div class="views-field views-field-membership"><?php !empty($row['managelinkmy']) ? print $row['managelinkmy'] : print $row['subscribe']; ?></div>
      </td>
      -->
    </tr>
    <?php endforeach; ?>
  </tbody>
</table>
