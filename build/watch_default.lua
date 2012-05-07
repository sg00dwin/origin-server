sourcedir = "{LOCAL_DIR}"

--- Override to prevent --delete from being passed to rsync startup

default.rsync.init = function(inlet)
  local config = inlet.getConfig()
  local event = inlet.createBlanketEvent()
  event.isStartup = true -- marker for user scripts 
    
  if string.sub(config.target, -1) ~= "/" then
    config.target = config.target .. "/"
  end

  local excludes = inlet.getExcludes();
  if #excludes == 0 then
    log("Normal", "recursive startup rsync: ", config.source,
      " -> ", config.target)
    spawn(event, "/usr/bin/rsync",              
          -- "--delete", Don't call delete during startup
          config.rsyncOps, "-r", 
          config.source, 
          config.target)
  else
    local exS = table.concat(excludes, "\n")
    log("Normal", "recursive startup rsync: ", config.source,
        " -> ", config.target, " excluding\n", exS)
    spawn(event, "/usr/bin/rsync",
      "<", exS,
      "--exclude-from=-",
      -- "--delete", Don't call delete during startup
      config.rsyncOps, "-r",
      config.source,
      config.target)
  end
end

settings = {
  nodaemon = true,
}

rsync_defaults = {"-vuzt", "--chmod=ug+rwX"}
rails = {
  delay= 0.2,
  rsyncOps= rsync_defaults,
  exclude= {"log", "tmp", "httpd"},
}
rpm = {
  delay= 0.2,
  rsyncOps= rsync_defaults,
  exclude= "*.spec",
}

-- Actual sync definitions

sync{ rails, default.rsync,
  source= sourcedir .. "/site",
  target= "verifier:/var/www/stickshift/site",
}

sync { rpm, default.rsync,
  source= sourcedir .. "/server-common",
  target= "verifier:/usr/lib/ruby/site_ruby/1.8",
}

drupal_modules = {
  ['custom_forms']  = 'modules/custom/custom_forms',
  ['features-blogs']  = 'modules/features/blogs',
  ['features-community_wiki']  = 'modules/features/community_wiki',
  ['features-forums']  = 'modules/features/forums',
  ['features-front_page']  = 'modules/features/front_page',
  ['features-global_settings']  = 'modules/features/global_settings',
  ['features-recent_activity_report']  = 'modules/features/recent_activity_report',
  ['features-reporting_csv_views']  = 'modules/features/reporting_csv_views',
  ['features-rules_by_category']  = 'modules/features/rules_by_category',
  ['features-user_profile']  = 'modules/features/user_profile',
  ['features-video']  = 'modules/features/video',
  ['modals']  = 'modules/custom/modals',
  ['og_comment_perms']  = 'modules/custom/og_comment_perms',
  ['redhat_acquia']  = 'modules/custom/redhat_acquia',
  ['redhat_frontpage']  = 'modules/custom/redhat_frontpage',
  ['redhat_events']  = 'modules/custom/redhat_events',
  ['redhat_ideas']  = 'modules/custom/redhat_ideas',
  ['redhat_sso']  = 'modules/custom/redhat_sso',
  ['theme']       = 'themes/openshift-theme',
}
for source, destination in pairs(drupal_modules) do
  sync{ rpm, default.rsync,
    source= sourcedir .. "/drupal/drupal6-openshift-" .. source,
    target= "verifier:/etc/drupal6/all/" .. destination,
  }
end

sync{ rpm, default.rsync,
  source= sourcedir .. "/misc/devenv/etc/drupal6",
  target= "verifier:/etc/drupal6"
}

sync{ rpm, default.rsync,
  source= sourcedir .. "/misc/devenv/etc/httpd",
  target= "verifier:/etc/httpd"
}
