require 'logger'
require 'fileutils'

module MyLogger
  def initialize(dir = nil)
    @@logdir = make_logdir(dir)
  end

  def loggers
    @@loggers ||= make_loggers
  end

  def make_logdir(path = '')
    path = File.join('log',path)
    FileUtils.mkdir_p path
    path
  end

  def logdir
    @@logdir ||= make_logdir
  end

  def log(msg = "", sev = Logger::DEBUG)
    loggers.each{|x| x.add(sev){msg}}
  end

  def puts(msg = '')
    log(msg,Logger::INFO)
  end

  def debug(msg = '')
    log(msg,Logger::DEBUG)
  end

  def logfile(name = 'log')
    File.join(logdir,"#{name}.log")
  end

  def make_loggers
    s_logger = new_logger(STDOUT)
    s_logger.formatter = proc do |severity, datetime, progname, msg|
      "#{msg}\n"
    end

    f_logger = new_logger(logfile('profile'))
    f_logger.formatter = proc do |severity, datetime, progname, msg|
      "#{datetime}: #{msg}\n"
    end

    d_logger = new_logger(logfile('debug'),Logger::DEBUG)

    [s_logger,f_logger,d_logger]
  end

  def new_logger(out,level = Logger::INFO)
    logger = Logger.new(out)
    logger.sev_threshold = level
    logger
  end
end
