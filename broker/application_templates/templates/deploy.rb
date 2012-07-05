#!/usr/bin/env ruby
require 'rubygems'
require 'yaml'
require 'tempfile'
require 'json'

templates = YAML.load(DATA)

templates.each do |name,opts|
  begin
    puts "Deploying #{name}"
    metadata_file = Tempfile.new('metadata')
    descriptor_file = Tempfile.new('descriptor')

    metadata_file.write JSON.pretty_generate(opts[:metadata])
    metadata_file.close

    descriptor_file.write YAML.dump(opts[:descriptor])
    descriptor_file.close

    script = "#{opts[:script]} --descriptor '#{descriptor_file.path}' --metadata '#{metadata_file.path}' "
    puts `#{script}`
  ensure
    [metadata_file,descriptor_file].each do |f|
      f.close
      f.unlink
    end
  end
end

__END__
--- !omap 
- drupal: 
    :descriptor: 
      Requires: 
      - php-5.3
      - mysql-5.1
      License: unknown
      Vendor: unknown
      Connections: 
        mysql-5.1-php-5.3: 
          Components: 
          - php-5.3
          - mysql-5.1
      Architecture: noarch
      Scaling: 
        Max: -1
        Min: 1
      Name: drupal
      Description: ""
      Version: "0.0"
      Display-Name: drupal-0.0-noarch
    :script: rhc-admin-ctl-template --command 'add' --cost '1' --git-url 'git://github.com/openshift/drupal-example.git' --named 'Drupal' --tags 'php,drupal,wiki,framework,experimental'
    :metadata: !omap 
      - :credentials: 
        - :password: OpenShiftAdmin
          :username: Admin
      - :description: An open source content management platform written in PHP powering millions of websites and applications. It is built, used, and supported by an active and diverse community of people around the world.
      - :git_project_url: http://github.com/openshift/drupal-example
      - :git_url: git://github.com/openshift/drupal-example.git
      - :license: :"gpl2+"
      - :version: 7.7
      - :website: http://drupal.org/
- kitchensink: 
    :descriptor: 
      Requires: 
      - jbossas-7
      License: unknown
      Vendor: unknown
      Architecture: noarch
      Scaling: 
        Max: -1
        Min: 1
      Name: kitchensink
      Description: ""
      Version: "0.0"
      Display-Name: kitchensink-0.0-noarch
    :script: rhc-admin-ctl-template --command 'add' --cost '1' --git-url 'git://github.com/openshift/kitchensink-example.git' --named 'Kitchensink Example' --tags 'java,jboss,framework,experimental'
    :metadata: !omap 
      - :description: This quickstart uses JBoss AS7 to show off all the new features of Java EE 6 and makes a great starting point for your Java project.
      - :git_project_url: http://github.com/openshift/kitchensink-example
      - :git_url: git://github.com/openshift/kitchensink-example.git
      - :license: :apache2
      - :version: 7.0.0
      - :website: https://docs.jboss.org/author/display/AS71/Kitchensink+quickstart
- rails: 
    :descriptor: 
      Requires: 
      - ruby-1.8
      - mysql-5.1
      License: unknown
      Vendor: unknown
      Connections: 
        mysql-5.1-ruby-1.8: 
          Components: 
          - ruby-1.8
          - mysql-5.1
      Architecture: noarch
      Scaling: 
        Max: -1
        Min: 1
      Name: rails
      Description: ""
      Version: "0.0"
      Display-Name: rails-0.0-noarch
    :script: rhc-admin-ctl-template --command 'add' --cost '1' --git-url 'git://github.com/openshift/rails-example.git' --named 'Ruby on Rails' --tags 'ruby,rails,framework,experimental'
    :metadata: !omap 
      - :description: An open source web framework for Ruby that is optimized for programmer happiness and sustainable productivity. It lets you write beautiful code by favoring convention over configuration.
      - :git_project_url: http://github.com/openshift/rails-example
      - :git_url: git://github.com/openshift/rails-example.git
      - :license: :mit
      - :version: 3.1.1
      - :website: http://rubyonrails.org/
- springeap6: 
    :descriptor: !omap 
      - Architecture: noarch
      - Description: ""
      - Display-Name: springeap6-0.0-noarch
      - License: unknown
      - Name: springeap6
      - Requires: 
        - jbosseap-6.0
      - Scaling: 
          Max: -1
          Min: 1
      - Vendor: unknown
      - Version: "0.0"
    :script: rhc-admin-ctl-template --command 'add' --cost '1' --git-url 'git://github.com/openshift/spring-eap6-quickstart.git' --named 'Spring Framework on JBoss EAP6' --tags 'java,jboss,framework,experimental'
    :metadata: !omap 
      - :description: This quickstart allows you to use Spring Framework on JBoss JBoss EAP 6.
      - :git_project_url: http://github.com/openshift/spring-eap6-quickstart
      - :git_url: git://github.com/openshift/spring-eap6-quickstart.git
      - :license: :apache2
      - :version: 3.1.1
      - :website: http://springframework.org/
- wordpress: 
    :descriptor: 
      Requires: 
      - php-5.3
      - mysql-5.1
      License: unknown
      Vendor: unknown
      Connections: 
        mysql-5.1-php-5.3: 
          Components: 
          - php-5.3
          - mysql-5.1
      Architecture: noarch
      Scaling: 
        Max: -1
        Min: 1
      Name: wordpress
      Description: ""
      Version: "0.0"
      Display-Name: wordpress-0.0-noarch
    :script: rhc-admin-ctl-template --command 'add' --cost '1' --git-url 'git://github.com/openshift/wordpress-example.git' --named 'WordPress' --tags 'php,wordpress,blog,framework,experimental'
    :metadata: !omap 
      - :credentials: 
        - :password: OpenShiftAdmin
          :username: Admin
      - :description: A semantic personal publishing platform written in PHP with a MySQL back end, focusing on aesthetics, web standards, and usability.
      - :git_project_url: http://github.com/openshift/wordpress-example
      - :git_url: git://github.com/openshift/wordpress-example.git
      - :license: :"gpl2+"
      - :version: 3.3.2
      - :website: http://wordpress.org
