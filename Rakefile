require "rake"
require "rspec/core/rake_task"
require "yard-ghpages"

Dir.glob(File.join("tasks/**/*.rake")).each { |f| load f }

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = Dir.glob("spec/**/*_spec.rb")
  t.rspec_opts = "--format doc"
end

Yard::GHPages::Tasks.install_tasks
