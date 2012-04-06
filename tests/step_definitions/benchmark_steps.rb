require 'rubygems'
require 'uri'
require 'fileutils'
require 'json'
require 'pty'
require 'benchmark'

include AppHelper
include StatsHelper
include Benchmark

def create_user_and_domains(type, n)
  nfailures = 0
  apps = n.times.collect do
    app = TestApp.create_unique(type)
    begin
      register_user(app.login, app.password) if $registration_required
      rhc_create_domain(app)
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


def benchmark_app_creation(type, tag, zapps, repeat_n)
  measures = StatMeasures.new(type, tag)
  app_options = '--no-dns --nogit'
  nfailed = 0
  idx = 0
  endidx = repeat_n * zapps.length

  $logger.debug("Benchmarking app creation [#{type} #{tag}] ...")

  repeat_n.times do
    zapps.each do |app|
      begin
        # Cleanup any previously created app if repeating 'n' times.
        destroy_app(app)

        # Benchmark 'elapsed' times for app creation.
        idx += 1
        elapsed = Benchmark.realtime do
          app = rhc_create_app(app, true, app_options)
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
 
Then /^benchmark creating (.+) applications (\d+) times/ do |type, n|
  ztag = "Application Creation"
  nfail, @zapps = create_user_and_domains(type, 1)
  if nfail > 0
    $logger.error("Failure creating user/domain")
  else
    nfail = benchmark_app_creation(type, ztag, @zapps, n.to_i)
    $logger.warn("#{nfail} failures creating applications!") if nfail > 0
  end
end
 
Then /^benchmark creating (.+) applications monotonically with (\d+) samples/ do |type, n|
  ztag = "Monotonically Creating Applications"
  nfail, @zapps = create_user_and_domains(type, n.to_i)
  $logger.warn("#{nfail} failures creating users/domains!") if nfail > 0

  nfail = benchmark_app_creation(type, ztag, @zapps, 1)
  $logger.warn("#{nfail} failures creating applications!") if nfail > 0
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

