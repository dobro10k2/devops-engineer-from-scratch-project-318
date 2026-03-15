IMAGE_NAME=project-devops-deploy
DOCKER_REPO=ghcr.io/dobro10k2/project-devops-deploy

# Short git commit SHA
APP_REPO=../project-devops-deploy
GIT_SHA := $(shell git -C $(APP_REPO) rev-parse --short HEAD)
#GIT_SHA := $(shell git rev-parse --short HEAD)

VAULT_FILE=.vault_pass
ANSIBLE_DIR=ansible

setup:
	cd $(ANSIBLE_DIR) && \
	ansible-playbook playbook.yml \
	-i inventory.ini \
	-e docker_tag=$(or $(docker_tag),$(GIT_SHA)) \
	--vault-password-file ../$(VAULT_FILE)

deploy:
	cd $(ANSIBLE_DIR) && \
	ansible-playbook playbook.yml \
	-i inventory.ini \
	-e docker_tag=$(or $(docker_tag),$(GIT_SHA)) \
	--tags deploy \
	--vault-password-file ../$(VAULT_FILE)

rollback:
	cd $(ANSIBLE_DIR) && \
	ansible-playbook playbook.yml \
	-i inventory.ini \
	-e docker_tag=$(TAG) \
	--vault-password-file ../$(VAULT_FILE)

lint:
	ansible-lint ansible

check:
	ansible-playbook ansible/playbook.yml \
	-i ansible/inventory.ini \
	--syntax-check
