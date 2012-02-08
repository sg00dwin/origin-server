require 'rubygems'
require 'sinatra/base'
require 'dm-core'
require 'dm-validations'
require 'dm-migrations'
require 'dm-timestamps'
require 'haml'

MY_ROOT = File.expand_path(File.dirname(__FILE__))
require File.join(MY_ROOT,'model')

class StatusApp < Sinatra::Base
  configure do
   # DataMapper::Logger.new(STDOUT, :debug)
    DataMapper.setup(:default,sprintf("sqlite://%s/status_app.db", File.join(MY_ROOT,'db')))
    DataMapper.finalize
    DataMapper.auto_upgrade!

    set :views, File.join(MY_ROOT,'views')
  end

  get '/' do
    @open = Issue.open
    @resolved = Issue.resolved & Issue.year
    haml :index
  end

  helpers do
    def header
      case @open.length
      when 0
        {
          :class => '',
          :message => 'No known issues',
          :short => 'OK'
        }
      when 1
        {
          :class => 'error',
          :message => '1 known issue',
          :short => '1'
        }
      else
        {
          :class => 'error',
          :message => "#{@open.length} known issues",
          :short => @open.length
        }
      end
    end
  end
end
