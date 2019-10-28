BIN_DIR=bin/samples

box: directories
	@crystal build samples/box/main.cr -o $(BIN_DIR)/box
	./bin/samples/box

model: directories
	@crystal build samples/model/main.cr -o $(BIN_DIR)/model
	./bin/samples/model

format:
	@crystal tool format ./src

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
