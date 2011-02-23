<?php

$user_data = json_decode($_POST['json_data']);
$customer_name = escapeshellarg(filter_var($user_data->{'username'}, FILTER_SANITIZE_SPECIAL_CHARS, FILTER_FLAG_STRIP_LOW));
$email = escapeshellarg(filter_var($user_data->{'email'}, FILTER_SANITIZE_EMAIL, FILTER_FLAG_STRIP_LOW));
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
if($alter)
    $alter = "--alter";
$results = my_exec("/usr/bin/rhc-new-user -u $customer_name -e $email -s $ssh_key $alter", $out);

print json_encode($results);

// print_r("\n\n");
// print_r("\nstdout: " . $results['stdout']);
// print_r("\nstderr: " . $results['stderr']);
// print_r("\nreturn: " . $results['return']);
?>
