require 'sinatra/base'
require 'haml'
require 'json'
require 'uri'

require 'models'
require 'database'
require 'helpers'

require 'active_support/core_ext/string/encoding'
require 'active_support/core_ext/string/output_safety'

class StatusApp < Sinatra::Base
  configure do
    set :views, File.join(STATUS_APP_ROOT,'views')
    set :synced, false
    set :sessions, false
  end

  before do
    @base = URI.parse(request.path_info).path.split('/')[0..-2].join('/')
    if !settings.synced && Issue.all.empty?
      _log("Not synced")
      sync(sprintf(STATUS_APP_HOSTS[:template],STATUS_APP_HOSTS[:host]))
    end
  end

  module IgnoredCookies
    def write(headers)
      logger = defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
      logger.debug "  Cookies are disabled for this request by StatusApp::IgnoredCookies"
    end
  end

  after do
    #
    # Rails aggressively sets cookies even when the content is publicly cached.  To prevent 
    # cookies from being set by the status app while it is mounted inside 
    #
    if jar = env['action_dispatch.cookies']
      jar.extend(IgnoredCookies) rescue _log("Cookies could not be protected from being written")
    end
  end

  get '*/status' do
    @open = Issue.is_open
    @resolved = Issue.resolved.merge(Issue.year)
    haml :index
  end
  
  get '*/status/status.json' do
    content_type :json
    { :open => Issue.is_open.includes(:updates), :resolved => Issue.resolved.includes(:updates).limit(5) }.to_json(:include => :updates)
  end

  get '*/status/current.json' do
    content_type :json
    dump_json
  end

  get '*/status/sync/?' do
    redirect "*/status/sync/#{STATUS_APP_HOSTS[:host]}"
  end

  get '*/status/sync/:server' do
    server = params[:server]
    _log "Syncing to #{server}"
    sync(sprintf(STATUS_APP_HOSTS[:template],server))
    redirect '*/status'
  end

  get '*/status/status.js' do
    @open = Issue.is_open
    status = header
    content_type 'text/javascript'
    expires 60*5, :public
    if params[:id].present?
      if params[:always] or @open.present?
        :javascript
        <<-EOS
          var el = document.getElementById('#{escape_javascript(params[:id])}');
          if (el) {
            el.innerHTML = '#{escape_javascript(status[:message])}';
            el.className += ' #{escape_javascript(status[:class])}';
            el.style.display = '';
          }
        EOS
      end
    else
      :javascript
      <<-EOS 
        var div = "                               \
          <div class='status #{status[:class]}'>  \
            <a href='/app/status'>                \
      #{status[:message]}                 \
            </a> \
          </div>" ;
        div = div.replace(/^\s+|\s+$/g, '');
        div = div.replace(/\s+/g, ' ');
        document.write(div);
      EOS
    end
  end

  # copied from ActionView::Helpers::JavascriptHelper
  JS_ESCAPE_MAP = {
    '\\' => '\\\\',
    '</' => '<\/',
    "\r\n" => '\n',
    "\n" => '\n',
    "\r" => '\n',
    '"' => '\\"',
    "'" => "\\'"
  } unless defined? JS_ESCAPE_MAP #unattractive trap for redefinition

  helpers do
    include Rack::Utils

    if "ruby".encoding_aware?
      JS_ESCAPE_MAP["\342\200\250".force_encoding('UTF-8').encode!] = '&#x2028;'
    else
      JS_ESCAPE_MAP["\342\200\250"] = '&#x2028;'
    end
    def escape_javascript(javascript)
      if javascript
        result = javascript.gsub(/(\\|<\/|\r\n|\342\200\250|[\n\r"'])/u) {|match| JS_ESCAPE_MAP[match] }
        javascript.html_safe? ? result.html_safe : result
      else
        ''
      end
    end

    def header
      case @open.length
      when 0
        {
          :class => '',
          :message => 'No open issues',
          :short => 'OK'
        }
      when 1
        {
          :class => 'error',
          :message => '1 open issue',
          :short => '1'
        }
      else
        {
          :class => 'error',
          :message => "#{@open.length} open issues",
          :short => @open.length
        }
      end
    end
    
    def sync(host)
      uri = "#{host}/current.json"
      _log "Syncing to #{uri}"  

      http_req(uri) do |resp|
        case resp
        when Net::HTTPSuccess
          begin
            data = JSON.parse(resp.body)

            if data['issues'].empty?
              _log "Server responded with no issues, refusing to sync"
            else
              # Overwrite the current database
              overwrite_db(data)
            end
            settings.synced = true
          rescue JSON::ParserError
            _log "Site not responding to status request"
          end
        else
          _log("Did not succeed: #{resp}")
        end
      end

      _log "Done syncing"
    end
  end
end
