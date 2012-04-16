<div class="<?php print $class; ?>">
<?php foreach ($rows as $count => $row): ?>
  <?php 
  //echo '<pre>';
  //print_r($title);
  //echo '<pre>';
  // We need to calculate the number of people participating in each thread (not the number of comments).
  // A separate view pulls unique author names and loads them into an array.
  // We just need to count the number of array elements.
  $unique_participants = views_embed_view('unique_users_per_thread', 'block_1', $row['nid']);
  ?>
  <div class="<?php print implode(' ', $row_classes[$count]); ?>">
    <div class="block-header">
      <div class="views-field views-field-picture"><?php print $row['picture']; ?></div>
      <span class="views-field views-field-title"><?php print $row['title']; ?></span>
      <span class="views-field views-field-author">Started by <?php print $row['name']; ?></span>
    </div>
    <div class="block-stats">
      <div class="views-field views-field-created sprite-icon-bg sprite-icon-timestamp"><?php print $row['created']; ?></div>
      <div class="views-field views-field-replies sprite-icon-bg sprite-icon-replies" style="background-position: 0 -133px;"><?php print format_plural($row['comment_count'], '1 reply', '@count replies'); ?></div>
      <div class="views-field views-field-people sprite-icon-bg sprite-icon-people"><?php print strtolower($unique_participants); ?></div>
    </div>
      <h4>Forum:</h4>
      <div class="views-field views-field-group-name"><?php print $row['group_nid']; ?></div>
    
  </div>
  <?php endforeach; ?>
</div>