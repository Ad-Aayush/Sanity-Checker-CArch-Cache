.PHONY: run check clean

# File to check
file_name ?=

run: 
	./test.sh $(file_name)

clean:
	rm -rf diffs
