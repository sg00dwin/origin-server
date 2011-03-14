<?php

$data = json_decode($_POST['json_data']);
$rhlogin = escapeshellarg(filter_var($data->{'rhlogin'}, FILTER_SANITIZE_STRING));

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

$results = my_exec("/usr/bin/rhc-get-user-info -l $rhlogin", $out);

if($results['return'] != 0) {
    header('HTTP/1.1 500 Internal Server Error', 500);
}

print json_encode($results);

// print_r("\nstdout: " . $results['stdout']);
// print_r("\nstderr: " . $results['stderr']);
// print_r("\nreturn: " . $results['return']);
?>
