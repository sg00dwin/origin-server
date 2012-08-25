<table class="table <?php print $class; ?> view-forum">
  <?php if (!empty($title)) : ?>
    <caption><?php print $title; ?></caption>
  <?php endif; ?>
  <thead>
    <tr>
      <th class="views-header views-header-thread">Thread</th>
      <th class="views-header views-header-stats">Stats</th>
      <th class="views-header views-header-last-post">Last Post</th>
    </tr>
  </thead>
  <tbody>
    <?php foreach ($rows as $count => $row): ?>
      <?php 
      // We need to calculate the number of people participating in each thread (not the number of comments).
      // A separate view pulls unique author names and loads them into an array.
      // We just need to count the number of array elements.
      $unique_participants = views_embed_view('unique_users_per_thread', 'block_1', $row['nid']);
      
      // We will pull the image of the last comment author from another view.
      $last_comment_author_uid = $row['phpcode'];
      $last_comment_author_icon = views_embed_view('user_icon_from_uid', 'block_1', $last_comment_author_uid);
      ?>
      <tr class="<?php print implode(' ', $row_classes[$count]); $row['sticky'] == 'True' ? print ' sticky' : FALSE; ?>">
        <td>
          <div class="views-field views-field-title<?php $row['sticky'] == 'True' ? print' sprite-icon-bg sprite-icon-sticky': FALSE; ?>"><?php print $row['title']; ?></div>
          <?php $row['sticky'] == 'True' ? print '<div class="sticky-cell-wrapper">' : FALSE; ?>
          <div class="views-field views-field-name"><?php print $row['name']; ?></div>
          <div class="views-field views-field-comment-count sprite-icon-bg sprite-icon-replies"><?php print format_plural($row['comment_count'], '1 Reply', '@count Replies'); ?></div>
          <?php $row['sticky'] == 'True' ? print '</div>' : FALSE; ?>
        </td>
        <td>
          <div class="views-field views-field-participants sprite-icon-bg sprite-icon-people"><?php print $unique_participants; ?></div>
          <div class="views-field views-field-pageviews sprite-icon-bg sprite-icon-views"><?php print format_plural($row['totalcount'], '1 View', '@count Views'); ?></div>
        </td>
        <td>
          <div class="views-field views-field-picture"><?php print $last_comment_author_icon ?></div>
          <div class="picture-right">
            <div class="views-field views-field-last-comment-name"><?php print $row['last_comment_name']; ?></div>
            <div class="views-field views-field-last-comment_timestamp sprite-icon-bg sprite-icon-timestamp""><?php print $row['last_comment_timestamp']; ?></div>
          </div>
        </td>
      </tr>
    <?php endforeach; ?>
  </tbody>
</table>
