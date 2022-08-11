# runs a local docker-compose
start:
	docker-compose up -d

# stops a local docker-compose
stop:
	docker-compose down

# runs psql inside an active local postgres container for database inspection and queries
inspect:
	docker exec -it -u postgres feedreader-db psql
