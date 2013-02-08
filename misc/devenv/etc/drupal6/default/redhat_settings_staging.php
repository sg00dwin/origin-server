<?php

/**
 * Configuration key/value pairs for external Redhat services.
 */

$streamline_host = 'https://streamline-proxy1.ops.rhcloud.com';
/**
 * If you have configured broker and site to generate cookies to
 * uncomment this line.
 */
#$cookie_domain = '.redhat.com';

$conf['redhat_sso_enabled'] = true;
$conf['redhat_sso_register_url'] = '/app/account/new';

/**
 * RedHat User Info Settings
 *
 * Examples:
 *   $conf['redhat_user_info_url'] = 'https://www.webqa.redhat.com/wapps/streamline/userInfo.html';
 *   $conf['redhat_user_info_secret_key'] = 'xxxxxxx';
 *
 * For security these settings will be kept out of the repository.
 */
$conf['redhat_login_url'] = $streamline_host . '/wapps/streamline/login.html';
$conf['redhat_user_info_url'] = $streamline_host . '/wapps/streamline/userInfo.html';
$conf['redhat_user_info_secret_key'] = 'sw33tl1Qu0r';
?>
