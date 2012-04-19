<?php if ($rows[0]): ?>
<div class="author-bio-box">
  <div class="blog-author-image"><?php print $rows[0]['field_author_image_fid']; ?></div>
  <div class="title_1">by <?php print $rows[0]['title']; ?></div>
  <div class="field_author_profession_title_value"><?php print $rows[0]['field_author_profession_title_value']; ?></div>
  <div class="author-bio"><?php print $rows[0]['body']; ?></div>
</div>
<?php endif; ?>