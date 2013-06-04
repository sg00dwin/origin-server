<?php

/**
 * @file
 * OpenShift Partner Self Service Portal template.
 */
?>
<div id='portal-welcome'><h2><?php print (t('Welcome')); ?> <?php print ($partner_level['partner_level']); ?></h2></div>
<div id='portal-get-started'><h3><?php print (t('Get Started Now!')); ?></h3>
  <div class='portal-upload'><?php print (l(t('UPLOAD: Company Information'), 'partner/portal/company-info')); ?></div>
  <div class='portal-download'>
    <?php if ($partner_level['partner_level'] == 'Ready Partner'): ?>
      <?php print (l(t('DOWNLOAD: Red Hat OpenShift Partner Logo'), file_directory_path() . '/openshift_partner_logos_ready.zip')); ?>
    <?php else: ?>
      <?php print (l(t('DOWNLOAD: Red Hat OpenShift Partner Logo'), file_directory_path() . '/openshift_partner_logos_advanced.zip')); ?>
    <?php endif; ?>
  </div>
</div>
<div id='portal-marketing'><h3><?php print (t('Marketing Assets')); ?></h3>
  <div class='portal-paas'>
    <?php print (l(t('The Road to Enterprise PaaS'), file_directory_path() . '/RH_Openshift_Enterprise_PaaS_WP_10204147_1112_dc_web copy.pdf')); ?>
  </div>
  <div class='portal-blog-content'>
    <?php print (l(t('Blog Content'), 'partner/portal/blog-content')); ?>
  </div>
  <div class='portal-social-media-posts'>
    <?php print (l(t('Social Media Posts'), 'partner/portal/social-media-posts')); ?>
  </div>
</div>
<div id='portal-submit'><h3><?php print (t('Manage Your Partnership')); ?></h3>
  <div class='portal-story'>
    <?php print (l(t('Submit a Customer Success Story'), 'partner/portal/customer-story')); ?>
  </div>
  <?php if ($partner_level['partner_level'] == 'Ready Partner'): ?>
    <div class='portal-upgrade'>
      <?php print (l(t('Request to Upgrade Partner Level'), 'partner/portal/upgrade')); ?>
    </div>
  <?php endif; ?>
  <div class='portal-materials'>
    <?php print (l(t('Request Assistance / Materials'), 'partner/portal/request-assistance')); ?>
  </div>
</div>
<div id='portal-questions'>
  <?php print (t('Questions? Email ') . l(t('openshift-partners@redhat.com'), 'mailto:openshift-partners@redhat.com')); ?>
</div>

