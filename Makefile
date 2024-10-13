## This file list useful commands to interact with the application containers without directly invoking docker commands.
## ---

# Define variables
DOCKER_COMPOSE = docker compose -f ./.devcontainer/docker-compose.yml
APP_CONTAINER_NAME = app

# Define targets
.PHONY: setup start stop update logs console migrate attach pristine init-dev-db init-test-db init-db rspec rspec-file

help:	## Show this help.
	@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST)

start: ## Create and start containers
	$(DOCKER_COMPOSE) up -d

stop: ## Stop and remove containers, networks
	$(DOCKER_COMPOSE) down

update: ## Build or rebuild services and remove unused images
	$(DOCKER_COMPOSE) down
	$(DOCKER_COMPOSE) build
	docker image prune -f

logs: ## View and follow output from containers
	$(DOCKER_COMPOSE) logs -f

console: ## Start a rails console in the running web container
	$(DOCKER_COMPOSE) exec $(APP_CONTAINER_NAME) bundle exec rails console

migrate: ## Run database migrations
	$(DOCKER_COMPOSE) exec $(APP_CONTAINER_NAME) bundle exec rake db:migrate

attach: ## Attach local stdin, stdout, stderr, to the running web container
	docker attach maybe-$(APP_CONTAINER_NAME)-1

pristine: ## Rebuild services from scratch. This command will delete all data, including database volumes
	$(DOCKER_COMPOSE) down
	docker system prune -af --volumes
	docker volume rm $$(docker volume ls -q)
	$(DOCKER_COMPOSE) build --no-cache

init-dev-db: ## Initialise the development database and seed required data.
	$(DOCKER_COMPOSE) exec $(APP_CONTAINER_NAME) bundle exec rails db:prepare

init-test-db: ## Initialise the test database
	$(DOCKER_COMPOSE) exec -e "RAILS_ENV=test" $(APP_CONTAINER_NAME) bundle exec rails db:create db:schema:load

init-db: init-dev-db init-test-db

rspec: ## Run all specs
	$(DOCKER_COMPOSE) exec $(APP_CONTAINER_NAME) bundle exec rspec spec

setup: ## Setup the application
	$(DOCKER_COMPOSE) exec $(APP_CONTAINER_NAME) bundle exec bin/setup

rspec-file: ## Run specs for a single file. Usage: make rspec-file spec/path/to/file_spec.rb
	$(DOCKER_COMPOSE) exec $(APP_CONTAINER_NAME) bundle exec rspec $(filter-out $@,$(MAKECMDGOALS))

%: # Catch all for unknown targets so Make won't complaining about the additional arguments
	@:
