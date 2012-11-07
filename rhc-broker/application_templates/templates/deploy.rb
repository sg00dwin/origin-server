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
- :name: cakephp
  :script: oo-admin-ctl-template --command 'add' --cost '1' --git-url 'git://github.com/openshift/cakephp-example.git'
    --named 'CakePHP' --tags 'php,cakephp,framework,experimental'
  :metadata: ! '{"git_url":"git://github.com/openshift/cakephp-example.git","git_project_url":"http://github.com/openshift/cakephp-example","website":"http://cakephp.org/","version":"2.2.1","license":"mit","description":"CakePHP
    is a rapid development framework for PHP which uses commonly known design patterns
    like Active Record, Association Data Mapping, Front Controller and MVC."}'
  :descriptor: ! "---\nConnections:\n  mysql-5.1-php-5.3:\n    Components:\n    -
    php-5.3\n    - mysql-5.1\nDisplay-Name: cakephp-0.0-noarch\nName: cakephp\nRequires:\n-
    php-5.3\n- mysql-5.1\n"
- :name: cakephptest
  :script: oo-admin-ctl-template --command 'add' --cost '1' --git-url 'git://github.com/nhr/cakephp-example.git'
    --named 'CakePHP (TEST)' --tags 'php,cakephp,framework,experimental,in_development'
  :metadata: ! '{"git_url":"git://github.com/nhr/cakephp-example.git","git_project_url":"http://github.com/nhr/cakephp-example","website":"http://cakephp.org/","version":"2.2.1","license":"mit","description":"CakePHP
    is a rapid development framework for PHP which uses commonly known design patterns
    like Active Record, Association Data Mapping, Front Controller and MVC."}'
  :descriptor: ! "---\nConnections:\n  mysql-5.1-php-5.3:\n    Components:\n    -
    php-5.3\n    - mysql-5.1\nDisplay-Name: cakephptest-0.0-noarch\nName: cakephptest\nRequires:\n-
    php-5.3\n- mysql-5.1\n"
- :name: django
  :script: oo-admin-ctl-template --command 'add' --cost '1' --git-url 'git://github.com/openshift/django-example.git'
    --named 'Django' --tags 'python,django,framework,experimental,in_development'
  :metadata: ! '{"git_url":"git://github.com/openshift/django-example.git","git_project_url":"http://github.com/openshift/django-example","website":"https://www.djangoproject.com/","version":1.4,"license":"bsd","description":"A
    high-level Python web framework that encourages rapid development and clean, pragmatic
    design."}'
  :descriptor: ! '---

    Display-Name: django-0.0-noarch

    Name: django

    Requires:

    - python-2.6

'
- :name: djangotest
  :script: oo-admin-ctl-template --command 'add' --cost '1' --git-url 'git://github.com/nhr/django-example.git'
    --named 'Django (Test)' --tags 'python,django,framework,experimental,in_development'
  :metadata: ! '{"git_url":"git://github.com/nhr/django-example.git","git_project_url":"http://github.com/nhr/django-example","website":"https://www.djangoproject.com/","version":1.4,"license":"bsd","description":"A
    high-level Python web framework that encourages rapid development and clean, pragmatic
    design."}'
  :descriptor: ! '---

    Display-Name: djangotest-0.0-noarch

    Name: djangotest

    Requires:

    - python-2.6

'
  
- :name: capedwarf
  :script: oo-admin-ctl-template --command 'add' --cost '1' --git-url 'git://github.com/openshift/capedwarf-example.git'
     --named 'CapeDwarf' --tags 'app engine,java,google,capedwarf,experimental'
  :metadata: ! '{"git_url":"git://github.com/openshift/capedwarf-example.git","git_project_url":"https://github.com/openshift/capedwarf-example","website":"http://www.jboss.org/capedwarf","version":"1.0.0-SNAPSHOT","license":"lgpl",
    "description":"Deploy and run your Java App Engine applications on your own private JBoss Application Server (AS7) cluster or on RedHats OpenShift cloud."}'
  :descriptor: ! '---

    Display-Name: capedwarf-0.0-noarch

    Name: capedwarf

    Requires:

    - jbossas-7

'
  
- :name: drupal
  :script: oo-admin-ctl-template --command 'add' --cost '1' --git-url 'git://github.com/openshift/drupal-example.git'
    --named 'Drupal' --tags 'php,drupal,wiki,framework,experimental'
  :metadata: ! '{"git_url":"git://github.com/openshift/drupal-example.git","git_project_url":"http://github.com/openshift/drupal-example","website":"http://drupal.org/","version":7.7,"license":"gpl2+","description":"An
    open source content management platform written in PHP powering millions of websites
    and applications. It is built, used, and supported by an active and diverse community
    of people around the world.","credentials":[{"username":"Admin","password":"OpenShiftAdmin"}]}'
  :descriptor: ! "---\nArchitecture: noarch\nCart-Data: {}\nCategories:\n- cartridge\nConnections:\n
    \ mysql-5.1-php-5.3:\n    Components:\n    - php-5.3\n    - mysql-5.1\nDescription:
    ''\nDisplay-Name: drupal-0.0-noarch\nHelp-Topics: {}\nLicense: unknown\nLicense-Url:
    ''\nName: drupal\nRequires:\n- php-5.3\n- mysql-5.1\nScaling:\n  Max: -1\n  Min:
    1\nVendor: unknown\nVersion: '0.0'\nWebsite: ''\n"
