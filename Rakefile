# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"
require 'fileutils'

# Remove default test task
Rake::Task['test'].clear

# Load our custom test tasks
load 'lib/tasks/test.rake'

Rails.application.load_tasks

namespace :dev do
  desc "Setup development environment"
  task :setup => :environment do
    puts "🚀 Starting Good Night development environment setup..."

    # Check for required dependencies
    puts "🔍 Checking dependencies..."
    check_dependencies

    # Start services
    puts "🐳 Starting services..."
    system("docker-compose -f docker-compose-dev.yml up -d db redis")

    # Wait for PostgreSQL
    puts "⏳ Waiting for PostgreSQL to be ready..."
    wait_for_postgres

    # Setup database
    puts "💾 Setting up database..."
    unless system("bundle exec rails db:create") &&
           system("bundle exec rails db:migrate") &&
           system("bundle exec rails runner 'ActiveRecord::Base.connection.execute(\"CREATE SCHEMA IF NOT EXISTS cable\")'")
      puts "❌ Failed to setup database"
      exit 1
    end

    # Create .env file if it doesn't exist
    create_env_file unless File.exist?('.env')

    puts "✅ Setup completed successfully!"
    puts "📝 Please check .env file for configuration"
    puts "🚀 Start the server with: bundle exec rails server"
    puts "🧪 Run tests with: bundle exec rspec"
  end

  desc "Stop development environment"
  task :stop => :environment do
    puts "🛑 Stopping Good Night development environment..."
    system("docker-compose -f docker-compose-dev.yml down")
    puts "✅ Teardown completed successfully!"
  end

  desc "Stop development environment and remove volumes"
  task :clean => :environment do
    puts "🧹 Stopping and cleaning Good Night development environment..."
    system("docker-compose -f docker-compose-dev.yml down -v")
    puts "✅ Cleanup completed successfully!"
  end

  private

  def check_dependencies
    %w[docker docker-compose ruby bundle].each do |cmd|
      unless system("which #{cmd} > /dev/null 2>&1")
        puts "❌ #{cmd.capitalize} is required but not installed. Please install #{cmd} first."
        exit 1
      end
    end
  end

  def wait_for_postgres
    loop do
      break if system("docker-compose -f docker-compose-dev.yml exec db pg_isready -h localhost -p 5432 -U dev_app")
      puts "⏳ Waiting for PostgreSQL..."
      sleep 2
    end
  end

  def create_env_file
    puts "📝 Creating .env file..."
    File.write('.env', <<~EOL)
      DATABASE_URL=postgres://dev_app:dev_secret@localhost:5432/good_night_dev
      REDIS_URL=redis://localhost:6379/0
      JWT_SECRET_KEY=#{SecureRandom.hex(32)}
    EOL
  end
end

namespace :server do
  desc "Deploy the application"
  task :deploy do
    puts "Starting server deployment..."
    
    # Load environment variables
    puts "Loading environment variables..."
    if File.exist?('.env.production')
      File.readlines('.env.production').each do |line|
        next if line.strip.empty? || line.start_with?('#')
        key, value = line.split('=', 2)
        ENV[key.strip] = value.strip if key && value
      end
    else
      puts "❌ .env.production file not found"
      exit 1
    end
    
    # Stop existing containers
    puts "Stopping existing containers..."
    system("docker compose down -v")
    
    # Build services
    puts "Building services..."
    system("docker compose build")
    
    # Start services
    puts "Starting services..."
    system("docker compose up -d db redis")
    
    # Wait for PostgreSQL
    puts "Waiting for PostgreSQL..."
    max_attempts = 30
    attempt = 1
    while attempt <= max_attempts
      if system("docker compose exec db pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}")
        puts "db:5432 - accepting connections"
        break
      end
      puts "⏳ Waiting for PostgreSQL... (Attempt #{attempt}/#{max_attempts})"
      sleep 2
      attempt += 1
    end
    
    if attempt > max_attempts
      puts "❌ Failed to connect to PostgreSQL after #{max_attempts} attempts"
      exit 1
    end
    
    # Create databases
    puts "Creating databases..."
    create_databases
    
    # Start app service
    puts "Starting application..."
    system("docker compose up -d app")
    
    # Wait for app to be ready
    puts "Waiting for application to be ready..."
    wait_for_app
    
    # Initialize app container
    puts "Initializing application container..."
    initialize_app_container
    
    # Run migrations
    puts "Running migrations..."
    system("docker compose exec app bundle exec rails db:migrate")
    
    # Show logs
    puts "Showing logs..."
    system("docker compose logs -f")
  end
  
  desc "Stop server deployment"
  task :stop => :environment do
    puts "🛑 Stopping Good Night server..."
    system("docker-compose down")
    puts "✅ Server stopped successfully!"
  end

  desc "Stop server and remove volumes"
  task :clean => :environment do
    puts "🧹 Stopping and cleaning Good Night server..."
    system("docker-compose down -v")
    puts "✅ Cleanup completed successfully!"
  end

  desc "Show server logs"
  task :logs do
    system("docker-compose logs -f app")
  end

  private
  
  def create_databases
    # Create user and databases using the default postgres user
    system("docker compose exec -T db psql -U ${POSTGRES_USER} -c \"CREATE DATABASE #{ENV['POSTGRES_DB']};\"") rescue puts "⚠️ Database might already exist, continuing..."
    system("docker compose exec -T db psql -U ${POSTGRES_USER} -c \"GRANT ALL PRIVILEGES ON DATABASE #{ENV['POSTGRES_DB']} TO #{ENV['POSTGRES_USER']};\"") rescue puts "⚠️ Failed to grant privileges, but continuing..."
  end
  
  def wait_for_app
    max_attempts = 60  # Increased from 30 to 60
    attempt = 1
    while attempt <= max_attempts
      # Check if container is running first
      if system("docker compose ps app | grep -q 'Up'")
        # Then check health endpoint directly
        if system("docker compose exec app curl -f http://127.0.0.1:3000/health > /dev/null 2>&1")
          puts "✅ Application is ready and healthy!"
          break
        end
      end
      puts "⏳ Waiting for application... (Attempt #{attempt}/#{max_attempts})"
      sleep 5  # Increased from 2 to 5 seconds
      attempt += 1
    end
    
    if attempt > max_attempts
      puts "❌ Application failed to start after #{max_attempts} attempts"
      puts "📝 Showing application logs for debugging:"
      system("docker compose logs app --tail=50")
      exit 1
    end
  end
  
  def initialize_app_container
    # Install dependencies
    puts "Installing dependencies..."
    system("docker compose exec app bundle install")
    
    # Set up encryption key
    puts "Setting up encryption key..."
    unless ENV['RAILS_MASTER_KEY']
      puts "❌ RAILS_MASTER_KEY environment variable is not set"
      exit 1
    end
    
    # Verify database connection
    puts "Verifying database connection..."
    max_attempts = 30
    attempt = 1
    while attempt <= max_attempts
      if system("docker compose exec app bundle exec rails runner 'ActiveRecord::Base.connection.active?'")
        puts "✅ Database connection established"
        break
      end
      puts "⏳ Waiting for database connection... (Attempt #{attempt}/#{max_attempts})"
      sleep 2
      attempt += 1
    end
    
    if attempt > max_attempts
      puts "❌ Failed to establish database connection after #{max_attempts} attempts"
      exit 1
    end
  end
end
