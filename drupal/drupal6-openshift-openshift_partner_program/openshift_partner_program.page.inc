<?php

/**
 * @file
 * Page callback functions, validators and submit functions.
 */

/**
 * Callback function for the partner apply page.
 */
function _openshift_partner_program_apply() {
  drupal_set_title(t('Openshift Partner Program'));
  $form['subtitle'] = array(
    '#value' => '<h3>' . t('APPLY TO BE A PARTNER') . '</h3>',
  );
  $form['instructions'] = array(
    '#value' => '<p>' . t('Welcome!  We are glad to see you are interested in the OpenShift by Red Hat Partner Program. <br/>Joining the Partner Program takes just a few easy steps and you can begin by clicking Apply Now.') . '</p>',
  );
  $form['submit'] = array(
    '#type' => 'submit',
    '#value' => t('Apply Now'),
  );
  return $form;
}

/**
 * Submit function for the partner apply page.
 *
 * @param mixed $form
 *   The form.
 *
 * @param mixed $form_state
 *   The form state.
 */
function _openshift_partner_program_apply_submit($form, &$form_state) {
  global $user;
  drupal_set_message(t('We have received your application and you will receive an email shortly with details on the next steps in the application process.  Instructions how to build a QuickStart or cartridge and how to submit to become an OpenShift by Red Hat partner will be provided in your email.'));
  drupal_set_message(t('Already have your QuickStart or cartridge complete?  Submit it now !here.', array('!here' => l(t('here'), 'partner/apply/info'))));
  drupal_set_message(t('Learn more about OpenShift at !here.', array('!here' => l(t('www.openshift.com'), 'http://www.openshift.com'))));

  $params = array();
  $params['customer'] = $user->name;
  drupal_mail('openshift_partner_program', 'openshift_partner_program_apply_user', $user->mail, 0, $params);
  drupal_mail('openshift_partner_program', 'openshift_partner_program_apply_staff', 'openshift-partners@redhat.com', 0, $params);

  drupal_goto('user');
}

/**
 * Callback function for the partner apply info page.
 */
function _openshift_partner_program_apply_info() {
  drupal_set_title(t('Openshift Partner Program'));
  $form['#attributes'] = array('enctype' => "multipart/form-data");
  $form['subtitle'] = array(
    '#value' => '<h2>' . t('Submit Integration') . '</h2>',
  );
  $form['instructions'] = array(
    '#value' => '<h3>' . t('Welcome back!  Your application to become an OpenShift by Red Hat Partner is almost complete.  Please complete the following fields and submit your QuickStart or Cartridge here for approval.  Upon approval you will receive your Partner notification and access to the self-service partner portal where you can upload your logo.  Should we hae any questions we will use your contact information below to reach out to you.') . '</h3>',
  );
  $form['name']['first'] = array(
    '#type' => 'textfield',
    '#title' => t('First Name'),
    '#required' => TRUE,
  );
  $form['name']['last'] = array(
    '#type' => 'textfield',
    '#title' => t('Last Name'),
    '#required' => TRUE,
  );
  $form['name']['company'] = array(
    '#type' => 'textfield',
    '#title' => t('Company'),
    '#required' => TRUE,
  );
  $form['contact']['phone'] = array(
    '#type' => 'textfield',
    '#title' => t('Phone'),
    '#required' => TRUE,
  );
  $form['description'] = array(
    '#type' => 'textarea',
    '#title' => t('Insert details here'),
    '#required' => FALSE,
  );
  $form['file'] = array(
    '#type' => 'file',
    '#title' => t('Upload Documentation'),
  );
  $form['questions']['preamble'] = array(
    '#value' => t('Please complete the following questions in preparation for the partner agreement') . '<br/>' .
    t("With respect to any officer, director, agent or holder of five (5) percent or more of your firm's ownership interest:") . '<br/>',
  );
  $form['questions']['government'] = array(
    '#type' => 'radios',
    '#title' => t('Do they act in any government position or capacity (including political parties and international organizations)?'),
    '#options' => array(
      'yes' => t('Yes'),
      'no' => t('No'),
    ),
  );
  $form['questions']['crime'] = array(
    '#type' => 'radios',
    '#title' => t('Have they or your firm (including any affiliates) been charged with, investigated for, or convicted of an economic or other serious crime, including for alleged bribery or other corrupt activities within the past five (5) years?'),
    '#options' => array(
      'yes' => t('Yes'),
      'no' => t('No'),
    ),
  );
  $form['questions']['detailpreamble'] = array(
    '#value' => '</p>' . t('If you answered "Yes" to questions (i) or (ii) above, please describe the underlying facts and circumstances in reasonable detail below:') . '</p>',
  );
  $form['questions']['details'] = array(
    '#type' => 'textarea',
    '#title' => t('Insert details here'),
    '#required' => FALSE,
  );
  $form['countries'] = array(
    '#type' => 'select',
    '#multiple' => TRUE,
    '#options' => _openshift_partner_program_get_countries(),
    '#title' => t('Please select all countries of operation'),
    '#size' => 25,
  );
  $form['submit'] = array(
    '#type' => 'submit',
    '#value' => t('Submit'),
  );
  return $form;
}

