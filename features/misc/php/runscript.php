<?php
# define any functions needed later
date_default_timezone_set("UTC");

function formatdate() {
  return date("Ymd-H:i:sT");
}

#
# get parameters from $_GET or defaults
#
$defaults = 
  array('cmd' => "shell/simple.sh1",
	'background' => FALSE
	);

# Actual options provided
$opts = array();

# assign the default or provided value from $_GET for each variable
foreach (array_keys($defaults) as $key) {
  if (array_key_exists($key, $_GET)) {
    $opts[$key] = $_GET[$key];
  } else {
    $opts[$key] = $defaults[$key];
  }
}

$titleformat = "Run Script: '%s'\n";
$title = sprintf($titleformat, $opts['cmd']);

?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">
<html>
  <head>
    <title><?php echo $title ?></title>
  </head>
  <body>
    <h1 style="text-align: center;"><?php echo $title ?></h1>
    <p>
      <?php
	print formatdate() . " Begin script<br/>\n" ;
      ?>
      <hr/>
      <pre>
      <?php
	  $result = exec("$opts[cmd] 2>&1", &$lines, $status);
	  foreach ($lines as $line) {
	    print $line . "\n";
	  }
	  print "\n$opts[cmd] returned status $status\n";
	?>
      </pre>
      <hr/>
      <?php
	print formatdate() . " End script<br/>\n" ;
      ?>
    </p>
  </body>
</html>