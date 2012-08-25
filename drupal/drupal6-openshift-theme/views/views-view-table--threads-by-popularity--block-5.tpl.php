<h2>Recent Posts</h2>
<table class="table <?php print $class; ?>">
  <thead>
    <tr>
      <th class="views-header views-header-thread">Thread</th>
      <th class="views-header views-header-stats">Stats</th>
    </tr>
  </thead>
  <tbody>
    <?php foreach ($rows as $count => $row): ?>
      <?php 
      //echo '<pre>';
      //print_r($row);
      //echo '</pre>';
      ?>
      <tr>
        <td>
          <div class="views-field views-field-title"><?php print $row['title']; ?></div>
        </td>
        <td>
          <span class="views-field views-field-pageviews sprite-icon-bg sprite-icon-views"><?php print format_plural($row['totalcount'], '1 View', '@count Views'); ?></span>
          <span class="views-field views-field-pageviews sprite-icon-bg sprite-icon-timestamp"><?php print $row['created']; ?></span>
        </td>
      </tr>
      <tr>
        <td colspan="2">
          <?php print $row['teaser']; ?>
        </td>  
      </tr>
      <tr class="last-row">
        <td>
          <h4>FORUM</h4>
          <div class="views-field views-field-forum"><?php print $row['group_nid']; ?></div>
        </td>
        <td>
          <div class="views-field views-field-link"><?php print $row['view_node']; ?></div>
        </td>
      </tr>
    <?php endforeach; ?>
  </tbody>
</table>
