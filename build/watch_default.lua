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
default_delay = 0.2
rails = {
  delay= default_delay,
  rsyncOps= rsync_defaults,
  exclude= "log/**, tmp/**, httpd/**",
}
rpm = {
  delay= default_delay,
  rsyncOps= rsync_defaults,
  exclude= "*.spec",
}

-- Actual sync definitions

sync{ default.rsync, rails,
  source= sourcedir .. "/site",
  target= "verifier:/var/www/stickshift/site",
}

sync{ default.rsync, rails,
  source= sourcedir .. "/broker",
  target= "verifier:/var/www/stickshift/broker",
}

sync { default.rsync, rpm,
  source= sourcedir .. "/server-common",
  target= "verifier:/usr/lib/ruby/site_ruby/1.8",
}

drupal_modules = {
  ['theme']       = 'themes/openshift-theme',
  ['redhat_sso']  = 'modules/custom/redhat_sso',
}
for source, destination in pairs(drupal_modules) do
  sync{ default.rsync, rpm,
    source= sourcedir .. "/drupal/drupal6-openshift-" .. source,
    target= "verifier:/etc/drupal6/all/" .. destination,
  }
end

sync{ default.rsync, rpm,
  source= sourcedir .. "/misc/devenv/etc/drupal6",
  target= "verifier:/etc/drupal6"
}

