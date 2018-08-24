BIN_DIR=bin/samples
GLUC_DIR=src/crystglut/lib_gluc

all: samples

lib: src/crystglut/lib_gluc
	cd ${GLUC_DIR} && cmake . && make

samples: lib directories
	@crystal build samples/game.cr -o $(BIN_DIR)/game

directories:
	@mkdir -p $(BIN_DIR)

docs:
	@crystal docs

test:
	@crystal spec

clean:
	@rm -rf bin
	@rm -rf docs
	cd ${GLUC_DIR} && make clean
