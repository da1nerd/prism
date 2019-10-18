BIN_DIR=bin/samples

all: samples

start: samples
	./bin/samples/game

model: directories
	@crystal build samples/model/main.cr -o $(BIN_DIR)/model
	./bin/samples/model

box: directories
	@crystal build samples/box/main.cr -o $(BIN_DIR)/box
	./bin/samples/box

format:
	@crystal tool format ./src

samples: directories
	@crystal build samples/main.cr -o $(BIN_DIR)/game
	@crystal build samples/model-preview/main.cr -o $(BIN_DIR)/model-preview

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
