# Oyasumi Service - Sleep Tracking Application

A Rails application for tracking sleep patterns and records, built with a clean architecture approach. The application allows users to track their sleep, follow other users, and view sleep records of followed users.

[![Ruby Version](https://img.shields.io/badge/ruby-3.4.2-red.svg)](https://www.ruby-lang.org/en/)
[![Rails Version](https://img.shields.io/badge/rails-8.0.0-red.svg)](https://rubyonrails.org/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## 🚀 Features

- **User Management**: Create and manage user profiles
- **Sleep Tracking**: Clock in/out to track sleep duration
- **Social Features**: Follow/unfollow other users
- **Sleep Analytics**: View sleep records of followed users
- **API-First**: RESTful API with OpenAPI documentation

## 🏗️ Architecture

The application follows a clean architecture pattern with:

### Domain Layer
- User management
- Sleep record tracking
- User relationships

### Application Layer
- Sleep tracking workflows
- User following logic
- Data aggregation

### Infrastructure Layer
- PostgreSQL database
- Redis caching
- Background jobs

### Interface Layer
- RESTful endpoints
- OpenAPI documentation

### Key Entities
- **User**: Tracks user profiles and relationships
- **SleepRecord**: Records sleep start and end times
- **Relationship**: Manages user following relationships

## 📋 Prerequisites

- Ruby 3.4.2 (managed by rbenv)
- Bundler 2.6.7
- Docker and Docker Compose
- PostgreSQL 14
- Redis 7

## 🛠️ Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/akbarpambudi/oyasumi_service.git
   cd oyasumi_service
   ```

2. Install Ruby and dependencies:
   ```bash
   rbenv install 3.4.2
   gem install bundler:2.6.7
   bundle install
   ```

3. Set up environment variables:
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. Start development services:
   ```bash
   docker compose -f docker-compose.dev.yml up -d
   ```

5. Set up the database:
   ```bash
   rbenv exec bundle exec rake db:create db:migrate
   ```

6. Run the application:
   ```bash
   rbenv exec bundle exec rails server
   ```

## 🔧 Development Tasks

### Environment Management
```bash
# Setup development environment
rbenv exec bundle exec rake dev:setup

# Stop development environment
rbenv exec bundle exec rake dev:stop

# Clean development environment (stop and remove volumes)
rbenv exec bundle exec rake dev:clean
```

### Testing
The project uses RSpec with three test categories:

1. **Unit Tests** (domain logic without database):
   ```bash
   rbenv exec bundle exec rake test:unit
   ```

2. **Integration Tests** (controllers, requests, infrastructure):
   ```bash
   rbenv exec bundle exec rake test:integration
   ```

3. **E2E Tests** (full stack):
   ```bash
   rbenv exec bundle exec rake test:e2e
   ```

4. **All Tests**:
   ```bash
   rbenv exec bundle exec rake test:all
   ```

5. **Test Coverage**:
   ```bash
   # All tests with coverage
   rbenv exec bundle exec rake test:coverage

   # Specific test types with coverage
   rbenv exec bundle exec rake test:coverage:unit
   rbenv exec bundle exec rake test:coverage:integration
   rbenv exec bundle exec rake test:coverage:e2e
   ```

## 🚀 Deployment

### Quick Deployment

1. Set up production environment:
   ```bash
   cp .env.production.example .env.production
   # Edit .env.production with your production configuration
   ```

2. Deploy the application:
   ```bash
   rbenv exec bundle exec rake server:deploy
   ```

This will:
- Build and start Docker containers
- Set up the database
- Run migrations
- Start the application

### Server Management
```bash
# View logs
rbenv exec bundle exec rake server:logs

# Stop server
rbenv exec bundle exec rake server:stop

# Clean server (stop and remove volumes)
rbenv exec bundle exec rake server:clean
```

## 📚 API Documentation

API documentation is available in OpenAPI format at `docs/api/open-api.yaml`. You can view it using any OpenAPI viewer or Swagger UI.

## ⚡ Performance Considerations

- Database indexes for efficient queries
- Redis caching for frequently accessed data
- Pagination for large result sets
- Background jobs for heavy computations
- Database transactions for data consistency

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Rails](https://rubyonrails.org/) - The web framework used
- [PostgreSQL](https://www.postgresql.org/) - The database
- [Redis](https://redis.io/) - The caching system