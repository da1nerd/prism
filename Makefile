BIN_DIR=bin/samples
TOOLS_DIR=src/prism/lib

all: samples

lib: src/prism/lib
	cd ${TOOLS_DIR} && cmake . && make

samples: lib directories
	@crystal build samples/game.cr -o $(BIN_DIR)/game
	@crystal build samples/blank_window.cr -o $(BIN_DIR)/blank_window

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
	cd ${TOOLS_DIR} && cmake . && make clean
