      <div id="nav" class="section-nav lift-counter">
        <div class="navbar">
          <div class="container">
            <div class="brand">
              <a href="/">
                <div class="brand-image"></div>
                <div class="brand-text"><strong>Open</strong>Shift</div>
              </a>
            </div>
            <ul class="nav">
                <?php $i = 0; foreach( $primary_links as $key=>$link) {
                if ($i++ == 2) {
                  print '<li class="divider">&nbsp;</li>';
                }
                $link['options']['html'] = TRUE;
              ?>
                <li class="<?php print strpos($key,'active-trail') ? "active" : ""; ?>"><?php print l("<span>" . $link['title'] . "</span>", $link['href'], $link['options']); ?></li>
              <?php } ?>
            </ul>
          </div>
        </div>

        <?php print $messaging; ?>

      </div>
