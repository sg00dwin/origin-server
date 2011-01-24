#
# = libra.rb: Facter integration for li
#
# Author:: Mike McGrath
# 
# Copyright © 2010 Mike McGrath All rights reserved
# Copyright © 2010 Red Hat, Inc. All rights reserved

# This copyrighted material is made available to anyone wishing to use, modify,
# copy, or redistribute it subject to the terms and conditions of the GNU
# General Public License v.2.  This program is distributed in the hope that it
# will be useful, but WITHOUT ANY WARRANTY expressed or implied, including the
# implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.  You should have
# received a copy of the GNU General Public License along with this program;
# if not, write to the Free Software Foundation, Inc., 51 Franklin Street,
# Fifth Floor, Boston, MA 02110-1301, USA. Any Red Hat trademarks that are
# incorporated in the source code or documentation are not subject to the GNU
# General Public License and may only be used or replicated with the express
# permission of Red Hat, Inc.
#
# == Description
# 
# libra.rb for facter adds several additional li related facts which can then
# be queried by facter (and mcollective).  Examples include the number of git
# repositories on the host, customer information, etc.


#
# Count the number of git repos on this host
#
Facter.add(:git_repos) do
    setcode { Dir.glob("/var/lib/libra/*/git/*.git").count }
end


#
# Lists customers on the host as well as what what git repos they currently own
#
if File.exists?("/var/lib/libra")
    # Determine customers on host and hosted info
    Dir.entries('/var/lib/libra/').each do |customer|
    
        if customer =~ /[A-Za-z0-9]/
            Facter.add("customer_#{customer}") do
                setcode do customer end
            end
        end

        if File.exists?("/var/lib/libra/#{customer}/git/")
            git_repos = Dir.glob("/var/lib/libra/#{customer}/git/*.git")
            Facter.add("git_#{customer}") do
                setcode do git_repos.join(',') end
            end
        end
    end
end

