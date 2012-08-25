<div class="<?php print $class; ?>">
<?php foreach ($rows as $count => $row): ?>
  <?php 
  //echo '<pre>';
  //print_r($title);
  //echo '<pre>';
  // We need to calculate the number of people participating in each thread (not the number of comments).
  // A separate view pulls unique author names and loads them into an array.
  // We just need to count the number of array elements.
  ?>
  <div class="<?php print implode(' ', $row_classes[$count]); ?>">
    <h4 class="views-field views-field-title"><?php print $row['title']; ?></h4>
    <div class="thread-meta">
      <span class="views-field views-field-author">Started by <?php print $row['name']; ?></span>
      <div>
        <span class="views-field views-field-created"><?php print $row['created']; ?></span>
        <span class="views-field views-field-replies"><?php print $row['comment_count']; ?></span>
      </div>
    </div>
  </div>
  <?php endforeach; ?>
</div>
