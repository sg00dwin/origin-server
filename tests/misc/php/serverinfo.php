<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">
<html>
  <head>
    <title>Server Information</title>
  </head>
  <body>
    <h1 style="text-align: center;">PHP Server Information</h1>
    <p>
      <?php

   date_default_timezone_set("UTC");
   
   print "<hr/>\n";
   
   foreach($_SERVER as $key_name => $key_value) {
     print $key_name . " = " . $key_value . "<br>\n";
   }
   
   print "<hr/>\n<pre>\n";
   
   phpinfo();
   
   print "</pre><br/>\n";
   
   #foreach($php_info as $key_name => $key_value) {
   #  print $key_name . " = " . $key_value . "<br>\n";
   #}

      ?>
    </p>
  </body>
</html>