- :name: kitchensink
  :script: oo-admin-ctl-template --command 'add' --cost '1' --git-url 'git://github.com/openshift/kitchensink-example.git'
    --named 'JavaEE Full Profile Example on JBoss' --tags 'java,jboss,framework,experimental'
  :metadata: ! '{"git_url":"git://github.com/openshift/kitchensink-example.git","git_project_url":"http://github.com/openshift/kitchensink-example","website":"https://docs.jboss.org/author/display/AS71/Kitchensink+quickstart","version":"7.0.0","license":"apache2","description":"This
    quickstart uses JBoss AS7 to show off all the new features of Java EE 6 and makes
    a great starting point for your Java project."}'
  :descriptor: ! "---\nArchitecture: noarch\nCart-Data: {}\nCategories:\n- cartridge\nDescription:
    ''\nDisplay-Name: kitchensink-0.0-noarch\nHelp-Topics: {}\nLicense: unknown\nLicense-Url:
    ''\nName: kitchensink\nRequires:\n- jbossas-7\nScaling:\n  Max: -1\n  Min: 1\nVendor:
    unknown\nVersion: '0.0'\nWebsite: ''\n"
  
- :name: rails
  :script: oo-admin-ctl-template --command 'add' --cost '1' --git-url 'git://github.com/openshift/rails-example.git'
    --named 'Ruby on Rails' --tags 'ruby,rails,framework,experimental'
  :metadata: ! '{"git_url":"git://github.com/openshift/rails-example.git","git_project_url":"http://github.com/openshift/rails-example","website":"http://rubyonrails.org/","version":"3.2.6","license":"mit","description":"An
    open source web framework for Ruby that is optimized for programmer happiness
    and sustainable productivity. It lets you write beautiful code by favoring convention
    over configuration."}'
  :descriptor: ! "---\nArchitecture: noarch\nCart-Data: {}\nCategories:\n- cartridge\nConnections:\n
    \ mysql-5.1-ruby-1.9:\n    Components:\n    - ruby-1.9\n    - mysql-5.1\nDescription:
    ''\nDisplay-Name: rails-0.0-noarch\nHelp-Topics: {}\nLicense: unknown\nLicense-Url:
    ''\nName: rails\nRequires:\n- ruby-1.9\n- mysql-5.1\nScaling:\n  Max: -1\n  Min:
    1\nVendor: unknown\nVersion: '0.0'\nWebsite: ''\n"
- :name: springeap6
  :script: oo-admin-ctl-template --command 'add' --cost '1' --git-url 'git://github.com/openshift/spring-eap6-quickstart.git'
    --named 'Spring Framework on JBoss EAP6' --tags 'java,jboss,framework,experimental'
  :metadata: ! '{"git_url":"git://github.com/openshift/spring-eap6-quickstart.git","git_project_url":"http://github.com/openshift/spring-eap6-quickstart","website":"http://springframework.org/","version":"3.1.1","license":"apache2","description":"This
    quickstart allows you to use Spring Framework on JBoss EAP 6."}'
  :descriptor: ! "---\nArchitecture: noarch\nCart-Data: {}\nCategories:\n- cartridge\nDescription:
    ''\nDisplay-Name: springeap6-0.0-noarch\nHelp-Topics: {}\nLicense: unknown\nLicense-Url:
    ''\nName: springeap6\nRequires:\n- jbosseap-6.0\nScaling:\n  Max: -1\n  Min: 1\nVendor:
    unknown\nVersion: '0.0'\nWebsite: ''\n"
- :name: wordpress
  :script: oo-admin-ctl-template --command 'add' --cost '1' --git-url 'git://github.com/openshift/wordpress-example.git'
    --named 'WordPress' --tags 'php,wordpress,blog,framework,experimental'
  :metadata: ! '{"git_url":"git://github.com/openshift/wordpress-example.git","git_project_url":"http://github.com/openshift/wordpress-example","website":"http://wordpress.org","version":"3.3.2","license":"gpl2+","description":"A
    semantic personal publishing platform written in PHP with a MySQL back end, focusing
    on aesthetics, web standards, and usability.","credentials":[{"username":"Admin","password":"OpenShiftAdmin"}]}'
  :descriptor: ! "---\nConnections:\n  mysql-5.1-php-5.3:\n    Components:\n    -
    php-5.3\n    - mysql-5.1\nDisplay-Name: wordpress-0.0-noarch\nName: wordpress\nRequires:\n-
    php-5.3\n- mysql-5.1\n"
