start-docker:
	TMPDIR=/private$$TMPDIR docker-compose -f docker-compose.yml up -d --force-recreate --remove-orphans

stop-docker:
	docker-compose -f docker-compose.yml down
