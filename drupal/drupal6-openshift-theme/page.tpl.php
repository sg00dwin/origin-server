<?php include 'page_header.inc' ?>

    <header>
      <?php include 'page_top.inc' ?>
      <?php include 'page_nav.inc' ?>
    </header>

    <div id="content" class="section-striped">
      <div class="container"><div class="row-content">
      <div class='row row-flush-right'>
        <?php if ($layout == 'left') :?>
      	<div class="column-navbar">      	
        	<a data-toggle="collapse" data-target=".nav-collapse" class="btn btn-navbar">
        	<span class="pull-left">Navigate</span>
        	<span class="pull-right">
        	<span class="icon-bar"></span>
        	<span class="icon-bar"></span>
        	<span class="icon-bar"></span>
        	</span>
        	</a>
        </div>
          <div class="column-nav lift-less grid-wrapper">
          <div class="nav-collapse collapse">
            <nav class="span3">
              <div class="gutter-right">
                <?php print $sidebar_left; ?>
              </div>
            </nav>
           </div>
          </div>
          <div class="column-content lift grid-wrapper">
            <div class="span9 span-flush-right">

        <?php elseif ($layout == 'both') :?>
          <div class="column-nav lift-less grid-wrapper">
            <nav class="span3">
              <div class="gutter-right">
                <?php print $sidebar_left; ?>
              </div>
            </nav>
          </div>
          <div class="column-content lift grid-wrapper">
            <div class="span6 span-flush-right">

        <?php elseif ($layout == 'right') :?>
          <div class="column-content lift grid-wrapper">
            <div class="span9 span-flush-right">

        <?php elseif ($layout == 'none') :?>
          <div class="column-content lift grid-wrapper">
            <div class="span12 span-flush-right">
        <?php endif; ?>

            <?php if ($heading) :?>
              <h1 class="ribbon">
                <div class="ribbon-content"><?php print $heading; ?></div>
                <div class="ribbon-left"></div>
              </h1>
            <?php endif; ?>

            <section class='default' id='about'>
              <?php if ($show_messages && $messages): print $messages; endif; ?>
            <?php print $breadcrumb; ?>
            <?php if ($tabs) :?>
            <div id="tabs"><?php print $tabs; ?></div>
            <?php endif; ?>
            <?php if ($forum['new-topic'] == TRUE) :?>
            <div id="forum-header" class="forum-new-topic">
              <div class="forum-header-left">
                <h2>Post a New Thread</h2>
              </div>
            </div>
            <?php endif; ?>
            <?php print $content_prefix; ?>
            <?php print $content; ?>

            </section>
            <?php print $content_suffix; ?>
         </div>

        <?php if ($layout == 'both' || $layout == 'right') :?>
          <div class="column-nav lift-less grid-wrapper">
            <div class="span3">
              <div class="gutter-right">
                <?php print $sidebar_right; ?>
              </div>
            </div>
          </div>
        <?php endif; ?>

          </div>
        </div>
      </div>
      </div></div>
    </div>

<?php include 'page_footer.inc' ?>
