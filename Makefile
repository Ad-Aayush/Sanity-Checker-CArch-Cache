.PHONY: run check clean

# File to check
file_name ?=

test: test_perms
	./code_test.sh $(file_name)

run: run_perms
	./run.sh $(file_name)

test_perms:
	chmod +x code_test.sh 

run_perms:
	chmod +x run.sh
clean:
	rm -rf diffs
