<?php
//echo '<pre>';
//print_r($node->uid);
//$user->uid;
//echo '</pre>';
$do = og_comment_perms_do();
?>

<section id="node-<?php print $node->nid; ?>" class="<?php if ($sticky) { print ' sticky'; } ?><?php if (!$status) { print ' node-unpublished'; } ?>">

<div class="breadcrumb"><a href="/community/events">Events</a><span class="divider"> /</span>CodeStrong</div>

<div class="events-post node node-events">

  <div class="row">
  <div class="span9">
    <div class="event-metadata">
    <figure class="pull-right related-block">
    <div class="related-logo" style="margin-right: 10%;"><img src="http://lacot.org/media/original/blog/2011/09/logo-codestrong.png" alt="codestrong logo" />
    </div>
    </figure>
    
    <h1><?php print $title ?></h1>
    <p class="event-date">
    	<?php print $node->field_event_start_date[0]["view"] ?>
    	<a href="" class="add-calendar">Add to calendar</a>
    </p>
    
    <h4>Intercontinental Hotel</h4>
    <?php print $node->field_event_city[0]["view"] ?>, 
    <?php print $node->field_event_state[0]["view"] ?>
    <?php print $node->field_event_country[0]["view"] ?><br />
    <?php print $node->field_event_url[0]["view"] ?><br />
    
    </div>

    <p>
    	<?php print $node->content["body"]["#value"] ?>
    </p>

    <?php print $node->field_event_categories[0]["view"] ?>
    
    </div>
  </div><!-- /row -->

</div>  
</section>

<!--
<pre>
	<?php //print_r($node); ?>
</pre>
-->