#!/usr/bin/env ruby
require 'rubygems'
require 'yaml'
require 'tempfile'
require 'json'
require 'bson'

# This function compacts any hashes by promoting any keys with nil values
class Hash
  def compact
    new_hash = {}
    self.each do |k,v|
      case
      when v.respond_to?(:compact)
        new_hash[k] = v.compact
      when v.nil?
        new_hash = k
      else
        new_hash[k] = v
      end
    end
    new_hash
  end
end

# The converts an OMAP into a proper hash
module Enumerable
  def to_h
    inject({}) do |acc, element|
      k,v = element;
      acc[k] = case
               when v.is_a?(BSON::OrderedHash)
                 v.to_h
               when v.is_a?(YAML::Omap)
                 Hash[v.map do |key,val|
                   [key,val.is_a?(Enumerable) ? val.to_h : val]
                 end]
               else
                 v
               end
      acc
    end.compact
  end
end

templates = YAML.load(DATA)

templates.each do |name,opts|
  begin
    puts "Deploying #{name}"
    metadata_file = Tempfile.new('metadata')
    descriptor_file = Tempfile.new('descriptor')

    # Fix the OMAP hash
    opts = opts.to_h

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
    :descriptor: !omap 
      - Architecture: noarch
      - Cart-Data: !map:BSON::OrderedHash {}

      - Categories: 
        - cartridge
      - Connections: 
          mysql-5.1-php-5.3: 
            Components: 
            - php-5.3
            - mysql-5.1
      - Description: ""
      - Display-Name: drupal-0.0-noarch
      - Help-Topics: !map:BSON::OrderedHash {}

      - License: unknown
      - License-Url: ""
      - Name: drupal
      - Requires: 
        - php-5.3
        - mysql-5.1
      - Scaling: 
          Min: 1
          Max: -1
      - Vendor: unknown
      - Version: "0.0"
      - Website: ""
    :script: rhc-admin-ctl-template --command 'add' --cost '1' --git-url 'git://github.com/openshift/drupal-example.git' --named 'Drupal' --tags 'php,drupal,wiki,framework,experimental'
    :metadata: !omap 
      - :credentials: 
        - :username: Admin
          :password: OpenShiftAdmin
      - :description: An open source content management platform written in PHP powering millions of websites and applications. It is built, used, and supported by an active and diverse community of people around the world.
      - :git_project_url: http://github.com/openshift/drupal-example
      - :git_url: git://github.com/openshift/drupal-example.git
      - :license: :"gpl2+"
      - :version: 7.7
      - :website: http://drupal.org/
- kitchensink: 
    :descriptor: !omap 
      - Architecture: noarch
      - Cart-Data: !map:BSON::OrderedHash {}

      - Categories: 
        - cartridge
      - Description: ""
      - Display-Name: kitchensink-0.0-noarch
      - Help-Topics: !map:BSON::OrderedHash {}

      - License: unknown
      - License-Url: ""
      - Name: kitchensink
      - Requires: 
        - jbossas-7
      - Scaling: 
          Min: 1
          Max: -1
      - Vendor: unknown
      - Version: "0.0"
      - Website: ""
    :script: rhc-admin-ctl-template --command 'add' --cost '1' --git-url 'git://github.com/openshift/kitchensink-example.git' --named 'Kitchensink Example' --tags 'java,jboss,framework,experimental'
    :metadata: !omap 
      - :description: This quickstart uses JBoss AS7 to show off all the new features of Java EE 6 and makes a great starting point for your Java project.
      - :git_project_url: http://github.com/openshift/kitchensink-example
      - :git_url: git://github.com/openshift/kitchensink-example.git
      - :license: :apache2
      - :version: 7.0.0
      - :website: https://docs.jboss.org/author/display/AS71/Kitchensink+quickstart
- rails: 
    :descriptor: !omap 
      - Architecture: noarch
      - Cart-Data: !map:BSON::OrderedHash {}

      - Categories: 
        - cartridge
      - Connections: 
          mysql-5.1-ruby-1.9: 
            Components: 
            - ruby-1.9
            - mysql-5.1
      - Description: ""
      - Display-Name: rails-0.0-noarch
      - Help-Topics: !map:BSON::OrderedHash {}

      - License: unknown
      - License-Url: ""
      - Name: rails
      - Requires: 
        - ruby-1.9
        - mysql-5.1
      - Scaling: 
          Min: 1
          Max: -1
      - Vendor: unknown
      - Version: "0.0"
      - Website: ""
    :script: rhc-admin-ctl-template --command 'add' --cost '1' --git-url 'git://github.com/openshift/rails-example.git' --named 'Ruby on Rails' --tags 'ruby,rails,framework,experimental'
    :metadata: !omap 
      - :description: An open source web framework for Ruby that is optimized for programmer happiness and sustainable productivity. It lets you write beautiful code by favoring convention over configuration.
      - :git_project_url: http://github.com/openshift/rails-example
      - :git_url: git://github.com/openshift/rails-example.git
      - :license: :mit
      - :version: 3.2.6
      - :website: http://rubyonrails.org/
