BIN_DIR=bin/samples

samples: directories
	@crystal build samples/blank_window.cr -o $(BIN_DIR)/blank_window
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

.PHONY: examples
