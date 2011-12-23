module OpenShift
  module Util
    
    # Invalid chars (") ($) (^) (<) (>) (|) (%) (/) (;) (:) (,) (\) (*) (=) (~)
    def self.check_rhlogin(rhlogin)
      if rhlogin =~ /["\$\^<>\|%\/;:,\\\*=~]/
        return false
      else
        return true
      end
    end

  end
end
