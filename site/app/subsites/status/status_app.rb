require 'sinatra/base'
require 'haml'
require 'json'
require 'uri'

require 'models'
require 'database'
require 'helpers'

class StatusApp < Sinatra::Base
  configure do
    set :views, File.join(STATUS_APP_ROOT,'views')
    set :synced, false
    set :sessions, false
  end

  before do
    _log("Handing request")
    @base = URI.parse(request.path_info).path.split('/')[0..-2].join('/')
    if !settings.synced && Issue.all.empty?
      _log("Not synced")
      sync(sprintf(STATUS_APP_HOSTS[:template],STATUS_APP_HOSTS[:host]))
    end
  end
  
  get '*/status' do
    @open = Issue.is_open
    @resolved = Issue.resolved.merge(Issue.year)
    haml :index
  end

  get '*/status/current.json' do
    content_type :json
    { :issues => Issue.all, :updates => Update.all }.to_json 
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

  helpers do
    include Rack::Utils

    # copied from ActionView::Helpers::JavascriptHelper
    JS_ESCAPE_MAP = {
      '\\' => '\\\\',
      '</' => '<\/',
      "\r\n" => '\n',
      "\n" => '\n',
      "\r" => '\n',
      '"' => '\\"',
      "'" => "\\'"
    }

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

            Issue.delete_all
            Update.delete_all

            string = "update sqlite_sequence set seq = 0 where name = '%s'"
            ActiveRecord::Base.connection.execute(sprintf(string,'issues'))
            ActiveRecord::Base.connection.execute(sprintf(string,'updates'))

            data['issues'].each do |val| 
              issue = val['issue']
              Issue.create issue
            end
            data['updates'].each do |val| 
              update = val['update']
              Update.create update
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
