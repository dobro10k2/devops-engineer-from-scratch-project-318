VAULT_FILE=.vault_pass
ANSIBLE_DIR=ansible

setup:
	cd $(ANSIBLE_DIR) && \
	ansible-playbook playbook.yml \
	--vault-password-file ../$(VAULT_FILE)

lint:
	ansible-lint ansible

check:
	ansible-playbook ansible/playbook.yml \
	--syntax-check

lint:
	ansible-lint ansible

test:
	ansible-playbook ansible/playbook.yml \
	--syntax-check

smoke:
	@echo "Checking application..."
	curl -f https://board.dobro10k2.ru/ || exit 1

	@echo "Checking actuator..."
	curl -f https://board.dobro10k2.ru/actuator/health || exit 1

	@echo "Checking Prometheus..."
	curl -f https://prometheus.dobro10k2.ru/-/healthy || exit 1

	@echo "Checking Grafana..."
	curl -f https://grafana.dobro10k2.ru/login || exit 1

	@echo "Checking metrics..."
	curl -f http://51.250.109.203:9090/actuator/prometheus || exit 1

	@echo "Smoke tests passed"
