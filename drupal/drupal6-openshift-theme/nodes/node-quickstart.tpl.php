<article id="node-<?php print $node->nid; ?>" class="quickstart node<?php if ($sticky) { print ' sticky'; } ?><?php if (!$status) { print ' node-unpublished'; } ?> node-quickstart">

<!-- <?php print_r($node); ?> -->
<?php if ($node->field_quickstart_icon[0]){ ?><div class="pull-right"><?php print $node->field_quickstart_icon[0]['view']; ?></div><?php } ?>
<h1 class="title"><?php print $title; ?></h1>
<div class="metadata"><?php 
  $trust = $node->field_quickstart_trust[0]; 
  if ($trust['value'] == 'partner' || $trust['value'] == 'openshift') {
    print "<span class='provider'>";
  } else {
    print "<span class='provider'>";
  }
  print check_plain($trust['view']);
  ?></span>
    <span class="divider"> | </span>
  <span class="created">Added by <?php print $node->name; ?> on <?php print readabledate($node->created); ?></span>
  <?php if ($node->comment_count > 0) { ?><span class="divider"> | </span><span class="comment-count"><?php print $node->comment_count; ?> comments</span><?php } ?>
  <?php if ($taxonomy): ?>
    <div class="terms">Tagged with: <?php print $terms ?></div>
  <?php endif;?>
  </div>


  <div class="content clear-block">
    <?php print $node->content['body']['#value']; ?>
    <p class="action-quickstart">
      <a class="pull-right btn btn-primary" href="<?php print openshift_server_url(); ?>/app/console/application_types/quickstart!<?php print check_plain($node->nid); ?>">Deploy Now!</a><?php 
        print application_quickstarts_summary(
          $node->field_cartridges_list[0]['value'], 
          $node->field_git_repository_url[0]['value']);
        ?></p>
    <?php print $field_code_language_rendered; ?>
    <?php print $field_website_rendered; ?>
  </div>

  <div class="clear-block">
    <div class="meta">
    </div>

    <?php if ($links): ?>
      <div class="links"><?php print $links; ?></div>
    <?php endif; ?>
  </div>

</article>
