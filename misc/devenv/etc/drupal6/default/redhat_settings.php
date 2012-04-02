<?php

/**
 * Configuration key/value pairs for external Redhat services.
 */

$conf['redhat_sso_enabled'] = TRUE;
$conf['redhat_sso_force_login'] = FALSE;
$conf['redhat_sso_login_url'] = 'https://openshiftdev.redhat.com/app/login';
$conf['redhat_sso_logout_url'] = 'https://openshiftdev.redhat.com/app/logout';
$conf['redhat_sso_verify_url'] = 'https://10.196.215.67/wapps/streamline/cloudVerify.html';
$conf['redhat_sso_register_url'] = 'https://openshiftdev.redhat.com/app/user/new';

/**
 * RedHat User Info Settings
 *
 * Examples:
 *   $conf['redhat_user_info_url'] = 'https://www.webqa.redhat.com/wapps/streamline/userInfo.html';
 *   $conf['redhat_user_info_secret_key'] = 'xxxxxxx';
 *
 * For security these settings will be kept out of the repository.
 */
$conf['redhat_user_info_url'] = 'https://10.196.215.67/wapps/streamline/userInfo.html';
$conf['redhat_user_info_secret_key'] = 'sw33tl1Qu0r';
$conf['openshift_url'] = 'https://openshiftdev.redhat.com';
?>
