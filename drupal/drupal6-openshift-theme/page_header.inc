<!DOCTYPE html>
<!--[if lt IE 7]> <html class="ie6 no-js" lang="en"> <![endif]-->
<!--[if IE 7]>    <html class="ie7 no-js" lang="en"> <![endif]-->
<!--[if IE 8]>    <html class="ie8 no-js" lang="en"> <![endif]-->
<!--[if gt IE 8]><!-->
<html class='no-js' lang='en'>
  <!--<![endif]-->
  <head>
    <meta charset='utf-8'>
    <meta content='IE=edge,chrome=1' http-equiv='X-UA-Compatible'>
    <?php print $head; ?>
    <title><?php print $head_title; ?></title>
    <?php if ($node && isset($node->field_search_meta_description) && $node->field_search_meta_description[0]) { ?>
    <meta name="description" content="<?php print $node->field_search_meta_description[0]['safe']; ?>">
    <?php }

      $openshift_server_url = openshift_server_url();
      // reference CSS files directly from openshift
      //print_r(menu_get_active_trail());
      global $base_url;
      global $base_root;
      if (empty($sidebar_left)) {
        if (empty($sidebar_right)) { $layout = 'none'; }
        else { $layout = 'right'; }
      }
      else {
        if (empty($sidebar_right)) { $layout = 'left'; }
        else { $layout = 'both'; }
      }
    ?> 
    <link type="image/png" rel="shortcut icon" href="<?php print $openshift_server_url; ?>/app/assets/favicon-32.png"></link>
    <link type="text/css" rel="stylesheet" href="<?php print $openshift_server_url; ?>/app/assets/overpass.css"></link>
    <script src="<?php print $openshift_server_url; ?>/app/assets/modernizr.min.js" type="text/javascript"></script>
    <link type="text/css" rel="stylesheet" href="<?php print $openshift_server_url; ?>/app/assets/common.css"></link>
    <link type="text/css" rel="stylesheet" href="<?php print $openshift_server_url; ?>/app/assets/site.css"></link>
	  <?php print $styles; ?>
    <script type="text/javascript" src="<?php print $openshift_server_url; ?>/app/assets/application.js"></script>
    <script type="text/javascript">
      $.ajaxPrefilter(function(options, orig, jqXHR) { 
        if (options.dataType == 'json') {
          options.dataType = 'postjson';
          options.dataTypes = ['postjson']; // supposedly this isn't necessary but couldn't get it to work without it
        }
      });
      $.ajaxSetup({
        converters: {
          "text postjson": function(text) {
            try { return $.parseJSON(text); }
            catch(e) { 
              return window.eval('(' + text + ');');
            }
          }
        }
      });
    </script>
	  <?php print $scripts; ?>
    <meta content='' name='author'>
    <meta content='width=device-width, initial-scale=1.0' name='viewport'>
    <meta name="csrf-param" content="authenticity_token"/>
    <meta name="csrf-token" content="+CyXrdA5MZFVwLks73ibMfRiwRE+ixICENvvHms1Exk="/>
  </head>
  <body class='<?php print $body_classes; ?> community'>