/**
 * Submit function for the partner apply info page.
 *
 * @param mixed $form
 *   The form.
 *
 * @param mixed $form_state
 *   The form state.
 */
function _openshift_partner_program_apply_info_submit($form, &$form_state) {
  global $user;
  $filename = '';
  if (count($_FILES)) {
    $file = file_save_upload('file', array(), file_directory_path() . '/partner/cartridges', FILE_EXISTS_RENAME);
    $filename = $file->destination;
  }
  $params['first'] = $form_state['values']['first'];
  $params['last'] = $form_state['values']['last'];
  $params['company'] = $form_state['values']['company'];
  $params['phone'] = $form_state['values']['phone'];
  $params['description'] = $form_state['values']['description'];
  $params['file'] = $filename;
  $params['government'] = $form_state['values']['government'];
  $params['crime'] = $form_state['values']['crime'];
  $params['details'] = $form_state['values']['details'];

  $countries = $form_state['values']['countries'];
  $bad_countries = array();
  foreach ($countries as $key => $country) {
    if (!is_numeric($key)) {
      $bad_countries[$key] = $country;
    }
  }

  $params['countries'] = implode(',', $bad_countries);
  $params['customer_name'] = $user->name;
  $params['admin'] = l(t('Admin'), 'partner/admin/edit/user/' . $user->uid);
  drupal_mail('openshift_partner_program', 'openshift_partner_program_new_partner', 'openshift-partners@redhat.com', 0, $params);
  drupal_mail('openshift_partner_program', 'openshift_partner_program_apply_info', 'openshift-partners@redhat.com', 0, $params);

  drupal_set_message(t('Thank you for submitting your Quickstart or Cartridge.  We will respond with your OpenShift by Red Hat Partner login or with questions within two business days.'));
  drupal_set_message(t('Check out our upcoming events and webinars at !here'), array('!here' => l(t('www.openshift.com'), 'http://www.openshift.com')));
  drupal_goto('user');

}

/**
 * Callback function for the partner agreement page.
 */
function _openshift_partner_program_tc() {
  drupal_set_title(t('Openshift Partner Program'));
  $openshift_partner_program_agreement = '';
  require 'includes/openshift_partner_program_agreement.inc';
  drupal_add_css(drupal_get_path('module', 'openshift_partner_program') . '/css/openshift_partner_program.css', 'module', 'all', FALSE);
  $form['tc'] = array(
    '#prefix' => '<p>' . t('Please sign the partner agreement to complete your application to the Openshift by Red Hat Partner Program.') . '</p>',
    '#type' => 'textarea',
    '#disabled' => TRUE,
    '#rows' => 20,
    '#default_value' => $openshift_partner_program_agreement,
  );
  $form['control']['print'] = array(
    '#value' => l(t('Print PDF'), drupal_get_path('module', 'openshift_partner_program') . '/includes/RHOpenShift_Certified_Program_20130531_click-through.pdf', array('attributes' => array('target' => 'tc'))),
  );
  $form['control']['ack'] = array(
    '#type' => 'checkbox',
    '#title' => t('Check box to agree to Partner Agreement.'),
    '#required' => TRUE,
  );
  $form['questions'] = array(
    '#value' => '<p>' . t('Questions? Email ') . l(t('openshift-partners@redhat.com'), 'mailto:openshift-partners@redhat.com') . '</p>',
  );
  $form['submit'] = array(
    '#type' => 'submit',
    '#value' => t('Submit'),
  );
  return $form;
}

/**
 * Validation function for partner agreement page.
 *
 * @param mixed $form
 *   The form.
 *
 * @param mixed $form_state
 *   The form state.
 */
function _openshift_partner_program_tc_validate($form, &$form_state) {
  if (!$form_state['values']['ack']) {
    form_set_error('ack', t('You must accept the partner agreement to continue.'));
  }
}

/**
 * Submit function for partner agreement page.
 *
 * @param mixed $form
 *   The form.
 *
 * @param mixed $form_state
 *   The form state.
 */
function _openshift_partner_program_tc_submit($form, &$form_state) {
  global $user;
  $edit['profile_user_state'] = 'Active partner';
  $edit['profile_partner_level'] = 'Ready Partner';
  profile_save_profile($edit, $user, 'Partner Program');
  $params['customer_name'] = $user->profile_first_name . ' ' . $user->profile_last_name;
  if ($params['customer_name'] == ' ') {
    $params['customer_name'] = $user->profile_display_name;
  }
  if ($params['customer_name'] == ' ' || !$params['customer_name']) {
    $params['customer_name'] = $user->name;
  }
  watchdog('openshift_partner_program', '@user has accepted the partner agreement', array('@user' => $user->name), WATCHDOG_NOTICE);
  drupal_mail('openshift_partner_program', 'openshift_partner_program_tc', 'openshift-partners@redhat.com', 0, $params);
  drupal_goto('partner/portal');
}

/**
 * Callback function for Self Service Portal.
 *
 * @param string $content
 *   Content to prepend to result.
 *
 * @return mixed
 *   The content to display.
 */
function _openshift_partner_program_portal($content = NULL) {
  global $user;
  profile_load_profile($user);
  drupal_add_css(drupal_get_path('module', 'openshift_partner_program') . '/css/openshift_partner_program.css', 'module', 'all', FALSE);
  drupal_set_title(t('Openshift Partner Program Portal'));
  $partner_level = $user->profile_partner_level;
  $result = theme('openshift_partner_program_portal', array('partner_level' => $partner_level));
  return $result;
}

/**
 * Validate function for partner program upgrade request.
 */
function _openshift_partner_program_portal_upgrade() {
  drupal_set_title(t('Openshift Partner Program'));
  $form['#attributes'] = array('enctype' => "multipart/form-data");
  $form['subtitle'] = array(
    '#value' => '<h2>' . t('UPGRADE PARTNER LEVEL') . '</h2>',
  );
  $form['documentation_paste'] = array(
    '#type' => 'textarea',
    '#title' => t('Tell us why you want to become an OpenShift by Red Hat Advance Partner.'),
    '#description' => t('After submitting your information, the OpenShift Partner team will evaluate your request.'),
  );
  $form['submit'] = array(
    '#type' => 'submit',
    '#value' => t('Submit'),
  );
  return $form;
}

/**
 * Submit function for partner program upgrade request.
 *
 * @param mixed $form
 *   The form.
 *
 * @param mixed $form_state
 *   The form state.
 */
function _openshift_partner_program_portal_upgrade_submit($form, &$form_state) {
  global $user;
  global $base_url;
  $paste = '';
  if ($form_state['values']['documentation_paste']) {
    $paste = $form_state['values']['documentation_paste'];
  }
  $params['name'] = $user->name;
  $params['documentation'] = $paste;
  drupal_mail('openshift_partner_program', 'openshift_partner_program_partner_upgrade', 'openshift-partners@redhat.com', 0, $params);
  drupal_set_message(t('Partner level upgrade request submitted.'));
  drupal_goto('partner/portal');
}

/**
 * Callback function for partner program customer story request.
 */
function _openshift_partner_program_portal_customer_story() {
  global $user;
  profile_load_profile($user);
  drupal_set_title(t('Openshift Partner Program'));
  $form['#attributes'] = array('enctype' => "multipart/form-data");
  $form['subtitle'] = array(
    '#value' => '<h2>' . t('SUBMIT CUSTOMER SUCCESS STORY') . '</h2>',
  );
  $form['instructions'] = array(
    '#value' => '<h3>' . t('Have a great success story?  Let us help you develop and share it!') . '</h3>',
  );
  $form['customer']['customer_name'] = array(
    '#type' => 'textfield',
    '#title' => t('Customer'),
    '#required' => TRUE,
  );
  $form['customer']['customer_contact_name'] = array(
    '#type' => 'textfield',
    '#title' => t('Customer Contact Name'),
    '#required' => FALSE,
  );
  $form['self']['name'] = array(
    '#type' => 'textfield',
    '#title' => t('Your Name'),
    '#required' => TRUE,
    '#default_value' => $user->profile_display_name,
  );
  $form['self']['phone'] = array(
    '#type' => 'textfield',
    '#title' => t('Your Preferred Contact Number'),
    '#required' => FALSE,
  );
  $form['self']['email'] = array(
    '#type' => 'textfield',
    '#title' => t('Your Email'),
    '#required' => TRUE,
    '#default_value' => $user->mail,
  );
  $form['questions']['agree'] = array(
    '#type' => 'radios',
    '#title' => t('Has customer agreed to participate in a public success story?'),
    '#options' => array(
      'yes' => t('Yes'),
      'no' => t('No'),
    ),
  );
  $form['questions']['approach'] = array(
    '#type' => 'radios',
    '#title' => t('If no, have you approached the customer to participate in a public success story?'),
    '#options' => array(
      'yes' => t('Yes'),
      'no' => t('No'),
    ),
  );
  $form['description'] = array(
    '#type' => 'textarea',
    '#title' => t('Insert brief description of success story'),
  );
  $form['submit'] = array(
    '#type' => 'submit',
    '#value' => t('Submit'),
  );
  return $form;
}

/**
 * Submit function for partner program customer story request.
 *
 * @param mixed $form
 *   The form.
 *
 * @param mixed $form_state
 *   The form state.
 */
function _openshift_partner_program_portal_customer_story_submit($form, &$form_state) {
  $params['customer'] = $form_state['values']['customer_name'];
  $params['customer_contact_name'] = $form_state['values']['customer_contact_name'];
  $params['name'] = $form_state['values']['name'];
  $params['phone'] = $form_state['values']['phone'];
  $params['email'] = $form_state['values']['email'];
  $params['customer_agree'] = $form_state['values']['agree'];
  $params['customer_approached'] = $form_state['values']['approach'];
  $params['story_description'] = $form_state['values']['description'];
  drupal_mail('openshift_partner_program', 'openshift_partner_program_customer_story', 'openshift-partners@redhat.com', 0, $params);
  drupal_set_message(t('Customer Story request submitted.'));
  drupal_goto('partner/portal');
}

/**
 * Callback function for partner program assistance request.
 */
function _openshift_partner_program_portal_request_assistance() {
  global $user;
  profile_load_profile($user);
  drupal_set_title(t('Openshift Partner Program'));
  $form['#attributes'] = array('enctype' => "multipart/form-data");
  $form['subtitle'] = array(
    '#value' => '<h2>' . t('REQUEST ASSISTANCE') . '</h2>',
  );
  $form['instructions'] = array(
    '#value' => '<h3>' . t('Have a question?  Want to request marketing assistance?  Please complete the form below and we will reach out to you to get more information.') . '</h3>',
  );
  $form['name']['first'] = array(
    '#type' => 'textfield',
    '#title' => t('First Name'),
    '#default_value' => $user->profile_first_name,
    '#required' => TRUE,
  );
  $form['name']['last'] = array(
    '#type' => 'textfield',
    '#title' => t('Last Name'),
    '#default_value' => $user->profile_last_name,
    '#required' => TRUE,
  );
  $form['name']['company'] = array(
    '#type' => 'textfield',
    '#title' => t('Company'),
    '#default_value' => $user->profile_company,
    '#required' => TRUE,
  );
  $form['contact']['phone'] = array(
    '#type' => 'textfield',
    '#title' => t('Preferred Contact Number'),
    '#required' => FALSE,
  );
  $form['contact']['email'] = array(
    '#type' => 'textfield',
    '#title' => t('Email Address'),
    '#default_value' => $user->mail,
    '#required' => TRUE,
  );
  $form['questions']['related'] = array(
    '#type' => 'checkboxes',
    '#title' => t('Is your request related to'),
    '#options' => array(
      'general' => t('General Question'),
      'marketing' => t('Marketing'),
      'technical' => t('Technical'),
    ),
  );
  $form['description'] = array(
    '#type' => 'textarea',
    '#title' => t('Insert brief description of request'),
    '#required' => TRUE,
  );
  $form['submit'] = array(
    '#type' => 'submit',
    '#value' => t('Submit'),
  );
  return $form;
}

/**
 * Submit function for partner program assistance request.
 *
 * @param mixed $form
 *   The form.
 *
 * @param mixed $form_state
 *   The form state.
 */
function _openshift_partner_program_portal_request_assistance_submit($form, &$form_state) {
  $params['first_name'] = $form_state['values']['first'];
  $params['last_name'] = $form_state['values']['last'];
  $params['company_name'] = $form_state['values']['company'];
  $params['phone'] = $form_state['values']['phone'];
  $params['email'] = $form_state['values']['email'];
  $params['request_related_to'] = '';
  $related = $form_state['values']['related'];
  foreach ($related as $category) {
    if ($category) {
      $params['request_related_to'] .= "$category ";
    }
  }
  $params['description'] = $form_state['values']['description'];
  drupal_mail('openshift_partner_program', 'openshift_partner_program_request_assistance', 'openshift-partners@redhat.com', 0, $params);
  drupal_set_message(t('Request for assistance submitted.'));
  drupal_goto('partner/portal');
}

/**
 * Callback function for partner program company info upload.
 */
function _openshift_partner_program_portal_company_info() {
  global $user;
  $info = openshift_partner_program_partner_info();
  $company = ($info) ? $info['company'] : '';
  $company_description = ($info) ? $info['company_description'] : '';

  drupal_set_title(t('Openshift Partner Program'));
  $form['#attributes'] = array('enctype' => "multipart/form-data");
  $form['subtitle'] = array(
    '#value' => '<h2>' . t('UPLOAD COMPANY INFO') . '</h2>',
  );
  $form['instructions'] = array(
    '#value' => '<h3>' . t('Please provide the following information for your listing on the OpenShift Partner pages on openshift.com')  . '</h3>',
  );
  $form['company_name'] = array(
    '#type' => 'textfield',
    '#title' => t('Company Name'),
    '#default_value' => $company,
    '#required' => TRUE,
  );
  $form['company_description'] = array(
    '#type' => 'textarea',
    '#title' => t('Company Description'),
    '#default_value' => $company_description,
    '#required' => TRUE,
  );
  $form['logo'] = array(
    '#type' => 'file',
    '#title' => t('Upload logo'),
    '#access' => !node_load(array('uid' => $user->uid, 'type' => 'partner')),
  );
  $form['expertise_tags'] = array(
    '#type' => 'select',
    '#multiple' => TRUE,
    '#options' => _openshift_partner_program_get_expertise_tags(),
    '#title' => t('Expertise Tags'),
    '#default_value' => _openshift_partner_program_get_selected_expertise_tags(),
  );
  $form['submit'] = array(
    '#type' => 'submit',
    '#value' => t('Submit'),
  );
  return $form;
}

/**
 * Submit function for partner program company upload info page.
 *
 * @param mixed $form
 *   The form.
 *
 * @param mixed $form_state
 *   The form state.
 */
function _openshift_partner_program_portal_company_info_submit($form, &$form_state) {
  global $user;
  $uid = $user->uid;
  $logo = '';
  if (count($_FILES)) {
    $file = file_save_upload('logo', array(), file_directory_path() . '/partner/logos', FILE_EXISTS_RENAME);
    $logo = $file->destination;
  }
  $company = $form_state['values']['company_name'];
  $company_description = $form_state['values']['company_description'];

  $expertise_tags = $form_state['values']['expertise_tags'];
  $expertise_tags = implode(',', $expertise_tags);

  $result = openshift_partner_program_partner_info_upsert_node($uid, $company, $company_description, $logo, $expertise_tags);

  if ($result && $logo) {
    drupal_set_message(t('Company info has been saved.'));
  }
  elseif ($result) {
    drupal_set_message(t('Failed to save company logo.'), 'error');
  }
  else {
    drupal_set_message(t('Failed to save company info.'), 'error');
  }

  drupal_goto('partner/portal');
}

/**
 * Returns the possible countries of operation.
 *
 * @return mixed
 *   The countries of operation.
 */
function _openshift_partner_program_get_countries() {
  $result['Afghanistan'] = '';
  $result['Albania'] = '';
  $result['Algeria'] = '';
  $result['Angola'] = '';
  $result['Argentina'] = '';
  $result['Armenia'] = '';
  $result['Azerbaijan'] = '';
  $result['Bangladesh'] = '';
  $result['Belarus'] = '';
  $result['Benin'] = '';
  $result['Bolivia'] = '';
  $result['Bosnia and Herzegovina'] = '';
  $result['Brazil'] = '';
  $result['Bulgaria'] = '';
  $result['Burkina Faso'] = '';
  $result['Burundi'] = '';
  $result['Cambodia'] = '';
  $result['Cameroon'] = '';
  $result['Central African Republic'] = '';
  $result['Chad'] = '';
  $result['China'] = '';
  $result['Colombia'] = '';
  $result['Comoros'] = '';
  $result['Congo Republic'] = '';
  $result["Cote d'Ivoire"] = '';
  $result['Croatia'] = '';
  $result['Democratic Republic of the Congo'] = '';
  $result['Djibouti'] = '';
  $result['Dominican Republic'] = '';
  $result['Ecuador'] = '';
  $result['Egypt'] = '';
  $result['El Salvador'] = '';
  $result['Equatorial Guinea'] = '';
  $result['Eritrea'] = '';
  $result['Ethiopia'] = '';
  $result['Gabon'] = '';
  $result['Gambia'] = '';
  $result['Ghana'] = '';
  $result['Greece'] = '';
  $result['Guatemala'] = '';
  $result['Guinea'] = '';
  $result['Guinea-Bissau'] = '';
  $result['Guyana'] = '';
  $result['Haiti'] = '';
  $result['Honduras'] = '';
  $result['India'] = '';
  $result['Indonesia'] = '';
  $result['Iran'] = '';
  $result['Iraq'] = '';
  $result['Italy'] = '';
  $result['Jamaica'] = '';
  $result['Kazakhstan'] = '';
  $result['Kenya'] = '';
  $result['Korea (North)'] = '';
  $result['Kosovo'] = '';
  $result['Kuwait'] = '';
  $result['Kyrgyzstan'] = '';
  $result['Laos'] = '';
  $result['Lebanon'] = '';
  $result['Lesotho'] = '';
  $result['Liberia'] = '';
  $result['Libya'] = '';
  $result['Macedonia'] = '';
  $result['Madagascar'] = '';
  $result['Malawi'] = '';
  $result['Mali'] = '';
  $result['Mauritania'] = '';
  $result['Mexico'] = '';
  $result['Moldova'] = '';
  $result['Mongolia'] = '';
  $result['Montenegro'] = '';
  $result['Morocco'] = '';
  $result['Mozambique'] = '';
  $result['Myanmar'] = '';
  $result['Nepal'] = '';
  $result['Nicaragua'] = '';
  $result['Niger'] = '';
  $result['Nigeria'] = '';
  $result['Oman'] = '';
  $result['Pakistan'] = '';
  $result['Panama'] = '';
  $result['Papua New Guinea'] = '';
  $result['Paraguay'] = '';
  $result['Peru'] = '';
  $result['Philippines'] = '';
  $result['Romania'] = '';
  $result['Russia'] = '';
  $result['Sao Tome and Principe'] = '';
  $result['Saudi Arabia'] = '';
  $result['Senegal'] = '';
  $result['Serbia'] = '';
  $result['Sierra Leone'] = '';
  $result['Slovakia'] = '';
  $result['Somalia'] = '';
  $result['South Africa'] = '';
  $result['Sri Lanka'] = '';
  $result['Sudan'] = '';
  $result['Suriname'] = '';
  $result['Swaziland'] = '';
  $result['Syria'] = '';
  $result['Tajikistan'] = '';
  $result['Tanzania'] = '';
  $result['Thailand'] = '';
  $result['Timor-Leste'] = '';
  $result['Togo'] = '';
  $result['Trinidad and Tobago'] = '';
  $result['Tunisia'] = '';
  $result['Turkmenistan'] = '';
  $result['Uganda'] = '';
  $result['Ukraine'] = '';
  $result['Uzbekistan'] = '';
  $result['Venezuela'] = '';
  $result['Vietnam'] = '';
  $result['Yemen'] = '';
  $result['Zambia'] = '';
  $result['Zimbabwe'] = '';

  $countries = array();
  foreach ($result as $key => $value) {
    $countries[$key] = t($key);
  }

  $safe_countries['United States'] = '';
  $safe_countries['Canada'] = '';
  $safe_countries['Afghanistan'] = '';
  $safe_countries['Aland Islands'] = '';
  $safe_countries['Albania'] = '';
  $safe_countries['Algeria'] = '';
  $safe_countries['American Samoa'] = '';
  $safe_countries['Andorra'] = '';
  $safe_countries['Angola'] = '';
  $safe_countries['Anguilla'] = '';
  $safe_countries['Antarctica'] = '';
  $safe_countries['Antigua/Barbuda'] = '';
  $safe_countries['Argentina'] = '';
  $safe_countries['Armenia'] = '';
  $safe_countries['Aruba'] = '';
  $safe_countries['Austria'] = '';
  $safe_countries['Australia'] = '';
  $safe_countries['Azerbaijan'] = '';
  $safe_countries['Bahamas'] = '';
  $safe_countries['Bahrain'] = '';
  $safe_countries['Bangladesh'] = '';
  $safe_countries['Barbados'] = '';
  $safe_countries['Belarus'] = '';
  $safe_countries['Belgium'] = '';
  $safe_countries['Belize'] = '';
  $safe_countries['Benin'] = '';
  $safe_countries['Bermuda'] = '';
  $safe_countries['Bhutan'] = '';
  $safe_countries['Bolivia'] = '';
  $safe_countries['Bosnia/Herzegovina'] = '';
  $safe_countries['Botswana'] = '';
  $safe_countries['Bouvet Island'] = '';
  $safe_countries['Brazil'] = '';
  $safe_countries['Brunei Darussalam'] = '';
  $safe_countries['Bulgaria'] = '';
  $safe_countries['Burkina Faso'] = '';
  $safe_countries['Burundi'] = '';
  $safe_countries['Cambodia'] = '';
  $safe_countries['Cameroon'] = '';
  $safe_countries['Cape Verde'] = '';
  $safe_countries['Cayman Islands'] = '';
  $safe_countries['Central African Republic'] = '';
  $safe_countries['Chad'] = '';
  $safe_countries['Chile'] = '';
  $safe_countries['China'] = '';
  $safe_countries['Christmas Island'] = '';
  $safe_countries['Cocos (Keeling) Islands'] = '';
  $safe_countries['Colombia'] = '';
  $safe_countries['Comoros'] = '';
  $safe_countries['Cook Islands'] = '';
  $safe_countries['Costa Rica'] = '';
  $safe_countries['Cote d\'Ivoire'] = '';
  $safe_countries['Croatia'] = '';
  $safe_countries['Cuba'] = '';
  $safe_countries['Cyprus'] = '';
  $safe_countries['Czech Republic'] = '';
  $safe_countries['Denmark'] = '';
  $safe_countries['Djibouti'] = '';
  $safe_countries['Dominica'] = '';
  $safe_countries['Dominican Republic'] = '';
  $safe_countries['Ecuador'] = '';
  $safe_countries['Egypt'] = '';
  $safe_countries['El Salvador'] = '';
  $safe_countries['Equatorial Guinea'] = '';
  $safe_countries['Eritrea'] = '';
  $safe_countries['Estonia'] = '';
  $safe_countries['Ethiopia'] = '';
  $safe_countries['Falkland Islands(Malvinas)'] = '';
  $safe_countries['Faroe Islands'] = '';
  $safe_countries['Fiji'] = '';
  $safe_countries['Finland'] = '';
  $safe_countries['France'] = '';
  $safe_countries['French Guiana'] = '';
  $safe_countries['French Polynesia'] = '';
  $safe_countries['French Southern Territories'] = '';
  $safe_countries['Gabon'] = '';
  $safe_countries['Gambia'] = '';
  $safe_countries['Georgia'] = '';
  $safe_countries['Germany'] = '';
  $safe_countries['Ghana'] = '';
  $safe_countries['Gibraltar'] = '';
  $safe_countries['Greece'] = '';
  $safe_countries['Greenland'] = '';
  $safe_countries['Grenada'] = '';
  $safe_countries['Guadeloupe'] = '';
  $safe_countries['Guam'] = '';
  $safe_countries['Guatemala'] = '';
  $safe_countries['Guernsey'] = '';
  $safe_countries['Guinea'] = '';
  $safe_countries['Guinea-Bissau'] = '';
  $safe_countries['Guyana'] = '';
  $safe_countries['Haiti'] = '';
  $safe_countries['Heard Island/Mcdonald Islands'] = '';
  $safe_countries['Honduras'] = '';
  $safe_countries['Hong Kong'] = '';
  $safe_countries['Hungary'] = '';
  $safe_countries['Iceland'] = '';
  $safe_countries['India'] = '';
  $safe_countries['Indonesia'] = '';
  $safe_countries['Iran'] = '';
  $safe_countries['Iraq'] = '';
  $safe_countries['Ireland'] = '';
  $safe_countries['Isle Of Man'] = '';
  $safe_countries['Israel'] = '';
  $safe_countries['Italy'] = '';
  $safe_countries['Jamaica'] = '';
  $safe_countries['Japan'] = '';
  $safe_countries['Jersey'] = '';
  $safe_countries['Jordan'] = '';
  $safe_countries['Kazakhstan'] = '';
  $safe_countries['Kenya'] = '';
  $safe_countries['Kiribati'] = '';
  $safe_countries['Kuwait'] = '';
  $safe_countries['Kyrgyzstan'] = '';
  $safe_countries['Lao'] = '';
  $safe_countries['Latvia'] = '';
  $safe_countries['Lebanon'] = '';
  $safe_countries['Lesotho'] = '';
  $safe_countries['Liberia'] = '';
  $safe_countries['Libyan Arab Jamahiriya'] = '';
  $safe_countries['Liechtenstein'] = '';
  $safe_countries['Lithuania'] = '';
  $safe_countries['Luxembourg'] = '';
  $safe_countries['Macao'] = '';
  $safe_countries['Macedonia'] = '';
  $safe_countries['Madagascar'] = '';
  $safe_countries['Malawi'] = '';
  $safe_countries['Malaysia'] = '';
  $safe_countries['Maldives'] = '';
  $safe_countries['Mali'] = '';
  $safe_countries['Malta'] = '';
  $safe_countries['Marshall Islands'] = '';
  $safe_countries['Martinique'] = '';
  $safe_countries['Mauritania'] = '';
  $safe_countries['Mauritius'] = '';
  $safe_countries['Mayotte'] = '';
  $safe_countries['Mexico'] = '';
  $safe_countries['Micronesia'] = '';
  $safe_countries['Moldova'] = '';
  $safe_countries['Monaco'] = '';
  $safe_countries['Mongolia'] = '';
  $safe_countries['Montenegro'] = '';
  $safe_countries['Montserrat'] = '';
  $safe_countries['Morocco'] = '';
  $safe_countries['Mozambique'] = '';
  $safe_countries['Myanmar'] = '';
  $safe_countries['Namibia'] = '';
  $safe_countries['Nauru'] = '';
  $safe_countries['Nepal'] = '';
  $safe_countries['Netherlands'] = '';
  $safe_countries['Netherlands Antilles'] = '';
  $safe_countries['New Caledonia'] = '';
  $safe_countries['New Zealand'] = '';
  $safe_countries['Nicaragua'] = '';
  $safe_countries['Niger'] = '';
  $safe_countries['Nigeria'] = '';
  $safe_countries['Niue'] = '';
  $safe_countries['Norfolk Island'] = '';
  $safe_countries['North Korea'] = '';
  $safe_countries['Northern Mariana Islands'] = '';
  $safe_countries['Norway'] = '';
  $safe_countries['Oman'] = '';
  $safe_countries['Pakistan'] = '';
  $safe_countries['Palau'] = '';
  $safe_countries['Palestine'] = '';
  $safe_countries['Panama'] = '';
  $safe_countries['Papua New Guinea'] = '';
  $safe_countries['Paraguay'] = '';
  $safe_countries['Peru'] = '';
  $safe_countries['Philippines'] = '';
  $safe_countries['Pitcairn'] = '';
  $safe_countries['Poland'] = '';
  $safe_countries['Portugal'] = '';
  $safe_countries['Puerto Rico'] = '';
  $safe_countries['Qatar'] = '';
  $safe_countries['Réunion'] = '';
  $safe_countries['Romania'] = '';
  $safe_countries['Russian Federation'] = '';
  $safe_countries['Rwanda'] = '';
  $safe_countries['St. Barthélemy'] = '';
  $safe_countries['St. Helena'] = '';
  $safe_countries['St. Kitts/Nevis'] = '';
  $safe_countries['St. Lucia'] = '';
  $safe_countries['St. Martin'] = '';
  $safe_countries['St. Pierre/Miquelon'] = '';
  $safe_countries['St. Vincent/The Grenadines'] = '';
  $safe_countries['Samoa'] = '';
  $safe_countries['San Marino'] = '';
  $safe_countries['Sao Tome/Principe'] = '';
  $safe_countries['Saudi Arabia'] = '';
  $safe_countries['Senegal'] = '';
  $safe_countries['Serbia'] = '';
  $safe_countries['Seychelles'] = '';
  $safe_countries['Sierra Leone'] = '';
  $safe_countries['Singapore'] = '';
  $safe_countries['Slovakia'] = '';
  $safe_countries['Slovenia'] = '';
  $safe_countries['Solomon Islands'] = '';
  $safe_countries['Somalia'] = '';
  $safe_countries['South Africa'] = '';
  $safe_countries['South Georgia/Sandwich Islands'] = '';
  $safe_countries['South Korea'] = '';
  $safe_countries['Spain'] = '';
  $safe_countries['Sri Lanka'] = '';
  $safe_countries['Sudan'] = '';
  $safe_countries['Suriname'] = '';
  $safe_countries['Svalbard/Jan Mayen'] = '';
  $safe_countries['Swaziland'] = '';
  $safe_countries['Sweden'] = '';
  $safe_countries['Switzerland'] = '';
  $safe_countries['Syrian Arab Republic'] = '';
  $safe_countries['Taiwan'] = '';
  $safe_countries['Tajikistan'] = '';
  $safe_countries['Tanzania'] = '';
  $safe_countries['Thailand'] = '';
  $safe_countries['Timor-Leste'] = '';
  $safe_countries['Togo'] = '';
  $safe_countries['Tokelau'] = '';
  $safe_countries['Tonga'] = '';
  $safe_countries['Tunisia'] = '';
  $safe_countries['Turkey'] = '';
  $safe_countries['Turkmenistan'] = '';
  $safe_countries['Turks/Caicos Islands'] = '';
  $safe_countries['Tuvalu'] = '';
  $safe_countries['Uganda'] = '';
  $safe_countries['Ukraine'] = '';
  $safe_countries['United Arab Emirates'] = '';
  $safe_countries['United Kingdom'] = '';
  $safe_countries['United States Minor Islands'] = '';
  $safe_countries['Uruguay'] = '';
  $safe_countries['Uzbekistan'] = '';
  $safe_countries['Vanuatu'] = '';
  $safe_countries['Vatican City State'] = '';
  $safe_countries['Venezuela'] = '';
  $safe_countries['Viet Nam'] = '';
  $safe_countries['Virgin Islands, British'] = '';
  $safe_countries['Virgin Islands, U.S.'] = '';
  $safe_countries['Wallis/Futuna'] = '';
  $safe_countries['Western Sahara'] = '';
  $safe_countries['Yemen'] = '';
  $safe_countries['Zambia'] = '';
  $safe_countries['Zimbabwe'] = '';

  foreach ($safe_countries as $key => $value) {
    if (!in_array($key, $countries)) {
      $countries[] = $key;
    }
  }
  asort($countries);
  return $countries;
}

/**
 * Returns the total possible expertise tags.
 *
 * @return mixed
 *   The expertise tags.
 */
function _openshift_partner_program_get_expertise_tags() {
  $vocab = reset(taxonomy_get_vocabularies('Partner'));
  $result = db_query("SELECT name FROM {term_data} where vid = %d order by name ASC", $vocab->vid);
  $tags = array();
  while ($row = db_fetch_array($result)) {
    $tags[$row['name']] = t($row['name']);
  }
  return $tags;
}

/**
 * Returns the selected expertise tags for the current user's profile.
 *
 * @return mixed
 *   The keys for the selected expertise tags.
 */
function _openshift_partner_program_get_selected_expertise_tags() {
  global $user;
  $node = node_load(array('uid' => $user->uid, 'type' => 'partner'));
  $tags = array();
  foreach ($node->taxonomy as $tag) {
    $tags[] = $tag->name;
  }
  return $tags;
}
