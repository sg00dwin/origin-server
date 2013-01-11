
      <div id="top" class="section-top">
        <div class="container">
        <a title="Track open issues on the OpenShift status page" style="display:none;" id="outage" class="btn btn-small btn-warning" href="<?php print $openshift_server_url; ?>/app/status">Status</a>
          <div class="pull-right login">

          <form action="/search/node" method="get" id="search-top">
             <input name="keys" class="search-query" type="text" placeholder="SEARCH">
             <button type="submit" class="search" value="Search"></button>
             <?php print $search['hidden']; ?>
          </form>

            <?php
            global $user;

            print '<a class="btn btn-small" href="'.$openshift_server_url.'/app/console">My Apps</a> ';
            print '<a class="btn btn-small" href="'.$openshift_server_url.'/app/account/new">Sign Up</a> ';
            ?>
          </div>
          <div class="mobile-block"><a href="/enterprise-paas"><span>Streamline App Delivery with  </span>OpenShift Enterprise</a></div>
        </div>
      </div>
