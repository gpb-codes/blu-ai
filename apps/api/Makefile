.PHONY: build run test tidy migrate

build:
	go build -o bin/server ./cmd/server

run:
	go run ./cmd/server

test:
	go test ./... -count=1

tidy:
	go mod tidy

migrate:
	@echo "Aplica migrations con: psql $$DATABASE_URL -f migrations/001_init.sql"
