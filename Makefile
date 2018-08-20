build: directories
	@crystal build src/prism.cr -o bin/debug/prism

release: directories
	@crystal build src/prism.cr -o bin/release/prism --release

run: build
	./bin/debug/prism

directories:
	@mkdir -p bin
	@mkdir -p bin/debug
	@mkdir -p bin/release

clean:
	@rm -rf bin

.PHONY: build
