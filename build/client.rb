namespace :client do
  desc "Build the client tools gem"
  task :gem do
      cd CLIENT_ROOT

      # Package the gem
      sh "rake", "package"

      puts "The packaged gem now exists in client/pkg/li-*.gem"
      puts "Copy the gem to the <SERVER>:/var/www/html/client directory"
      puts "and run 'gem generate_index -b /var/www/html/client'"
  end
end
