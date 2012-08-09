<?php
/*
 * Allows us to keep the theme registry cleared during build.  This will affect .local and .vmldev
 * so if you want to use this capability make sure your servername has (.local - ex. cbi.local) for
 * this to work or modify to fit your local install.
 */

//if (preg_match('/(vmldev\.com|local)$/', $_SERVER['SERVER_NAME'])) {
//  drupal_rebuild_theme_registry();
//}

// Add the CSS for the vote up/down module on all pages.
// This eliminates a bug with AJAX comments and vote up/down not working together.

function openshift_theme() {
  return array(
    'comment_form' => array('arguments' => array(
      'form' => NULL,
      'edit' => NULL,
    ))
  );
}

function openshift_comment_form($form, $edit=array()) {
  global $user;
  if ($user->uid && (empty($edit['cid']) || !user_access('administer comments'))) {
    $form['_author'] = NULL;
  }
  return drupal_render($form);
}

function openshift_imagecache($presetname, $path, $alt = '', $title = '', $attributes = NULL, $getsize = TRUE) {
	/* Begin Override */
	// Don't display a user's email address in the ALT tag.
	$alt = '';
	/* End Override */
  // Check is_null() so people can intentionally pass an empty array of
  // to override the defaults completely.
  if (is_null($attributes)) {
    $attributes = array('class' => 'imagecache imagecache-'. $presetname);
  }
  if ($getsize && ($image = image_get_info(imagecache_create_path($presetname, $path)))) {
    $attributes['width'] = $image['width'];
    $attributes['height'] = $image['height'];
  }

  $attributes = drupal_attributes($attributes);
  $imagecache_url = imagecache_create_url($presetname, $path);
  return '<img src="'. $imagecache_url .'" alt="'. check_plain($alt) .'" title="'. check_plain($title) .'" '. $attributes .' />';
}


function openshift_preprocess_page(&$vars) {

  //menu_set_active_menu_name('community_navigation');
  //drupal_set_header('X-UA-Compatible', 'IE=edge,chrome=1');

  // Setup variables to display the correct banners on node/add/discussion pages.
  if (arg(0) == 'node' && arg(1) == 'add' && arg(2) == 'discussion') {
    switch (arg(3)) {
      case 'openshift':
        $vars['forum']['new-topic'] = TRUE;
        break;
      case 'flex':
        $vars['forum']['new-topic'] = TRUE;
        break;
      case 'news-and-announcements':
        $vars['forum']['new-topic'] = TRUE;
        break;
      default:
        $vars['forum']['new-topic'] = FALSE;
    }
  }
  // Hackish way to detect the forums but right now the page
  // vars aren't being set properly. 404s?
  if(in_array($vars['node']->type, array('discussion', 'group'))) {
    list($vars['product']) = explode(' ', trim($vars['section_title']));
  }

  // surface the highest navigation node
  // FIXME replace with better integration with drupal site nav and taxonomies
  $vars['heading'] = _openshift_heading($vars);

  _openshift_whitelist_css($vars);
}

function _openshift_page_arguments($item) {
  $args = $item['page_arguments'];
  if ($args && $args[0]) {
    return $args[0];
  }
  return NULL;
}

/* whitelist */
function _openshift_whitelist_css(&$vars)
{
  drupal_add_css(drupal_get_path('module', 'vud') .'/widgets/updown/updown.css', 'module', 'all', FALSE);

  $css = drupal_add_css();
  foreach ( $css['all']['module'] as $stylesheet => $val ) {
    if (preg_match("/\/(defaults|system|system-menus)\\.css/", $stylesheet)) {
      unset($css['all']['module'][$stylesheet]);
    }
  }
  $vars['styles'] = drupal_get_css($css);

  /*drupal_add_js(drupal_get_path('theme', 'openshift') . '/js/flag.js', 'theme');
  $scripts = drupal_add_js();
  unset($scripts['module']['sites/all/modules/contrib/flag/theme/flag.js']);
  $vars['scripts'] = drupal_get_js('header', $scripts);  */
}

