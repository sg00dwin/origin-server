<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">
<?php
# define any functions needed later
date_default_timezone_set("UTC");
$defaults = array('children' => 10, 'sleep' => 4);

if (array_key_exists('children', $_GET)) {
  $children = $_GET['children'];
} else {
  $children = $defaults['children'];
}

if (array_key_exists('sleep', $_GET)) {
  $sleeptime = $_GET['sleep'];
} else {
  $sleeptime = $defaults['sleep'];
}

function formatdate() {
  return date("Ymd-H:i:sT");
}

?>
<html>
  <head>
    <title>Fork Test</title>
  </head>
  <body>
    <h1 style="text-align: center;">PHP Fork Test</h1>
    <p><?php
      print "\n";
      print formatdate() . " Begin script<br/>\n" ;
      if (function_exists("pcntl_for")) {
	print "creating " . $children . " children<br/>\n";
	print "each child will sleep " . $sleeptime . " seconds<br/>\n";
	$c = 0;
	$pidlist = array();
	while ($c < $children) {
	  $pid = pcntl_fork();
	  if ($pid == -1) {
	    die("Could not fork");
	  } else if ($pid) {
	    print formatdate() . " forked process #$c: pid = $pid<br/>\n";
	    $c++;
	    $pidlist[] = $pid;
	  } else {
	    print formatdate() . " Starting Child #$c<br/>\n";
	    sleep($sleeptime);
	    exit;
	  }
	}
	
	while (sizeof($pidlist) > 0) {
	  print formatdate() . " Waiting for children to die<br/>\n";
	  
	  $pid = pcntl_wait(&$status);
	  print formatdate() . " Child with pid $pid has exited</br>\n";
	  $i = array_search($pid, $pidlist);
	  unset($pidlist[$i]);
	}
      } else {
	print "pcntl_fork function is not available</br>\n";
      }
      
      print formatdate() . " End script</br>\n" ;
    ?>
    </p>
  </body>
</html>