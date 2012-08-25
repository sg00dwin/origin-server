<?php
// $Id: views-view.tpl.php,v 1.13.2.2 2010/03/25 20:25:28 merlinofchaos Exp $
/**
 * @file views-view.tpl.php
 * Main view template
 *
 * Variables available:
 * - $classes_array: An array of classes determined in
 *   template_preprocess_views_view(). Default classes are:
 *     .view
 *     .view-[css_name]
 *     .view-id-[view_name]
 *     .view-display-id-[display_name]
 *     .view-dom-id-[dom_id]
 * - $classes: A string version of $classes_array for use in the class attribute
 * - $css_name: A css-safe version of the view name.
 * - $css_class: The user-specified classes names, if any
 * - $header: The view header
 * - $footer: The view footer
 * - $rows: The results of the view query, if any
 * - $empty: The empty text to display if the view is empty
 * - $pager: The pager next/prev links to display, if any
 * - $exposed: Exposed widget form/info to display
 * - $feed_icon: Feed icon to display, if any
 * - $more: A link to view more, if any
 * - $admin_links: A rendered list of administrative links
 * - $admin_links_raw: A list of administrative links suitable for theme('links')
 *
 * @ingroup views_templates
 */
?>
<?php
if(module_exists('og_comment_perms')) {
  $do = og_comment_perms_do();
}
?>


<form action="/community/search/node" method="post" class="form-search custom-form-search">
<input class="span6" placeholder="Search forums..." type="text" value="" name="keys" />
<input type="submit" value="" name="op" class="btn btn-primary" title="Search OpenShift forums" alt="Search OpenShift forums" />
<input type="hidden" value="<?php print drupal_get_token('search_form'); ?>" name="form_token" />
<input type="hidden" value="search_form" id="edit-search-form" name="form_id" />
<input type="hidden" name="type[discussion]" id="edit-discussion" value="discussion" />
</form>

<div class="search-help"><strong>Advanced options:</strong> quotes search for <strong>"exact phrase"</strong>, dash excludes a <strong>-keyword</strong>, OR matches any <strong>keyword OR term</strong></div>



<?php if ($forum): ?>
<div id="forum-header">
<div class="forum-header-right pull-right">
<ul class="forum-navigation-links unstyled">
    <li><a href="<?php print base_path(); ?>forums"><?php print t('Main List of Forums'); ?></a></li>
</ul>
</div>
<!--div class="forum-header-left">
<div class="forum-header-hat">Forum</div>
<h2><?php print $forum['heading']; ?></h2>
<div class="forum-header-description"><?php print $forum['description']; ?></div>
</div-->

<div class="post-to-forum">
<?php print $forum['feed']; ?>
<?php if ($do->perm == 'post'): ?>
<div class="new-post-button"><a class='action-more'
	href="<?php print base_path(); ?>node/add/discussion/<?php print $forum['alias']; ?>?gids[]=<?php print $forum['nid']; ?>">Post
New Thread</a></div>
<?php elseif ($do->perm == 'join'): ?>
<div><?php print t('You need to !join this group before you can post a new thread.', array('!join' => l(t('join'), 'og/subscribe/'. $do->group->nid))); ?></div>
<?php elseif (!$user->uid): ?>
<div><?php print t('!Login to post a new thread.', array('!Login' => l(t('Login'), variable_get('redhat_sso_login_url')))); ?></div>
<?php endif; ?></div>
<!--div class="forum-header-right"> Place holder for Pager </div-->
</div>
<?php endif; ?>


<div class="<?php print $classes; ?>">
  <?php if ($admin_links): ?>
    <div class="views-admin-links views-hide">
      <?php print $admin_links; ?>
    </div>
  <?php endif; ?>
  <?php if ($header): ?>
    <div class="view-header">
      <?php print $header; ?>
    </div>
  <?php endif; ?>

  <?php if ($exposed): ?>
    <div class="view-filters">
      <?php print $exposed; ?>
    </div>
  <?php endif; ?>

  <?php if ($attachment_before): ?>
    <div class="attachment attachment-before">
      <?php print $attachment_before; ?>
    </div>
  <?php endif; ?>

  <?php if ($rows): ?>
    <div class="view-content">
      <?php print $rows; ?>
    </div>
  <?php elseif ($empty): ?>
    <div class="view-empty">
      <?php print $empty; ?>
    </div>
  <?php endif; ?>

  <?php if ($pager): ?>
    <?php print $pager; ?>
  <?php endif; ?>

  <?php if ($attachment_after): ?>
    <div class="attachment attachment-after">
      <?php print $attachment_after; ?>
    </div>
  <?php endif; ?>

  <?php if ($more): ?>
    <?php print $more; ?>
  <?php endif; ?>

  <?php if ($footer): ?>
    <div class="view-footer">
      <?php print $footer; ?>
    </div>
  <?php endif; ?>

  <?php if ($feed_icon): ?>
    <div class="feed-icon">
      <?php print $feed_icon; ?>
    </div>
  <?php endif; ?>

</div> <?php /* class view */ ?>