function openshift_pager($tags = array(), $limit = 10, $element = 0, $parameters = array(), $quantity = 9) {
  global $pager_page_array, $pager_total;

  // Calculate various markers within this pager piece:
  // Middle is used to "center" pages around the current page.
  $pager_middle = ceil($quantity / 2);
  // current is the page we are currently paged to
  $pager_current = $pager_page_array[$element] + 1;
  // first is the first page listed by this pager piece (re quantity)
  $pager_first = $pager_current - $pager_middle + 1;
  // last is the last page listed by this pager piece (re quantity)
  $pager_last = $pager_current + $quantity - $pager_middle;
  // max is the maximum page number
  $pager_max = $pager_total[$element];
  // End of marker calculations.

  // Prepare for generation loop.
  $i = $pager_first;
  if ($pager_last > $pager_max) {
    // Adjust "center" if at end of query.
    $i = $i + ($pager_max - $pager_last);
    $pager_last = $pager_max;
  }
  if ($i <= 0) {
    // Adjust "center" if at start of query.
    $pager_last = $pager_last + (1 - $i);
    $i = 1;
  }
  // End of generation loop preparation.

  $li_first = theme('pager_first', t('←'), $limit, $element, $parameters);
  $li_previous = theme('pager_previous', t('«'), $limit, $element, 1, $parameters);
  $li_next = theme('pager_next', t('»'), $limit, $element, 1, $parameters);
  $li_last = theme('pager_last', t('→'), $limit, $element, $parameters);

  if ($pager_total[$element] > 1) {
    if ($li_first) {
      $items[] = array(
        'data' => $li_first,
      );
    }
    if ($li_previous) {
      $items[] = array(
        'data' => $li_previous,
      );
    }

    // When there is more than one page, create the pager list.
    if ($i != $pager_max) {
      if ($i > 1) {
        $items[] = array(
          'class' => 'disabled', 
          'data' => '<a>...</a>',
        );
      }
      // Now generate the actual pager piece.
      for (; $i <= $pager_last && $i <= $pager_max; $i++) {
        if ($i < $pager_current) {
          $items[] = array(
            'data' => theme('pager_previous', $i, $limit, $element, ($pager_current - $i), $parameters),
          );
        }
        if ($i == $pager_current) {
          $items[] = array(
            'class' => 'active', 
            'data' => theme('pager_link', $i, $limit, $element, $i, $parameters),
          );
        }
        if ($i > $pager_current) {
          $items[] = array(
            'data' => theme('pager_next', $i, $limit, $element, ($i - $pager_current), $parameters),
          );
        }
      }
      if ($i < $pager_max) {
        $items[] = array(
          'class' => 'disabled', 
          'data' => '<a>...</a>',
        );
      }
    }
    // End generation.
    if ($li_next) {
      $items[] = array(
        'data' => $li_next,
      );
    }
    if ($li_last) {
      $items[] = array(
        'data' => $li_last,
      );
    }
    return '<div class="pagination">'. theme('item_list', $items, NULL, 'ul') . '</div>';
  }
}

/* FIXME Replace with a better site hierarchy concept which allows heading to be inferred from
 * the last left nav item (community navigation is not visible via get_active_trail because items
 * aren't parented).
 */
function _openshift_heading(&$vars) {
  $page_title = $vars['title'];
  //print "<!-- page_title: ".$page_title."-->";
  $item = end(menu_get_active_trail());
  if ($vars['forum']['new-topic']) {
    $type = 'discussion';
  }
  elseif ($item['path'] == 'node/%' && $item['page_arguments'] && $item['page_arguments'][0]) {
    $node = $item['page_arguments'][0];
    $type = $node->type;
    $title = $node->title;
    //print "<!-- title from node: ".$title."-->";
  }
  elseif ($item['path'] == 'comment/reply/%' && $item['page_arguments'] && $item['page_arguments'][0]) {
    $node = $item['page_arguments'][0];
    $type = $node->type;
  }
  elseif ($item['link_path']) {
    $type = $item['link_path'];
    /*if ($item['title_callback']) {
      $arguments = $item['title_arguments'];
      if (is_array($arguments)) {
        $title = call_user_func_array($item['title_callback'], $arguments);
      }
    }
    if (empty($title)) {*/
    $title = $page_title;
    if (empty($title)) {
      $title = $item['title'];
    }
    //print "<!-- title from link_path: ".$title."-->";
  }
  //FIXME: forums doesn't have a type, is this something we can detect via view config?
  elseif ($item['href'] == '<front>') {
    $type = 'openshift';
  }
  switch ($type) {
  case 'home': $heading = "Overview"; break;
  case 'ideas':
  case 'idea': $heading = "Vote on Features"; break;
  case 'poll':
  case 'polls': $heading = "Polls"; break;
  case 'wiki_page':
  case 'wikis': $heading = "Open Source Wiki"; break;
  case 'discussion':
  case 'groups':
  case 'group': $heading = "Forums"; break;
  case 'documentation': $heading = "Documentation"; break; // no title for some reason
  case 'community': $heading = "Welcome to OpenShift"; break; // override the default link title
  case 'calendar':
  case 'event':
  case 'events': $heading = "Events"; break; // no title for some reason
  case 'knowledge_base':
  case 'kb': $heading = "Knowledge Base"; break; // no title for some reason
  case 'blogs': // no title for some reason
  case 'blog': $heading = "Blogs"; break;
  case 'faq': $heading = "Frequently Asked Questions"; break;
  case 'videos': // no title for some reason
  case 'video': $heading = "Videos"; break;
  default:
    $heading = $title;
  }
  //print "<!-- final heading: ".$heading."-->";
  return $heading;
}

