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
  exclude= "log/**, tmp/**, httpd/**",
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

sync{ rails, default.rsync,
  source= sourcedir .. "/broker",
  target= "verifier:/var/www/stickshift/broker",
}

sync { rpm, default.rsync,
  source= sourcedir .. "/server-common",
  target= "verifier:/usr/lib/ruby/site_ruby/1.8",
}

drupal_modules = {
  ['theme/openshift-theme']       = 'themes/openshift-theme',
  ['redhat_sso/redhat_sso']  = 'modules/custom/redhat_sso',
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

