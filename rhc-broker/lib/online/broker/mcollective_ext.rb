require File.expand_path('./nurture', File.dirname(__FILE__))

module OpenShift
  class MCollectiveApplicationContainerProxy < OpenShift::ApplicationContainerProxy
    alias :run_cartridge_command_old :run_cartridge_command

    def run_cartridge_command(framework, gear, command, arg=nil, allow_move=true)
      if allow_move
        app = gear.app
        Online::Broker::Nurture.application(app.domain.owner.login, app.domain.owner._id, app.name, app.domain.namespace, framework, command, app._id.to_s, app.user_agent, app.init_git_url)
      end
      run_cartridge_command_old(framework, gear, command, arg, allow_move)
    end

    class << self
      alias_method :blacklisted_in_impl_old?, :blacklisted_in_impl?
    end

    def self.blacklisted_in_impl?(name)
      OpenShift::Blacklist.in_blacklist?(name)
    end

    def self.get_blacklisted_in_impl
      OpenShift::Blacklist.blacklist
    end

    def self.max_user_domains_impl(user)
      if user.plan_id.nil? || user.plan_id == 'free' 
        1
      else
        super
      end
    end
  end
end

#
# Relocated from server-common.
#
module OpenShift
  module Blacklist

    NONO = %w(amentra aop apiviz arquillian blacktie boxgrinder byteman cirras
            cloud cloudforms cygwin davcache dogtag drools drools ejb3 errai
            esb fedora freeipa gatein git gfs gravel guvnor hibernate hornetq iiop
            infinispan ironjacamar javassist jbcaa jbcd jboss jbpm jdcom jgroups
            jmx jopr jrunit jsfunit kosmos liberation makara mass maven metajizer
            metamatrix mobicents mod_cluster modeshape mugshot mysql netty openshift
            osgi overlord ovirt penrose picketbox picketlink portletbridge portletswap
            posse pressgang qumranet railo redhat resteasy rhca rhcds rhce
            rhcsa rhcss rhct rhcva rhel rhev rhq rhx richfaces riftsaw savara scribble
            seam shadowman shotoku shrinkwrap snowdrop solidice spacewalk spice
            steamcannon stormgrind switchyard tattletale teiid tohu torquebox weld
            wise xnio
    )

    def self.blacklist
      NONO
    end

    def self.in_blacklist?(field)
      NONO.include?(field.to_str.downcase)
    end
    
  end
end

