ARGS = $(filter-out $@,$(MAKECMDGOALS))
MAKEFLAGS += --silent

list:
	sh -c "echo; $(MAKE) -p no_targets__ | awk -F':' '/^[a-zA-Z0-9][^\$$#\/\\t=]*:([^=]|$$)/ {split(\$$1,A,/ /);for(i in A)print A[i]}' | grep -v '__\$$' | grep -v 'Makefile'| sort"

#############################
# Create new project
#############################

create:
	bash bin/create-project.sh $(ARGS)

#############################
# Docker machine states
#############################

up:
	docker-compose up -d

start:
	docker-compose start

stop:
	docker-compose stop

state:
	docker-compose ps

rebuild:
	docker-compose stop
	docker-compose rm --force app
	docker-compose build --no-cache
	docker-compose up -d

#############################
# MySQL
#############################

mysql-backup:
	bash ./bin/backup.sh mysql

mysql-restore:
	bash ./bin/restore.sh mysql

#############################
# Solr
#############################

solr-backup:
	bash ./bin/backup.sh solr

solr-restore:
	bash ./bin/restore.sh solr

#############################
# General
#############################

backup:  mysql-backup  solr-backup
restore: mysql-restore solr-restore

build:
	bash bin/build.sh

bash: shell

shell:
	docker exec -it -u application $$(docker-compose ps -q app) /bin/bash

root:
	docker exec -it -u root $$(docker-compose ps -q app) /bin/bash


#############################
# gdz
#############################

gdz-install:
	$(eval IMAGEPREFIX:=$(subst -,,$(shell basename $(CURDIR))))
	docker-compose up -d
	touch app/FIRST_INSTALL
	docker exec --user=application $(IMAGEPREFIX)_app_1 /docker/app/composer.phar install
	docker exec $(IMAGEPREFIX)_app_1 chown -R application:application /docker/app/

#############################
# Argument fix workaround
#############################
%:
	@:
