<?php

/**
 * @file
 * Admin callbacks for the openshift partner program module.
 */

/**
 * Callback function for the partner program user admin page.
 *
 * @param array $form_state
 *   The form state.
 * @param int $uid
 *   The user's id.
 *
 * @return mixed
 *   The form.
 */
function _openshift_partner_program_user_admin($form_state, $uid) {
  drupal_set_title('OpenShift Partner Program');
  $account = user_load(array('uid' => $uid));
  profile_load_profile($account);
  $form['uid'] = array(
    '#type' => 'hidden',
    '#value' => check_plain($uid),
  );
  $form['preamble'] = array(
    '#value' => '<h2>' . t('Edit User ') . $account->name . '</h2>',
  );
  $form['user_state'] = array(
    '#type' => 'select',
    '#title' => t('User State'),
    '#options' => array(
      'Not a partner' => t('Not a partner'),
      'More info required' => t('More info required'),
      'New partner' => t('New partner'),
      'Active partner' => t('Active partner'),
    ),
    '#default_value' => ($account->profile_user_state) ? $account->profile_user_state : 'Not a partner',
  );
  $form['partner_level'] = array(
    '#type' => 'select',
    '#title' => t('Partner Level'),
    '#options' => array(
      'Ready Partner' => t('Ready Partner'),
      'Advanced Partner' => t('Advanced Partner'),
    ),
    '#default_value' => ($account->profile_partner_level) ? $account->profile_partner_level : 'Ready Partner',
  );
  $form['submit'] = array(
    '#type' => 'submit',
    '#value' => t('Submit'),
  );
  return $form;
}

/**
 * Submit function for the partner program user admin page.
 *
 * @param mixed $form
 *   The form.
 *
 * @param mixed $form_state
 *   The form state.
 */
function _openshift_partner_program_user_admin_submit($form, &$form_state) {
  $uid = check_plain($form_state['values']['uid']);
  $account = user_load($uid);
  profile_load_profile($account);
  $account->profile_user_state = $form_state['values']['user_state'];
  $account->profile_partner_level = $form_state['values']['partner_level'];

  $edit['profile_user_state'] = $account->profile_user_state;
  $edit['profile_partner_level'] = $account->profile_partner_level;

  if (user_save($account, $edit, 'Partner Program')) {
    drupal_set_message(t('Your changes have been saved.'));
  }
  else {
    drupal_set_message(t('Error saving changes.'), 'error');
  }
  $params['customer_name'] = $account->profile_first_name . ' ' . $account->profile_last_name;
  if ($params['customer_name'] == ' ') {
    $params['customer_name'] = $account->profile_display_name;
  }
  if ($params['customer_name'] == ' ') {
    $params['customer_name'] = $account->name;
  }
  $params['partner_level'] = $account->profile_partner_level;

  if ($account->profile_user_state == 'More info required') {
    drupal_mail('openshift_partner_program', 'openshift_partner_program_more_info_required', $account->mail, 0, $params);
  }
  elseif ($account->profile_user_state == 'New partner') {
    drupal_mail('openshift_partner_program', 'openshift_partner_program_new_partner', $account->mail, 0, $params);
  }

  drupal_goto('partner/admin/user');
}

/**
 * Callback function for the partner program user admin page.
 */
function _openshift_partner_program_admin() {
  $form['openshift_partner_program_agreement_text'] = array(
    '#type' => 'textarea',
    '#rows' => '25',
    '#title' => t('Partner Agreement Text'),
    '#default_value'  => variable_get('openshift_partner_program_agreement_text', ''),
  );
  $form['openshift_partner_program_agreement_filepath'] = array(
    '#type' => 'textfield',
    '#title' => t('Partner Agreement PDF File'),
    '#default_value'  => variable_get('openshift_partner_program_agreement_filepath', ''),
  );

  return system_settings_form($form);
}
