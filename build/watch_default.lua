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

sync{
  default.rsync,
  delay= 0.2,
  source= sourcedir .. "/site",
  target= "verifier:/var/www/stickshift/site",
  rsyncOps={"-vuzt", "--chmod=ug+rwX"},
  exclude= "site/log/**, site/tmp/**, site/httpd/**",
}

sync{
  default.rsync,
  delay= 0.2,
  source= sourcedir .. "/broker",
  target= "verifier:/var/www/stickshift/broker",
  rsyncOps={"-vuzt", "--chmod=ug+rwX"},
  exclude= "broker/log/**, broker/tmp/**, broker/httpd/**"
}

sync{
  default.rsync,
  delay= 0.2,
  source= sourcedir .. "/server-common",
  target= "verifier:/usr/lib/ruby/site_ruby/1.8",
  rsyncOps={"-vuzt", "--chmod=ug+rwX"},
  exclude= "*.spec"
}
