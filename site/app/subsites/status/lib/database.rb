require 'rubygems'
require 'active_record'
require 'sqlite3'

# Need to discover the paths so we can use the same configs inside Rails
cur_path = File.expand_path(File.dirname(__FILE__))
config_path = File.join(cur_path,%w[.. config database.yml])

db_config = YAML.load(File.read(config_path))

# Need to force the whole path so Rails doesn't try a path relative to Rails.root
db_config['database'] = File.join(cur_path,'..',db_config['database'])

ActiveRecord::Base.establish_connection(db_config)