function openshift_breadcrumb($breadcrumb) {
  if (!empty($breadcrumb) && count($breadcrumb) > 2) {
    //array_unshift($breadcrumb, "<a href='http://openshift.redhat.com/app' class='active'>OpenShift</a>");
    array_shift($breadcrumb);
    return '<div class="breadcrumb">' . implode('<span class="divider"> /</span>', $breadcrumb) . '</div>';
  }
}

function openshift_menu_tree($tree) {
  return '<ul class="menu nav nav-list">'. $tree .'</ul>';
}

function openshift_menu_item($link, $has_children, $menu = '', $in_active_trail = FALSE, $extra_class = NULL) {
  $class = ($menu ? 'expanded' : ($has_children ? 'collapsed' : 'leaf'));
  if (!empty($extra_class)) {
    $class .= ' '. $extra_class;
  }
  if ($in_active_trail) {
    $class .= ' active';
  }
  return '<li class="'. $class .'">'. $link . $menu ."</li>\n";
}

function openshift_preprocess_node(&$vars) {
  $path = request_uri();
  $path_parts = explode('/', $path);
  $forum = $path_parts[2];

  switch ($forum) {
    case 'openshift':
      $vars['forum']['id'] = 'openshift';
      $vars['forum']['title'] = 'OpenShift Forum';
      break;
    case 'flex':
      $vars['forum']['id'] = 'flex';
      $vars['forum']['title'] = 'Flex Forum';
      break;
    case 'news-and-announcements':
      $vars['forum']['id'] = 'news-and-announcements';
      $vars['forum']['title'] = 'News and Announcements';
      break;
    default:
      $vars['forum'] = NULL;
  }
  
  // Theme the links appended to each discussion node.
  _openshift_theme_subscription_links($vars['links']);
  
  // FIXME replace with better integration with drupal site nav and taxonomies
  $vars['heading'] = _openshift_heading($vars);
}

function _openshift_theme_subscription_links(&$links) {
  $links = str_replace('<em>', '', $links);
  $links = str_replace('</em>', '', $links);
  $links = str_replace('Subscribe to: This post', 'Subscribe to this thread', $links);
  $links = str_replace('Unsubscribe from: This post', 'Unsubscribe from this thread', $links);
  $links = str_replace('Subscribe to: Discussion posts in', 'Subscribe to ', $links);
  $links = str_replace('Unsubscribe from: Discussion posts in', 'Unsubscribe from ', $links);
  $links = str_replace('Subscribe to: Posts by ', 'Subscribe to ', $links);
  $links = str_replace('Unsubscribe from: Posts by ', 'Unsubscribe from ', $links);
}

function openshift_form_element($element, $value) {
  // This is also used in the installer, pre-database setup.
  $t = get_t();

  $output = '<div class="control-group"';
  if (!empty($element['#id'])) {
    $output .= ' id="'. $element['#id'] .'-wrapper"';
  }
  $output .= ">\n";
  $required = !empty($element['#required']) ? '<span class="form-required" title="'. $t('This field is required.') .'">*</span>' : '';

  if (!empty($element['#title'])) {
    $title = $element['#title'];
    if (!empty($element['#id'])) {
      $output .= ' <label for="'. $element['#id'] .'">'. $t('!title: !required', array('!title' => filter_xss_admin($title), '!required' => $required)) ."</label>\n";
    }
    else {
      $output .= ' <label>'. $t('!title: !required', array('!title' => filter_xss_admin($title), '!required' => $required)) ."</label>\n";
    }
  }

  $output .= " <div class='controls'>";
  $output .= $value;

  if (!empty($element['#description'])) {
    $output .= ' <div class="help-block">'. $element['#description'] ."</div>\n";
  }
  
  $output .= "</div>";

  $output .= "</div>\n";

  return $output;
}

