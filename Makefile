build: directories
	@crystal build src/prism.cr -o bin/debug/prism

release: clean directories docs test
	@crystal build src/prism.cr -o bin/release/prism --release --no-debug

run:
	@crystal src/prism.cr

directories:
	@mkdir -p bin
	@mkdir -p bin/debug
	@mkdir -p bin/release

docs:
	@crystal docs src/prism.cr

test:
	@crystal spec

clean:
	@rm -rf bin
	@rm -rf docs

.PHONY: build
