require 'pp'

Given /^existing servers with git repositories$/ do
  pp @rpc_facts.get_fact(:fact => 'git_repos')
end