function openshift_button($element) {
  // Make sure not to overwrite classes.
  $id = $element['#id'];
  $class = 'btn';
  if ($id) {
    if (openshift_ends_with($id, '-submit')) {
      $class .= ' btn-primary';
    }
    else if (openshift_ends_with($id, '-delete')) {
      $class .= ' btn-danger';
    }
  }
  if (isset($element['#attributes']['class'])) {
    $element['#attributes']['class'] = $class . ' form-'. $element['#button_type'] .' '. $element['#attributes']['class'];
  }
  else {
    $element['#attributes']['class'] = $class . ' form-'. $element['#button_type'];
  }

  return '<input type="submit" '. (empty($element['#name']) ? '' : 'name="'. $element['#name'] .'" ') .'id="'. $element['#id'] .'" value="'. check_plain($element['#value']) .'" '. drupal_attributes($element['#attributes']) ." />\n";
}

function openshift_radio($element) {
  _form_set_class($element, array('form-radio'));
  $output = '<input type="radio" ';
  $output .= 'id="'. $element['#id'] .'" ';
  $output .= 'name="'. $element['#name'] .'" ';
  $output .= 'value="'. $element['#return_value'] .'" ';
  $output .= (check_plain($element['#value']) == $element['#return_value']) ? ' checked="checked" ' : ' ';
  $output .= drupal_attributes($element['#attributes']) .' />';
  if (!is_null($element['#title'])) {
    $output = '<label class="radio" for="'. $element['#id'] .'">'. $output .' '. $element['#title'] .'</label>';
  }

  unset($element['#title']);
  return theme('form_element', $element, $output);
}

function openshift_checkbox($element) {
  _form_set_class($element, array('form-checkbox'));
  $checkbox = '<input ';
  $checkbox .= 'type="checkbox" ';
  $checkbox .= 'name="'. $element['#name'] .'" ';
  $checkbox .= 'id="'. $element['#id'] .'" ' ;
  $checkbox .= 'value="'. $element['#return_value'] .'" ';
  $checkbox .= $element['#value'] ? ' checked="checked" ' : ' ';
  $checkbox .= drupal_attributes($element['#attributes']) .' />';

  if (!is_null($element['#title'])) {
    $checkbox = '<label class="checkbox" for="'. $element['#id'] .'">'. $checkbox .' '. $element['#title'] .'</label>';
  }

  unset($element['#title']);
  return theme('form_element', $element, $checkbox);
}

function openshift_preprocess_search_block_form(&$vars) {
//  $vars['form']['text']['#class'] = 'input-small search-query';
//  $vars['search']['text'] = drupal_render($vars['form']['text']);

  $vars['form']['submit']['#class'] = 'btn';
  $vars['search']['submit'] = drupal_render($vars['form']['submit']);

  $vars['form']['search_block_form']['#attributes'] = array('class' => 'form-search');
  unset($vars['form']['search_block_form']['#title']);
  unset($vars['form']['search_block_form']['#printed']);
  $vars['search']['search_block_form'] = drupal_render($vars['form']['search_block_form']);

  // Collect all form elements to print entire form
  $vars['search_form'] = implode($vars['search']);
}

function openshift_preprocess_search_result(&$vars) {
  if ($vars['type'] == 'user'){
    $vars['title'] = strip_email($vars['title']);
  }
}

function openshift_filter_tips($tips, $long = FALSE, $extra = '') {
  $output = '';

  $multiple = count($tips) > 1;
  if ($multiple) {
    $output = t('input formats') .':';
  }

  if (count($tips)) {
    if ($multiple) {
      $output .= '<ul>';
    }
    foreach ($tips as $name => $tiplist) {
      if ($multiple) {
        $output .= '<li>';
        $output .= '<strong>'. $name .'</strong>:<br />';
      }

      if (count($tiplist) > 0) {
        $output .= '<ul class="tips unstyled">';
        foreach ($tiplist as $tip) {
          $output .= '<li'. ($long ? ' id="filter-'. str_replace("/", "-", $tip['id']) .'">' : '>') . $tip['tip'] .'</li>';
        }
        $output .= '</ul>';
      }

      if ($multiple) {
        $output .= '</li>';
      }
    }
    if ($multiple) {
      $output .= '</ul>';
    }
  }

  return $output;
}

