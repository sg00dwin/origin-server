#
# Create db:test:prepare task so that we don't execute actual mongo_mapper task 
# which is trying to connect to 'test' db in mongo and this will fail due to incorrect credentials.
#
namespace :db do
  namespace :test do
    task :prepare do
      # ignore
    end
  end
end
