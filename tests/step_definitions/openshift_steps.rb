Dir.glob(File.dirname(__FILE__) + "/../../controller/test/cucumber/step_definitions/*").each { |step_definition|
  require step_definition unless ["client_steps.rb"].include? File.basename(step_definition)
}
