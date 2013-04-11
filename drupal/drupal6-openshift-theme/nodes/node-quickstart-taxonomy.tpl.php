<div id="node-<?php print $node->nid; ?>" class="quickstart view-application-quickstarts-content">
<div class="views-row">
  <?php if ($node->field_quickstart_icon[0]){ ?><div class="pull-right"><?php print $node->field_quickstart_icon[0]['view']; ?></div><?php } ?>
  <div class="views-field-title"><h3><a href="<?php print url($node->path); ?>"><?php print $title; ?></a></h3></div>
  <div class="views-field-created">
  <!-- <?php print_r($node); ?> -->
    <?php 
      $trust = $node->field_quickstart_trust[0]; 
      if (!empty($trust['value'])) {

        ?><div class="metadata"><?php

        if ($trust['value'] == 'partner' || $trust['value'] == 'openshift') {
          print "<span class='provider trusted'>";
        } else {
          print "<span class='provider'>";
        }
        print check_plain($trust['view']);

        ?></span></div><?php
      }
      ?>
  </div>
  <div class="views-field-teaser">
    <?php print views_trim_text(array('max_length' => 400, 'html' => true), $node->content['body']['#value']); ?>
  </div>

  <?php if ($taxonomy): ?>
    <div class="views-field-tid terms">Tags: <?php print $terms ?></div>
  <?php endif;?>
</div>
</div>
