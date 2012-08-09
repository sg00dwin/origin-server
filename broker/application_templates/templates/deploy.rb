#!/usr/bin/env ruby
require 'rubygems'
require 'yaml'
require 'tempfile'
require 'json'
require 'bson'

# Courtesy of: http://as.rubyonrails.org/classes/Object.html#M000010
def returning(value)
  yield(value)
  value
end

templates = YAML.load(DATA)

templates.each do |options|
  begin
    name = options[:name]
    puts "Deploying #{name}"

    # Create a hash of all files to include as options
    files = Hash[
      [:descriptor, :metadata ].map do |name|
        file = returning(Tempfile.new(name)) do |file|
          file.write options[name]
          file.close
          file
        end

        [name,file]
      end
    ]

    # Create the script to run
    script = [
      options[:script],
      *files.map{|k,v| "--%s '%s'" % [k,v.path]}
    ].join(' ')

    puts `#{script}`
  ensure
    # Make sure all of the files are closed
    files.each do |name,f|
      f.close
      f.unlink
    end
  end
end

__END__
---
- :descriptor: |
    ---
    Name: cakephp
    Scaling:
      Max: -1
      Min: 1
    License-Url: ""
    License: unknown
    Help-Topics: {}

    Requires:
    - php-5.3
    - mysql-5.1
    Display-Name: cakephp-0.0-noarch
    Cart-Data: {}

    Connections:
      mysql-5.1-php-5.3:
        Components:
        - php-5.3
        - mysql-5.1
    Version: "0.0"
    Website: ""
    Vendor: unknown
    Categories:
    - cartridge
    Description: ""
    Architecture: noarch

  :script: rhc-admin-ctl-template --command 'add' --cost '1' --git-url 'git://github.com/openshift/cakephp-example.git' --named 'CakePHP' --tags 'php,cakephp,framework,experimental'
  :metadata: |-
    {
      "website": "http://cakephp.org/",
      "git_url": "git://github.com/openshift/cakephp-example.git",
      "license": "mit",
      "version": "2.2.1",
      "git_project_url": "http://github.com/openshift/cakephp-example",
      "description": "CakePHP is a rapid development framework for PHP which uses commonly known design patterns like Active Record, Association Data Mapping, Front Controller and MVC."
    }
  :name: cakephp
- :descriptor: |
    ---
    Name: drupal
    Scaling:
      Max: -1
      Min: 1
    License-Url: ""
    License: unknown
    Help-Topics: {}

    Requires:
    - php-5.3
    - mysql-5.1
    Display-Name: drupal-0.0-noarch
    Cart-Data: {}

    Connections:
      mysql-5.1-php-5.3:
        Components:
        - php-5.3
        - mysql-5.1
    Version: "0.0"
    Website: ""
    Vendor: unknown
    Categories:
    - cartridge
    Description: ""
    Architecture: noarch

  :script: rhc-admin-ctl-template --command 'add' --cost '1' --git-url 'git://github.com/openshift/drupal-example.git' --named 'Drupal' --tags 'php,drupal,wiki,framework,experimental'
  :metadata: |-
    {
      "website": "http://drupal.org/",
      "git_url": "git://github.com/openshift/drupal-example.git",
      "license": "gpl2+",
      "credentials": [
        {
          "username": "Admin",
          "password": "OpenShiftAdmin"
        }
      ],
      "version": 7.7,
      "git_project_url": "http://github.com/openshift/drupal-example",
      "description": "An open source content management platform written in PHP powering millions of websites and applications. It is built, used, and supported by an active and diverse community of people around the world."
    }
  :name: drupal
- :descriptor: |
    ---
    Name: kitchensink
    Scaling:
      Max: -1
      Min: 1
    License-Url: ""
    License: unknown
    Help-Topics: {}

    Requires:
    - jbossas-7
    Display-Name: kitchensink-0.0-noarch
    Cart-Data: {}

    Version: "0.0"
    Website: ""
    Vendor: unknown
    Categories:
    - cartridge
    Description: ""
    Architecture: noarch

  :script: rhc-admin-ctl-template --command 'add' --cost '1' --git-url 'git://github.com/openshift/kitchensink-example.git' --named 'Kitchensink Example' --tags 'java,jboss,framework,experimental'
  :metadata: |-
    {
      "website": "https://docs.jboss.org/author/display/AS71/Kitchensink+quickstart",
      "git_url": "git://github.com/openshift/kitchensink-example.git",
      "license": "apache2",
      "version": "7.0.0",
      "git_project_url": "http://github.com/openshift/kitchensink-example",
      "description": "This quickstart uses JBoss AS7 to show off all the new features of Java EE 6 and makes a great starting point for your Java project."
    }
  :name: kitchensink
