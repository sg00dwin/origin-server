<?php

$user_data = json_decode($_POST['json_data']);
$namespace = escapeshellarg(filter_var($user_data->{'namespace'}, FILTER_SANITIZE_SPECIAL_CHARS, FILTER_FLAG_STRIP_LOW));
$rhlogin = escapeshellarg(filter_var($user_data->{'rhlogin'}, FILTER_SANITIZE_EMAIL, FILTER_FLAG_STRIP_LOW));
$password = escapeshellarg(filter_var($user_data->{'password'}, FILTER_SANITIZE_STRING));
$ssh_key = escapeshellarg(filter_var($user_data->{'ssh'}, FILTER_SANITIZE_STRING));
$alter = escapeshellarg(filter_var($user_data->{'alter'}, FILTER_SANITIZE_STRING));

function my_exec($cmd, $input='')
         {$proc=proc_open($cmd, array(0=>array('pipe', 'r'), 1=>array('pipe', 'w'), 2=>array('pipe', 'w')), $pipes);
          fwrite($pipes[0], $input);fclose($pipes[0]);
          $stdout=stream_get_contents($pipes[1]);fclose($pipes[1]);
          $stderr=stream_get_contents($pipes[2]);fclose($pipes[2]);
          $rtn=proc_close($proc);
          return array('stdout'=>$stdout,
                       'stderr'=>$stderr,
                       'return'=>$rtn
                      );
         }
$out='';
if(strcmp($alter, "'--alter'") == 0)
    $alter = "--alter";
$results = my_exec("/usr/bin/rhc-new-user -n $namespace -l $rhlogin -p $password -s $ssh_key $alter -q | grep -v 'No request sent'", $out);

print json_encode($results);

// print_r("\n\n");
// print_r("\nstdout: " . $results['stdout']);
// print_r("\nstderr: " . $results['stderr']);
// print_r("\nreturn: " . $results['return']);
?>
