<?php

/**
 * Configuration key/value pairs for external Redhat services.
 */

$streamline_host = 'https://10.118.51.155';
/**
 * If you have configured broker and site to generate cookies to
 * the current domain, comment out this line.
 */
$cookie_domain = '.redhat.com';

$conf['redhat_sso_enabled'] = true;
$conf['redhat_sso_force_login'] = false;
$conf['redhat_sso_login_url'] = '/app/login';
$conf['redhat_sso_logout_url'] = '/app/logout';
$conf['redhat_sso_verify_url'] = $streamline_host . '/wapps/streamline/cloudVerify.html';
$conf['redhat_sso_register_url'] = '/app/user/new';

/**
 * RedHat User Info Settings
 *
 * Examples:
 *   $conf['redhat_user_info_url'] = 'https://www.webqa.redhat.com/wapps/streamline/userInfo.html';
 *   $conf['redhat_user_info_secret_key'] = 'xxxxxxx';
 *
 * For security these settings will be kept out of the repository.
 */
$conf['redhat_user_info_url'] = $streamline_host . '/wapps/streamline/userInfo.html';
$conf['redhat_user_info_secret_key'] = 'sw33tl1Qu0r';
?>