function openshift_links($links, $attributes = array('class' => 'links')) {
  
  // Begin Override
  // Remove the statistics counter on every node.
  if ($links['statistics_counter']) {
  	unset($links['statistics_counter']);
  }
  // End Override
	
  global $language;
  $output = '';

  if (count($links) > 0) {

    /*$attributes['class'] = 'btn-group ' . (isset($attributes['class']) ? $attributes['class'] : '');*/
    $output = '<div'. drupal_attributes($attributes) .'>';

    $num_links = count($links);
    $i = 1;

    foreach ($links as $key => $link) {
      $class = $key;

      // Add first, last and active classes to the list of links to help out themers.
      if ($i == 1) {
        $class .= ' first';
      }
      if ($i == $num_links) {
        $class .= ' last';
      }
      if (isset($link['href']) && ($link['href'] == $_GET['q'] || ($link['href'] == '<front>' && drupal_is_front_page()))
          && (empty($link['language']) || $link['language']->language == $language->language)) {
        $class .= ' active';
      }
      //$output .= '<li'. drupal_attributes(array('class' => $class)) .'>';

      if (isset($link['href'])) {
        if (!isset($link['attributes'])) {
          $link['attributes'] = array();
        }
        $link_attributes = $link['attributes'];
        $link['attributes']['class'] = /*'btn '.*/$class;// . (isset($link_attributes['class']) ? $link_attributes['class'] : '');
        // Pass in $link as $options, they share the same keys.
        $output .= l($link['title'], $link['href'], $link);
      }
      else if (!empty($link['title'])) {
        // Some links are actually not links, but we wrap these in <span> for adding title and class attributes
        if (empty($link['html'])) {
          $link['title'] = check_plain($link['title']);
        }
        $span_attributes = '';
        if (isset($link['attributes'])) {
          $span_attributes = drupal_attributes($link['attributes']);
        }
        $output .= $link['title']; //.= '<span'. $span_attributes .'>'. $link['title'] .'</span>';
      }

      $i++;
      //$output .= "</li>\n";
    }

    $output .= '</div>';
  }

  return $output;
}


function openshift_status_messages($display = NULL) {
  $output = '';
  foreach (drupal_get_messages($display) as $type => $messages) {
    $output .= "<div class=\"messages $type\">\n";
    if (count($messages) > 1) {
      foreach ($messages as $message) {
        $output .= " <div class=\"alert alert-$type\">" . $message . "</div>";
      }
    }
    else {
      $output .= " <div class=\"alert alert-$type\">" . $messages[0] . "</div>";
    }
    $output .= "</div>\n";
  }
  return $output;
}

function openshift_menu_local_tasks() {
  $output = '';

  if ($primary = menu_primary_local_tasks()) {
    $output .= "<ul class=\"nav nav-tabs primary\">\n". $primary ."</ul>\n";
  }
  if ($secondary = menu_secondary_local_tasks()) {
    $output .= "<ul class=\"nav nav-tabs secondary\">\n". $secondary ."</ul>\n";
  }

  return $output;
}

function openshift_preprocess_views_view(&$vars) {

  if ($vars['view']->name === 'knowledge_base') {
    drupal_add_js(drupal_get_path('theme', 'redhat') .'/js/redhat.js', 'theme');
  }
  
  // We are displaying a thread list from a group.
  if ($vars['view']->name === 'og_ghp_thread_list') {
    
 	// Pass forum information to the view.
    $path = arg(0) .'/'. arg(1);
    switch ($path) {
      case 'node/1':
      	$vars['forum']['nid'] = '1';
      	$vars['forum']['alias'] = 'openshift';
        $vars['forum']['heading'] = 'OpenShift';
        $vars['forum']['description'] = _openshift_get_group_description(arg(1));
        break;
      case 'node/2':
      	$vars['forum']['nid'] = '2';
      	$vars['forum']['alias'] = 'flex';
        $vars['forum']['heading'] = 'Flex';
        $vars['forum']['description'] = _openshift_get_group_description(arg(1));
        break;
      case 'node/3':
      	$vars['forum']['nid'] = '3';
      	$vars['forum']['alias'] = 'news-and-announcements';
        $vars['forum']['heading'] = 'News and Announcements';
        $vars['forum']['description'] = _openshift_get_group_description(arg(1));
        break;
      default:
        $vars['forum'] = NULL;
    }
    $feed = base_path() . 'forums/feeds/' . $vars['forum']['nid'];
    $vars['forum']['feed'] = theme_feed_icon($feed, 'Subscribe to the RSS feed for this forum');
  }
}

