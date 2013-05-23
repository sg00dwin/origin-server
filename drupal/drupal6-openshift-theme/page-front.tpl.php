<?php include 'page_header.inc' ?>
<header>
  <?php include 'page_top.inc' ?>
  <?php include 'page_nav.inc' ?>
</header>
<div id="home" class="ie6 ie7 ie8">
  <div class="container">
    <section class="products" id="products">
      <ul class="row-fluid">
        <li class="span4 active online">
          <div>
            <a href="#" class="block">
              <header>
                <h1>Online</h1>
                <h2>Public PaaS</h2>
              </header>
              <p>
                a public cloud application development and hosting platform which leverages a Platform-as-a-Service (PaaS) architecture
              </p>
            </a>
            <a href="#" class="learn">Learn more</a>
            <a href="#" class="cta">Sign up for free <span aria-hidden="true" data-icon="&#xe007;"> </span></a>
          </div>
        </li>
        <li class="span4 enterprise">
          <div>
            <a href="#" class="block">
              <header>
                <h1>Enterprise</h1>
                <h2>Private PaaS</h2>
              </header>
              <p>
                the benefits of PaaS in an on-premise software product deployable in data-centers or private clouds
              </p>
            </a>
            <a href="#" class="learn">Learn more</a>
            <a href="#" class="cta">Request evaluation <span aria-hidden="true" data-icon="&#xe007;"> </span></a>
          </div>
        </li>
        <li class="span4 origin">
          <div>
            <a href="#" class="block">
              <header>
                <h1>Origin</h1>
                <h2>Community PaaS</h2>
              </header>
              <p>
                the community-driven upstream code base that feeds RedHat's OpenShift Online &amp; Enterprise product offerings
              </p>
            </a>
            <a href="#" class="learn">Learn more</a>
            <a href="#" class="cta">Join the community <span aria-hidden="true" data-icon="&#xe007;"> </span></a>
          </div>
        </li>
      </ul>
    </section>
    <section class="redhat full-width" id="redhat">
      <header>
        <h1>Public and private PaaS by the open source leader</h1>
      </header>
      <img src="<?php print openshift_assets_url(); ?>/redhat.png" alt="Red Hat" />    
      <p>
        OpenShift is available in two different consumption models: the <a href="#">OpenShift Online</a> hosted service and the <a href="#">OpenShift Enterprise</a> on-premise PaaS software product.
      </p>
    </section>
    <section>
      <header>
        <h1>Write your apps the way you want</h1>
      </header>
      <ul class="logos">
        <li>
          <img src="<?php print openshift_assets_url(); ?>/placeholder.png" alt="" />    
        </li>
        <li>
          <img src="<?php print openshift_assets_url(); ?>/placeholder.png" alt="" />    
        </li>
        <li>
          <img src="<?php print openshift_assets_url(); ?>/placeholder.png" alt="" />    
        </li>
        <li>
          <img src="<?php print openshift_assets_url(); ?>/placeholder.png" alt="" />    
        </li>
        <li>
          <img src="<?php print openshift_assets_url(); ?>/placeholder.png" alt="" />    
        </li>
        <li>
          <img src="<?php print openshift_assets_url(); ?>/placeholder.png" alt="" />    
        </li>
        <li>
          <img src="<?php print openshift_assets_url(); ?>/placeholder.png" alt="" />    
        </li>
      </ul>
      <p>
        OpenShift is a cloud application development and hosting platform which 
leverages a Platform-as-a-Service (PaaS) architecture. The PaaS architecture of OpenShift automates the provisioning, 
management and scaling of applications so that the developers can focus on writing the code of these applications for their 
business, startup, or next big idea. A choice of programming languages and a complete set of developer tools are available within 
OpenShift to increase developer productivity and accelerate application delivery in a no-lock-in fashion and with enterprise-class 
security and high efficiency.
      </p>
    </section>
    <section>
      <header>
        <h1>A rich ecosystem of trusted service providers</h1>
      </header>
      <ul class="logos">
        <li>
          <img src="<?php print openshift_assets_url(); ?>/placeholder.png" alt="" />    
        </li>
        <li>
          <img src="<?php print openshift_assets_url(); ?>/placeholder.png" alt="" />    
        </li>
        <li>
          <img src="<?php print openshift_assets_url(); ?>/placeholder.png" alt="" />    
        </li>
        <li>
          <img src="<?php print openshift_assets_url(); ?>/placeholder.png" alt="" />    
        </li>
        <li>
          <img src="<?php print openshift_assets_url(); ?>/placeholder.png" alt="" />    
        </li>
        <li>
          <img src="<?php print openshift_assets_url(); ?>/placeholder.png" alt="" />    
        </li>
        <li>
          <img src="<?php print openshift_assets_url(); ?>/placeholder.png" alt="" />    
        </li>
        <li>
          <img src="<?php print openshift_assets_url(); ?>/placeholder.png" alt="" />    
        </li>
        <li>
          <img src="<?php print openshift_assets_url(); ?>/placeholder.png" alt="" />    
        </li>
        <li>
          <img src="<?php print openshift_assets_url(); ?>/placeholder.png" alt="" />    
        </li>
        <li>
          <img src="<?php print openshift_assets_url(); ?>/placeholder.png" alt="" />    
        </li>
        <li>
          <img src="<?php print openshift_assets_url(); ?>/placeholder.png" alt="" />    
        </li>
        <li>
          <img src="<?php print openshift_assets_url(); ?>/placeholder.png" alt="" />    
        </li>
        <li>
          <img src="<?php print openshift_assets_url(); ?>/placeholder.png" alt="" />    
        </li>
        <li>
          <img src="<?php print openshift_assets_url(); ?>/placeholder.png" alt="" />    
        </li>
      </ul>
      <p>
        At Red Hat OpenShift, our approach to partnering is designed with the customer in mind. Our customers demand choice and hence our goal is to work broadly with partners to make available complementary partner technologies and products along with Red Hat’s own offerings to satisfy the needs of our customers.
      </p>
    </section>
  </div>
</div>
<?php include 'page_footer.inc' ?>
<script type="text/javascript">
  $.fn.setAllToMaxHeight = function(){
      return this.height( Math.max.apply(this, $.map( this , function(e){ return $(e).height() }) ) );
    }
  $(document).ready(function() {
    var products = $('li', '#products');
    products.on('mouseover', function() {
      products.removeClass('active');
      $(this).addClass('active');
    });
    var productDescriptions = $('#products li p');
    productDescriptions.setAllToMaxHeight();
    $(window).resize(function() {
      //console.log('resizing');
      productDescriptions.css('height', 'auto');
      productDescriptions.setAllToMaxHeight();
    });
  });

</script>