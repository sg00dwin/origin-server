#!/usr/bin/env ruby

require 'rubygems'
gem 'ruby-mysql'
require 'mysql'
require 'securerandom'

db = Mysql.real_connect('localhost', 'root', nil, 'libra', nil, '/var/lib/mysql/mysql.sock')

def update(body)
  body.
    gsub(%r(www\.redhat\.com/openshift/community)i, 'www.openshift.com').
    gsub(%r(openshift\.redhat\.com/community)i, 'www.openshift.com').
    gsub(%r|([\(\[\s\"\'])/app/|i, '\1https://openshift.redhat.com/app/').
    gsub(%r|([\(\[\s\"\'])/community/|i, '\1/').
    gsub(%r|http(s?)\://openshift\.redhat\.com/app/opensource/download|i, '/open-source').
    gsub(%r|http(s?)\://openshift\.redhat\.com/app/getting_started|i, '/get-started').
    gsub(%r|\brhc\s+app\s+cartridge\b|, 'rhc cartridge').
    gsub(%r#\brhc\s+app\s+create\s+-a\s+([\w\-\.]+)\s+-[tc]\s+([\w\-\.]+)\b#, 'rhc app create \1 \2').
    gsub(%r#\brhc\s+cartridge\s+(add|restart|reload|status|stop|start)\s+-a\s+([\w\-\.]+)\s+-[tc]\s+([\w\-\.]+)\b#, 'rhc cartridge \1 \3 -a \2').
    gsub(%r#\brhc\s+cartridge\s+(add|restart|reload|status|stop|start)\s+-[tc]\s+([\w\-\.]+)\b#, 'rhc cartridge \1 \2')
end

nodes, comments = 0, 0
r = db.query "SELECT vid,body,title,nid FROM node_revisions;"
r.each do |row|
  vid, body, title, nid = row
  new_body = update(body)
  if new_body != body
    #puts "----\n#{new_body}\n"
    if db.prepare("update node_revisions set body = ? where vid = ?;").execute(new_body, vid).affected_rows < 1
      puts "FAILED: Unable to update node #{vid}"
      exit
    end
    db.prepare("update node set changed = ? where nid = ?;").execute(Time.now.utc.to_i, nid)
    nodes += 1
    #puts "CHANGED: #{title}"
  end
end

r = db.query "SELECT cid,comment,nid FROM comments;"
r.each do |row|
  cid, body, nid = row
  new_body = update(body)
  if new_body != body
    if db.prepare("update comments set comment = ? where cid = ?;").execute(new_body, cid).affected_rows < 1
      puts "FAILED: Unable to update node #{cid}"
      exit
    end
    db.prepare("update node set changed = ? where nid = ?;").execute(Time.now.utc.to_i, nid)
    #nodes += 1
    #puts "----\n#{new_body}\n"
    #puts "CHANGED: #{cid}"
    comments += 1
  end
end

puts "DONE: #{nodes} nodes and #{comments} comments changed."
