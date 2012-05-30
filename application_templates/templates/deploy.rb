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
---
drupal:
  :descriptor:
    Requires:
    - php-5.3
    - mysql-5.1
    Name: drupal
    Vendor: unknown
    Subscribes:
      doc-root:
        Type: FILESYSTEM:doc-root
        Required: false
    Description: ""
    Version: "0.0"
    Connections:
      mysql-5.1-php-5.3:
        Components:
        - php-5.3
        - mysql-5.1
    Architecture: noarch
    Display-Name: drupal-0.0-noarch
    License: unknown
  :metadata:
    :version: 7.7
    :website: http://drupal.org/
    :git_url: git://github.com/openshift/drupal-example.git
    :description: |
      An open source content management platform written in PHP powering millions of websites and applications. It is built, used, and supported by an active and diverse community of people around the world.

    :license: :"gpl2+"
    :git_project_url: http://github.com/openshift/drupal-example
  :script: rhc-admin-ctl-template --cost '1' --git-url '' --tags 'php,drupal,wiki,framework' --command 'add' --named 'Drupal'
kitchensink:
  :descriptor:
    Requires:
    - jbossas-7
    Name: kitchensink
    Vendor: unknown
    Subscribes:
      doc-root:
        Type: FILESYSTEM:doc-root
        Required: false
    Description: ""
    Version: "0.0"
    Architecture: noarch
    Display-Name: kitchensink-0.0-noarch
    License: unknown
  :metadata:
    :version: 7.0.0
    :website: https://docs.jboss.org/author/display/AS71/Kitchensink+quickstart
    :git_url: git://github.com/openshift/kitchensink-example.git
    :description: |
      This quickstart uses JBoss AS7 to show off all the new features of Java EE 6 and makes a great starting point for your Java project.

    :license: :apache2
    :git_project_url: http://github.com/openshift/kitchensink-example
  :script: rhc-admin-ctl-template --cost '1' --git-url '' --tags 'java,jboss,framework' --command 'add' --named 'Kitchensink Example'
rails:
  :descriptor:
    Requires:
    - ruby-1.8
    - mysql-5.1
    Name: rails
    Vendor: unknown
    Subscribes:
      doc-root:
        Type: FILESYSTEM:doc-root
        Required: false
    Description: ""
    Version: "0.0"
    Connections:
      mysql-5.1-ruby-1.8:
        Components:
        - ruby-1.8
        - mysql-5.1
    Architecture: noarch
    Display-Name: rails-0.0-noarch
    License: unknown
  :metadata:
    :version: 3.1.1
    :website: http://rubyonrails.org/
    :git_url: git://github.com/openshift/rails-example.git
    :description: |
      An open source web framework for Ruby that is optimized for programmer happiness and sustainable productivity. It lets you write beautiful code by favoring convention over configuration.

    :license: :mit
    :git_project_url: http://github.com/openshift/rails-example
  :script: rhc-admin-ctl-template --cost '1' --git-url '' --tags 'ruby,rails,framework' --command 'add' --named 'Ruby on Rails'
wordpress:
  :descriptor:
    Requires:
    - php-5.3
    - mysql-5.1
    Name: wordpress
    Vendor: unknown
    Subscribes:
      doc-root:
        Type: FILESYSTEM:doc-root
        Required: false
    Description: ""
    Version: "0.0"
    Connections:
      mysql-5.1-php-5.3:
        Components:
        - php-5.3
        - mysql-5.1
    Architecture: noarch
    Display-Name: wordpress-0.0-noarch
    License: unknown
  :metadata:
    :version: 3.3.2
    :website: http://wordpress.org
    :git_url: git://github.com/openshift/wordpress-example.git
    :description: |
      A semantic personal publishing platform written in PHP with a MySQL back end, focusing on aesthetics, web standards, and usability.

    :license: :"gpl2+"
    :git_project_url: http://github.com/openshift/wordpress-example
  :script: rhc-admin-ctl-template --cost '1' --git-url '' --tags 'php,wordpress,blog,framework' --command 'add' --named 'WordPress'
