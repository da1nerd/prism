BIN_DIR=bin/samples

all: samples

start: samples
	./bin/samples/game

format:
	@crystal tool format ./src

samples: directories
	@crystal build samples/main.cr -o $(BIN_DIR)/game
	@crystal build samples/model/main.cr -o $(BIN_DIR)/model

release: directories
	@crystal build samples/main.cr -o $(BIN_DIR)/game --release

directories:
	@mkdir -p $(BIN_DIR)
	@cp -r samples/res $(BIN_DIR)

docs:
	@crystal docs

test:
	@crystal spec

clean:
	@rm -rf bin
	@rm -rf docs
