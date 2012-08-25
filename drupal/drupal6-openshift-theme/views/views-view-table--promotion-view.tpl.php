<div class="<?php print $class; ?>">

<?php foreach ($rows as $count => $row): ?>
  <div class="<?php print implode(' ', $row_classes[$count]); ?>">
    <a href="<?php print $row['field_promo_url_url']; ?>" title="<?php print $row['title']; ?>">
      <img src="<?php print base_path() . $row['field_promo_image_fid']; ?>" alt="<?php print $row['title']; ?>" />
    </a>
  </div>
  <?php endforeach; ?>
</div>