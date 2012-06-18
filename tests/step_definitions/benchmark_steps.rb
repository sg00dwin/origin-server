require 'rubygems'
require 'uri'
require 'fileutils'
require 'json'
require 'pty'
require 'benchmark'

include AppHelper
include GearHelper
include StatsHelper
include Benchmark

def create_user_and_domains(type, n, ngears=3)
  nfailures = 0
  apps = n.times.collect do
    app = TestApp.create_unique(type)
    begin
      register_user(app.login, app.password) if $registration_required
      rhc_create_domain(app)
      change_max_gears_for_user(app.login, ngears) if ngears > 3
    rescue Exception => ex
      $logger.error("Failure creating user/domain - #{ex.message}")
      nfailures += 1
    end
    app
  end

  return nfailures, apps
end


def destroy_app(app)
  begin
    rhc_ctl_destroy(app)
  rescue
  end
end


def create_and_scale_app(app, ngears)
  # Replace when the REST API libraries are complete
  outf = "/tmp/rhc/json_response_#{app.name}_#{app.namespace}.json"
  hdrs = "-H 'Accept: application/json' --user '#{app.login}:fakepw' -X POST"
  app_ns_uri = "https://localhost/broker/rest/domains/#{app.namespace}"
  cr_uri = "#{app_ns_uri}/applications"
  cr_params = "-d name=#{app.name} -d cartridge=#{app.type}"
  if ngears > 1
    cr_params << " -d scale=true"
  end

  command = "curl -k -s -o #{outf} -k #{hdrs} #{cr_uri} #{cr_params}"
  $logger.debug("Creating #{app.type} app - #{command}")
  app.create_app_code = runcon command, 'unconfined_u', 'unconfined_r', 'unconfined_t'
  if app.create_app_code != 0
    raise "Could not create app.  Exit code: #{app.create_app_code}.  Json debug: /tmp/rhc/json_response_#{app.name}_#{app.namespace}.json"
  end

  while ngears > 1 do
    ngears -= 1

    outf = "/tmp/rhc/json_response_scaleup_#{app.name}_#{app.namespace}.json"
    up_uri = "#{app_ns_uri}/applications/#{app.name}/events"
    up_params = "-d event=scale-up"

    command = "curl -k -s -o #{outf} #{hdrs} #{up_uri} #{up_params}"
    $logger.debug("Scaling up #{app.type} app - #{command}")
    exit_code = runcon command, 'unconfined_u', 'unconfined_r', 'unconfined_t'
    if exit_code != 0
       raise "Could not scale up application.  Exit code: #{exit_code}.  Json debug: /tmp/rhc/json_response_#{app.name}_#{app.namespace}.json"
    end
  end

  return app
end


def benchmark_app_creation(type, tag, zapps, repeat_n=1, ngears=1)
  measures = StatMeasures.new(type, tag, ngears)
  nfailed = 0
  idx = 0
  endidx = repeat_n * zapps.length

  $logger.debug("Benchmarking app creation [#{type} #{tag} #{ngears}] ...")

  repeat_n.times do
    zapps.each do |app|
      begin
        # Cleanup any previously created app if repeating 'n' times.
        destroy_app(app)

        # Benchmark 'elapsed' times for app creation.
        idx += 1
        elapsed = Benchmark.realtime do
          app = create_and_scale_app(app, ngears)
        end

        nfailed += 1  if app.create_app_code != 0
        measures.add(elapsed)

        pcntage = "%.2f" % ((idx * 100.0)/endidx)
        $logger.debug("Progress: #{pcntage}% - #{idx}/#{endidx} ...")
        $logger.debug("#{Time.now().to_f}, #{tag}, " + measures.raw)

      rescue Exception => ex
        nfailed += 1
        $logger.error("Failure creating app or timing it - #{ex.message}")
      end
    end
  end

  StatsReport.instance.addstats(measures)
  return nfailed
end


Before do
  @reportName = ''
end

After do |scenario|
  if scenario.name =~ /^Generate (.+) Benchmark Report/
    datarow_prefix = "#{Time.now().to_f}, #{@reportName}"
    File.open(File.join($temp, "benchmark.csv"), "a") do |f|
      f.write(StatsReport.instance.rawmetrics(datarow_prefix) )
    end
    StatsReport.instance.report(@reportName)
    StatsReport.instance.clear
  end
end

Then /^benchmark creating (.+) applications (\d+) times$/ do |type, n|
  ztag = "Application Creation"
  nfail, @zapps = create_user_and_domains(type, 1)
  if nfail > 0
    $logger.error("Failure creating user/domain")
  else
    nfail = benchmark_app_creation(type, ztag, @zapps, n.to_i)
    $logger.warn("#{nfail} failures creating applications!") if nfail > 0
  end
end

Then /^benchmark creating scaled (.+) applications with (\d+) gears (\d+) times/ do |type, gears, n|
  ztag = "Scaled Application Creation"
  nfail, @zapps = create_user_and_domains(type, 1, 20)
  if nfail > 0
    $logger.error("Failure creating user/domain")
  else
    nfail = benchmark_app_creation(type, ztag, @zapps, n.to_i, gears.to_i)
    $logger.warn("#{nfail} failures creating scaled applications!") if nfail > 0
  end
end

When /^finally cleanup all applications that the benchmark created/ do
  @zapps.each do |app|
    destroy_app(app)
  end
end

When /^generate the (.+) benchmark report/ do  |name|
   @reportName = name
   $logger.debug("Generating benchmark report - #{name} ...")
end