function _openshift_get_group_description($node_id) {
  $group_description = db_result(db_query("SELECT og_description FROM {og} as d
    WHERE d.nid = %d", array($node_id)));
  return $group_description;
}

function openshift_username($object) {

  if ($object->uid && $object->name) {
  	// BEGIN OVERRIDE.  If the user has provided a display name, we need to show the 
  	// display name instead of the username.
    $result = db_result(db_query("SELECT pv.value
        FROM {profile_values} AS pv
        LEFT JOIN {profile_fields} AS pf ON (pv.fid = pf.fid)
        WHERE pv.uid = %d AND pf.name = '%s'", array($object->uid, 'profile_display_name')));
    if (!empty($result)) {
      $name = $result;
    }
    else {
    	// Else we check for an email and remove the domain.
      $name = $object->name;
      $name_parts = explode('@', $name);
      if (count($name_parts) > 1) {
      	$name = $name_parts[0];
      }
    }

    // Shorten the name when it is too long or it will break many tables.
    if (drupal_strlen($name) > 20) {
      $name = drupal_substr($name, 0, 15) .'...';
    }
    // END OVERRIDE

    if (user_access('access user profiles')) {
      $output = l($name, 'user/'. $object->uid, array('attributes' => array('title' => t('View user profile.'))));
    }
    else {
      $output = check_plain($name);
    }
  }
  else if ($object->name) {
    // Sometimes modules display content composed by people who are
    // not registered members of the site (e.g. mailing list or news
    // aggregator modules). This clause enables modules to display
    // the true author of the content.
    if (!empty($object->homepage)) {
      $output = l($object->name, $object->homepage, array('attributes' => array('rel' => 'nofollow')));
    }
    else {
      $output = check_plain($object->name);
    }

    $output .= ' ('. t('not verified') .')';
  }
  else {
    $output = check_plain(variable_get('anonymous', t('Anonymous')));
  }

  return $output;
}

function openshift_preprocess_user_profile(&$vars) {

  global $user;
  $sid = db_result(db_query("SELECT n.sid FROM {notifications} as n
    LEFT JOIN {notifications_fields} AS nf ON (n.sid = nf.sid)
    WHERE n.type = 'author' AND n.uid = %d AND nf.value = %d", array($user->uid, $vars['account']->uid)));
  $vars['sid'] = $sid;
}

function strip_email($username) {
  $pieces = explode("@", $username);
  return $pieces[0];
}

function readabledate($enterdate) {
  $newdate = date("l, F j, Y", $enterdate);
  return $newdate;
}

function uservoice_token(){

  global $user;

  $uservoice_subdomain = "openshift";
  $sso_key = "2b258840625f4ed17e2554a97ad0daf3";

  $salted = $sso_key . $uservoice_subdomain;
  $hash = hash('sha1',$salted,true);
  $saltedHash = substr($hash,0,16);
  $iv = "OpenSSL for Ruby";
 
  $user_data = array('guid'  => $user->uid,
                     'email' => $user->mail,
                     'display_name' => $user->name);
  $data = json_encode($user_data);

  // double XOR first block
  for ($i = 0; $i < 16; $i++)
  {
   $data[$i] = $data[$i] ^ $iv[$i];
  }

  $pad = 16 - (strlen($data) % 16);
  $data = $data . str_repeat(chr($pad), $pad);
    
  $cipher = mcrypt_module_open(MCRYPT_RIJNDAEL_128,'','cbc','');
  mcrypt_generic_init($cipher, $saltedHash, $iv);
  $encryptedData = mcrypt_generic($cipher,$data);
  mcrypt_generic_deinit($cipher);

  $encryptedData = urlencode(base64_encode($encryptedData));
  return $encryptedData;
}

function openshift_date_all_day_label() {
    return '';
}

function openshift_starts_with($s, $substr)
{
    $length = strlen($substr);
    return (substr($s, 0, $length) === $substr);
}

function openshift_ends_with($s, $substr)
{
    $length = strlen($substr);
    $start  = -1 * $length;
    return (substr($s, $start) === $substr);
}