- :descriptor: |
    ---
    Name: rails
    Scaling:
      Max: -1
      Min: 1
    License-Url: ""
    License: unknown
    Help-Topics: {}

    Requires:
    - ruby-1.9
    - mysql-5.1
    Display-Name: rails-0.0-noarch
    Cart-Data: {}

    Connections:
      mysql-5.1-ruby-1.9:
        Components:
        - ruby-1.9
        - mysql-5.1
    Version: "0.0"
    Website: ""
    Vendor: unknown
    Categories:
    - cartridge
    Description: ""
    Architecture: noarch

  :script: rhc-admin-ctl-template --command 'add' --cost '1' --git-url 'git://github.com/openshift/rails-example.git' --named 'Ruby on Rails' --tags 'ruby,rails,framework,experimental'
  :metadata: |-
    {
      "website": "http://rubyonrails.org/",
      "git_url": "git://github.com/openshift/rails-example.git",
      "license": "mit",
      "version": "3.2.6",
      "git_project_url": "http://github.com/openshift/rails-example",
      "description": "An open source web framework for Ruby that is optimized for programmer happiness and sustainable productivity. It lets you write beautiful code by favoring convention over configuration."
    }
  :name: rails
- :descriptor: |
    ---
    Name: springeap6
    Scaling:
      Max: -1
      Min: 1
    License-Url: ""
    License: unknown
    Help-Topics: {}

    Requires:
    - jbosseap-6.0
    Display-Name: springeap6-0.0-noarch
    Cart-Data: {}

    Version: "0.0"
    Website: ""
    Vendor: unknown
    Categories:
    - cartridge
    Description: ""
    Architecture: noarch

  :script: rhc-admin-ctl-template --command 'add' --cost '1' --git-url 'git://github.com/openshift/spring-eap6-quickstart.git' --named 'Spring Framework on JBoss EAP6' --tags 'java,jboss,framework,experimental'
  :metadata: |-
    {
      "website": "http://springframework.org/",
      "git_url": "git://github.com/openshift/spring-eap6-quickstart.git",
      "license": "apache2",
      "version": "3.1.1",
      "git_project_url": "http://github.com/openshift/spring-eap6-quickstart",
      "description": "This quickstart allows you to use Spring Framework on JBoss EAP 6."
    }
  :name: springeap6
- :descriptor: |
    ---
    Name: wordpress
    Scaling:
      Max: -1
      Min: 1
    License-Url: ""
    License: unknown
    Help-Topics: {}

    Requires:
    - php-5.3
    - mysql-5.1
    Display-Name: wordpress-0.0-noarch
    Cart-Data: {}

    Connections:
      mysql-5.1-php-5.3:
        Components:
        - php-5.3
        - mysql-5.1
    Version: "0.0"
    Website: ""
    Vendor: unknown
    Categories:
    - cartridge
    Description: ""
    Architecture: noarch

  :script: rhc-admin-ctl-template --command 'add' --cost '1' --git-url 'git://github.com/openshift/wordpress-example.git' --named 'WordPress' --tags 'php,wordpress,blog,framework,experimental'
  :metadata: |-
    {
      "website": "http://wordpress.org",
      "git_url": "git://github.com/openshift/wordpress-example.git",
      "license": "gpl2+",
      "credentials": [
        {
          "username": "Admin",
          "password": "OpenShiftAdmin"
        }
      ],
      "version": "3.3.2",
      "git_project_url": "http://github.com/openshift/wordpress-example",
      "description": "A semantic personal publishing platform written in PHP with a MySQL back end, focusing on aesthetics, web standards, and usability."
    }
  :name: wordpress
