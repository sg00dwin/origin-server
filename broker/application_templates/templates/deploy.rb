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
wordpress:
  :script: rhc-admin-ctl-template --command 'add' --named 'WordPress' --cost '1' --tags
    'php,wordpress,blog,framework,experimental' --git-url 'git://github.com/openshift/wordpress-example.git'
  :metadata:
    :git_url: git://github.com/openshift/wordpress-example.git
    :git_project_url: http://github.com/openshift/wordpress-example
    :website: http://wordpress.org
    :version: 3.3.2
    :license: :gpl2+
    :description: ! 'A semantic personal publishing platform written in PHP with a
      MySQL back end, focusing on aesthetics, web standards, and usability.

'
  :descriptor:
    Display-Name: wordpress-0.0-noarch
    Architecture: noarch
    Name: wordpress
    License: unknown
    Description: ''
    Connections:
      mysql-5.1-php-5.3:
        Components:
        - php-5.3
        - mysql-5.1
    Requires:
    - php-5.3
    - mysql-5.1
    Subscribes:
      doc-root:
        Required: false
        Type: FILESYSTEM:doc-root
    Vendor: unknown
    Version: '0.0'
drupal:
  :script: rhc-admin-ctl-template --command 'add' --named 'Drupal' --cost '1' --tags
    'php,drupal,wiki,framework,experimental' --git-url 'git://github.com/openshift/drupal-example.git'
  :metadata:
    :git_url: git://github.com/openshift/drupal-example.git
    :git_project_url: http://github.com/openshift/drupal-example
    :website: http://drupal.org/
    :version: 7.7
    :license: :gpl2+
    :description: ! 'An open source content management platform written in PHP powering
      millions of websites and applications. It is built, used, and supported by an
      active and diverse community of people around the world.

'
  :descriptor:
    Display-Name: drupal-0.0-noarch
    Architecture: noarch
    Name: drupal
    License: unknown
    Description: ''
    Connections:
      mysql-5.1-php-5.3:
        Components:
        - php-5.3
        - mysql-5.1
    Requires:
    - php-5.3
    - mysql-5.1
    Subscribes:
      doc-root:
        Required: false
        Type: FILESYSTEM:doc-root
    Vendor: unknown
    Version: '0.0'
rails:
  :script: rhc-admin-ctl-template --command 'add' --named 'Ruby on Rails' --cost '1'
    --tags 'ruby,rails,framework,experimental' --git-url 'git://github.com/openshift/rails-example.git'
  :metadata:
    :git_url: git://github.com/openshift/rails-example.git
    :git_project_url: http://github.com/openshift/rails-example
    :website: http://rubyonrails.org/
    :version: 3.1.1
    :license: :mit
    :description: ! 'An open source web framework for Ruby that is optimized for programmer
      happiness and sustainable productivity. It lets you write beautiful code by
      favoring convention over configuration.

'
  :descriptor:
    Display-Name: rails-0.0-noarch
    Architecture: noarch
    Name: rails
    License: unknown
    Description: ''
    Connections:
      mysql-5.1-ruby-1.8:
        Components:
        - ruby-1.8
        - mysql-5.1
    Requires:
    - ruby-1.8
    - mysql-5.1
    Subscribes:
      doc-root:
        Required: false
        Type: FILESYSTEM:doc-root
    Vendor: unknown
    Version: '0.0'
kitchensink:
  :script: rhc-admin-ctl-template --command 'add' --named 'Kitchensink Example' --cost
    '1' --tags 'java,jboss,framework,experimental' --git-url 'git://github.com/openshift/kitchensink-example.git'
  :metadata:
    :git_url: git://github.com/openshift/kitchensink-example.git
    :git_project_url: http://github.com/openshift/kitchensink-example
    :website: https://docs.jboss.org/author/display/AS71/Kitchensink+quickstart
    :version: 7.0.0
    :license: :apache2
    :description: ! 'This quickstart uses JBoss AS7 to show off all the new features
      of Java EE 6 and makes a great starting point for your Java project.

'
  :descriptor:
    Display-Name: kitchensink-0.0-noarch
    Architecture: noarch
    Name: kitchensink
    License: unknown
    Description: ''
    Requires:
    - jbossas-7
    Subscribes:
      doc-root:
        Required: false
        Type: FILESYSTEM:doc-root
    Vendor: unknown
    Version: '0.0'
