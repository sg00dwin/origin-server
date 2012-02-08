#!/usr/bin/env ruby

$: << File.expand_path(File.dirname(__FILE__))

require 'rubygems'
require 'thor'
require 'status_app'

class UpdateStatusCli < Thor
  include Thor::Actions

  no_tasks do
    def say_errors(model, msg=nil)
      unless msg.nil?
        say msg
      end
      model.errors.each {|t| say t }
    end
  end

  desc "new TITLE DESCRIPTION", "Start a new issue"
  def new(title,description)
    issue = Issue.new :title => title
    if issue.save
      say "Created issue \##{issue.id}"
      update(issue.id, description)
    else
      say_errors issue, "Unable to create issue"
    end
  end

  desc "update ISSUE_ID DESCRIPTION", "Add an update to an issue without resolving it"
  def update(issue_id, description)
    issue = Issue.get issue_id
    if issue.nil?
      say "Issue #{issue_id} does not exist"
    else
      update = issue.updates.new :description => description
      if update.save
        say "Update applied to issue \##{issue_id}"
      else
        say_errors update, "Unable to update issue"
      end
    end
  end

  desc "resolve ISSUE_ID DESCRIPTION", "Resolve an issue with a final update. Description is required."
  def resolve(issue_id, description)
    issue = Issue.get issue_id
    if issue.nil?
      say "Issue #{issue_id} does not exist"
    else
      update = issue.updates.new :description => description
      if update.save
        say "Update applied to issue \##{issue_id}"
        if issue.resolve
          say "Resolved issue \##{issue_id}"
        else
          say_errors issue, "Unable to resolve issue"
        end
      else
        say_errors update
      end
    end
  end
end

UpdateStatusCli.start
