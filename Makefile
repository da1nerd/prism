BIN_DIR=bin/samples
GLUC_DIR=src/crystglut/lib_gluc
CTOOLS_DIR=src/ctools/c

all: samples

lib: src/crystglut/lib_gluc src/ctools/c
	cd ${GLUC_DIR} && cmake . && make
	cd ${CTOOLS_DIR} && cmake . && make

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
	cd ${GLUC_DIR} && make clean
