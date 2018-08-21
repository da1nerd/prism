BIN_DIR=bin/samples

samples: directories
	@crystal build samples/window.cr -o $(BIN_DIR)/window

directories:
	@mkdir -p $(BIN_DIR)

docs:
	@crystal docs

test:
	@crystal spec

clean:
	@rm -rf bin
	@rm -rf docs

.PHONY: examples
