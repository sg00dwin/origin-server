require 'pp'

Given /^existing servers with git repositories$/ do
  # Just test a client call for right now
  @rpc_facts.get_fact(:fact => 'git_repos')
end
