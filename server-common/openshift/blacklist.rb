
module OpenShift
  module Blacklist

    NONO = %w(amentra aop apiviz arquillian blacktie boxgrinder byteman cirras
            cloud cloudforms cygwin davcache dogtag drools drools ejb3 errai
            esb fedora freeipa gatein gfs gravel guvnor hibernate hornetq iiop
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
