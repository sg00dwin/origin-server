namespace :assets do
  #
  # The OpenShift build process generates stylesheets and javascript into the public
  # directory so it can be served as static content.  Passenger will serve this content
  # when requests for /stylesheets/* are retrieved.  In order to perform autogeneration
  # of CSS/JS content you must run this task on your dev environment.
  #
  task :clean do
    puts "Remove built stylesheets..."
    source = Pathname.new "#{Rails.root}/app/stylesheets"
    dest = Pathname.new "#{Rails.root}/public/stylesheets"
    Dir["#{source}/**/*.scss"].map{ |p| Pathname.new(p) }.each do |p|
      path = dest.join(p.relative_path_from(source)).to_s.gsub(/\.scss$/i,'.css')
      if File.exists?(path)
        puts "  #{path}"
        File.delete(path)
      end
    end

    puts "Remove built JavaScript..."
    source = Pathname.new "#{Rails.root}/app/coffeescripts"
    dest = Pathname.new "#{Rails.root}/public/javascripts"
    Dir["#{source}/**/*.coffee"].map{ |p| Pathname.new(p) }.each do |p|
      path = dest.join(p.relative_path_from(source)).to_s.gsub(/\.coffee$/i,'.js')
      if File.exists?(path)
        puts "  #{path}"
        File.delete(path)
      end
    end
  end
end
