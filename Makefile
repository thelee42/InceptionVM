
VOLUME_PATH = /home/thelee/data
DB_VOLUME = db_data
WP_VOLUME = wordpress_data

SRCS_DIR = ./srcs
DC = docker compose -f $(SRCS_DIR)/docker-compose.yml
HOST_NAME = thelee.42.fr

BLUE  = \033[0;34m
GREEN = \033[0;32m
RED = \033[0;31m
NC = \033[0m


all:
	@clear
	@printf "$(BLUE)"
	@printf "  ___ _   _  ____ _____ ____ _____ ___ ___  _   _ \n"; sleep 0.1;
	@printf " |_ _| \ | |/ ___| ____|  _ \_   _|_ _/ _ \| \ | |\n"; sleep 0.1;
	@printf "  | ||  \| | |   |  _| | |_) || |  | | | | |  \| |\n"; sleep 0.1;
	@printf "  | || |\  | |___| |___|  __/ | |  | | |_| | |\  |\n"; sleep 0.1;
	@printf " |___|_| \_|\____|_____|_|    |_| |___\___/|_| \_|\n\n"; sleep 0.1;
	@printf "Loading"; sleep 0.1; printf "."; sleep 0.1; printf "."; sleep 0.1; printf ".$(NC)\n"
	@$(MAKE) up


init: host volume

host:
	@echo "$(GREEN)Ensuring $(HOST_NAME) is in /etc/hosts...$(NC)"
	@if ! grep -q "^127.0.0.1.*[[:space:]]$(HOST_NAME)[[:space:]]*$$" /etc/hosts; then \
			echo "127.0.0.1 $(HOST_NAME)" | sudo tee -a /etc/hosts > /dev/null; \
	fi

volume:
	@echo "$(GREEN)Creating Docker volumes...$(NC)"
	@mkdir -p $(VOLUME_PATH)/$(DB_VOLUME) $(VOLUME_PATH)/$(WP_VOLUME)
	@echo "$(GREEN)Docker volumes created !$(NC)"

up: init
	@echo "$(GREEN)Starting Docker compose...$(NC)"
	@$(DC) up --build -d

down:
	@echo "$(RED)Stopping Docker compose...$(NC)"
	@$(DC) down
	
clean: down
	@echo "$(RED)Removing Docker volumes and network...$(NC)"
	@$(DC) down -v
	@docker network prune -f

fclean: clean
	@echo "$(RED)Removing Docker volumes and pruning system...$(NC)"
	@docker volume rm $(DB_VOLUME) 2>/dev/null || true
	@docker volume rm $(WP_VOLUME) 2>/dev/null || true
	@rm -rf $(VOLUME_PATH)
	@docker system prune -a --force

re: fclean all

.PHONY: all down clean fclean re init host volume up down