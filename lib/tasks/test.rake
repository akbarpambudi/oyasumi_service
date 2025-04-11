require 'rspec/core/rake_task'

namespace :test do
  desc 'Run unit tests'
  task :unit do
    ENV['TEST_TYPE'] = 'unit'
    ENV['SKIP_DATABASE'] = 'true'
    system("rbenv exec bundle exec rspec spec/domain/")
  end

  desc 'Run integration tests'
  RSpec::Core::RakeTask.new(:integration) do |t|
    t.pattern = 'spec/{controllers,requests,infrastructure}/**/*_spec.rb'
    ENV['TEST_TYPE'] = 'integration'
    ENV['SKIP_DATABASE'] = 'false'
    ENV['RAILS_ENV'] = 'test'
    t.rspec_opts = '--format documentation'
  end

  desc 'Run end-to-end tests'
  task :e2e do
    ENV['TEST_TYPE'] = 'e2e'
    ENV['SKIP_DATABASE'] = 'false'
    ENV['RAILS_ENV'] = 'test'
    success = system("./bin/pretest")
    if success
      system("rbenv exec bundle exec rspec spec/e2e/")
    end
  end

  desc 'Run all tests'
  task :all do
    ENV['TEST_TYPE'] = 'all'
    ENV['SKIP_DATABASE'] = 'false'
    ENV['RAILS_ENV'] = 'test'
    success = system("./bin/pretest")
    if success
      system("rbenv exec bundle exec rspec spec/")
    end
  end

  desc 'Run tests with coverage report'
  task :coverage do
    ENV['COVERAGE'] = 'true'
    Rake::Task['test:all'].invoke
  end

  namespace :coverage do
    desc 'Run unit tests with coverage'
    task :unit do
      ENV['TEST_TYPE'] = 'unit'
      ENV['SKIP_DATABASE'] = 'true'
      ENV['COVERAGE'] = 'true'
      system("rbenv exec bundle exec rspec spec/domain/")
    end

    desc 'Run integration tests with coverage'
    task :integration do
      ENV['TEST_TYPE'] = 'integration'
      ENV['SKIP_DATABASE'] = 'false'
      ENV['COVERAGE'] = 'true'
      ENV['RAILS_ENV'] = 'test'
      success = system("./bin/pretest")
      if success
        system("rbenv exec bundle exec rspec spec/controllers/ spec/requests/ spec/infrastructure/")
      end
    end

    desc 'Run e2e tests with coverage'
    task :e2e do
      ENV['TEST_TYPE'] = 'e2e'
      ENV['SKIP_DATABASE'] = 'false'
      ENV['COVERAGE'] = 'true'
      ENV['RAILS_ENV'] = 'test'
      success = system("./bin/pretest")
      if success
        system("rbenv exec bundle exec rspec spec/e2e/")
      end
    end
  end

  namespace :fast do
    desc 'Run unit tests without coverage'
    task :unit do
      ENV['TEST_TYPE'] = 'unit'
      ENV['SKIP_DATABASE'] = 'true'
      ENV['COVERAGE'] = 'false'
      system("rbenv exec bundle exec rspec spec/domain/")
    end

    desc 'Run integration tests without coverage'
    task :integration do
      ENV['TEST_TYPE'] = 'integration'
      ENV['SKIP_DATABASE'] = 'false'
      ENV['COVERAGE'] = 'false'
      ENV['RAILS_ENV'] = 'test'
      success = system("./bin/pretest")
      if success
        system("rbenv exec bundle exec rspec spec/controllers/ spec/requests/ spec/infrastructure/")
      end
    end
  end
end

# Set default test task
task :test => 'test:all' 