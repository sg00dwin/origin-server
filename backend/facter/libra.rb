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

# Count number of git repos on host

if File.exists?("/var/lib/libra")
    Facter.add(:git_repos) do
        setcode do
            %x[/bin/ls /var/lib/libra/*/git/ -d | /usr/bin/wc -l].chomp
        end
    end


    # Determine customers on host and hosted info
    customers = Dir.entries('/var/lib/libra/')
    
    customers.each do |customer|
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