- railstest: 
    :descriptor: !omap 
      - Architecture: noarch
      - Cart-Data: !map:BSON::OrderedHash {}

      - Categories: 
        - cartridge
      - Connections: 
          mysql-5.1-ruby-1.9: 
            Components: 
            - ruby-1.9
            - mysql-5.1
      - Description: ""
      - Display-Name: railstest-0.0-noarch
      - Help-Topics: !map:BSON::OrderedHash {}

      - License: unknown
      - License-Url: ""
      - Name: railstest
      - Requires: 
        - ruby-1.9
        - mysql-5.1
      - Scaling: 
          Min: 1
          Max: -1
      - Vendor: unknown
      - Version: "0.0"
      - Website: ""
    :script: rhc-admin-ctl-template --command 'add' --cost '1' --git-url 'git://github.com/fotioslindiakos/rails-example.git' --named 'Ruby on Rails (TEST)' --tags 'ruby,rails,framework,experimental,in_development'
    :metadata: !omap 
      - :description: An open source web framework for Ruby that is optimized for programmer happiness and sustainable productivity. It lets you write beautiful code by favoring convention over configuration.
      - :git_project_url: http://github.com/fotioslindiakos/rails-example
      - :git_url: git://github.com/fotioslindiakos/rails-example.git
      - :license: :mit
      - :version: 3.2.6
      - :website: http://rubyonrails.org/
- springeap6: 
    :descriptor: !omap 
      - Architecture: noarch
      - Cart-Data: !map:BSON::OrderedHash {}

      - Categories: 
        - cartridge
      - Description: ""
      - Display-Name: springeap6-0.0-noarch
      - Help-Topics: !map:BSON::OrderedHash {}

      - License: unknown
      - License-Url: ""
      - Name: springeap6
      - Requires: 
        - jbosseap-6.0
      - Scaling: 
          Min: 1
          Max: -1
      - Vendor: unknown
      - Version: "0.0"
      - Website: ""
    :script: rhc-admin-ctl-template --command 'add' --cost '1' --git-url 'git://github.com/openshift/spring-eap6-quickstart.git' --named 'Spring Framework on JBoss EAP6' --tags 'java,jboss,framework,experimental'
    :metadata: !omap 
      - :description: This quickstart allows you to use Spring Framework on JBoss JBoss EAP 6.
      - :git_project_url: http://github.com/openshift/spring-eap6-quickstart
      - :git_url: git://github.com/openshift/spring-eap6-quickstart.git
      - :license: :apache2
      - :version: 3.1.1
      - :website: http://springframework.org/
- wordpress: 
    :descriptor: !omap 
      - Architecture: noarch
      - Cart-Data: !map:BSON::OrderedHash {}

      - Categories: 
        - cartridge
      - Connections: 
          mysql-5.1-php-5.3: 
            Components: 
            - php-5.3
            - mysql-5.1
      - Description: ""
      - Display-Name: wordpress-0.0-noarch
      - Help-Topics: !map:BSON::OrderedHash {}

      - License: unknown
      - License-Url: ""
      - Name: wordpress
      - Requires: 
        - php-5.3
        - mysql-5.1
      - Scaling: 
          Min: 1
          Max: -1
      - Vendor: unknown
      - Version: "0.0"
      - Website: ""
    :script: rhc-admin-ctl-template --command 'add' --cost '1' --git-url 'git://github.com/openshift/wordpress-example.git' --named 'WordPress' --tags 'php,wordpress,blog,framework,experimental'
    :metadata: !omap 
      - :credentials: 
        - :username: Admin
          :password: OpenShiftAdmin
      - :description: A semantic personal publishing platform written in PHP with a MySQL back end, focusing on aesthetics, web standards, and usability.
      - :git_project_url: http://github.com/openshift/wordpress-example
      - :git_url: git://github.com/openshift/wordpress-example.git
      - :license: :"gpl2+"
      - :version: 3.3.2
      - :website: http://wordpress.org
