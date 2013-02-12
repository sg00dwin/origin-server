
<style type="text/css">
#tabs {
  display: none;
}
.column-1 ul {
  background: url('<?php print openshift_server_url(); ?>/app/assets/community-bubbles.png') top left no-repeat;
  min-height: 68px;
  margin: 0 0 12px 12px;
}
.column-1 li {
  margin-left: 108px;
}

.column-1 {
  width: 45%;
  margin-right: 4.5%;
  float: left;
  padding-right: 50px;
  border-right: 1px solid #ccc;
}
.column-2 {
  width: 41%;
  float: left;
}
.label-hide label {
  display: none;
}
.frame {
  max-width: 768px;
  margin: 0 auto;
//  border: 1px solid #ddd;
}
.frame-primary {
  background: #fff;
  color: inherit;
  padding: 40px 60px;
  margin-bottom: 50px;
}
.input-max {width: 94%;/* otherwise inputs extend to far */}
.label-hide label {
  display: none;
}
.announcement a, .announcement h4 {color: inherit;}

.frame-announcement {
  background-color: #aaa;
  margin: 30px auto;
  padding: 25px 35px;
  color: #303030;
}
.frame-announcement.outage {
  background-color:#FFD24E;
  margin-bottom: 0;
}
.announcement + .announcement {
    margin-top: 20px;
}
.updates .update { 
  margin-top: 5px;
}
.form-actions {
  padding-top: 0;
}
.btn-large { text-transform: uppercase;}

.timestamp {font-size: 11.5px;}


@media (max-width: 767px) {
  .column-1, .column-2 {
    width: 98%;
  }
  .column-1 {margin-bottom: 20px; border-right: 0;}
  .frame-primary {
    padding: 40px 35px 30px;
  }
}
@media (max-width: 480px) {
  .frame-primary,
  .frame-announcement {
    margin: 0 -20px 30px;
    padding: 30px;
  }
  h1.marquee {
  font-size: 30px;
}
}

</style>

<section class="frame frame-primary">
            
              <div class="row-fluid">
                <div class="column-1">

                  <h2>Enter your OpenShift login</h2>
                  <ul class="spaced-items">
                    <li>post forum questions and comments</li>
                    <li>contribute to the wiki</li>
                    <li>vote for new features</li>
                  </ul> 
                  <?php print $rendered; ?>
                  <p class="pull-right smaller"><a href="/app/account/password/new">Forgot your password?</a></p>
                </div>
                <div class="column-2">
                  <h2>Need an account? <a href="">Create one</a></h2>
                  <ul class="spaced-items">
                    <li>Code and deploy to the cloud in minutes.</li>
                    <li>No-Lock-In. Built on open technologies.</li>
                    <li>Java, Ruby, Node.js, Python, PHP, or Perl</li>
                    <li>Grow your applications easily with resource scaling.</li>
                  </ul>
                </div> 
              </div>
                     
</section>
