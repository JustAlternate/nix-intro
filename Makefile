.PHONY: clean marp

watch:
	marp README.md -w -p --html & > /dev/null 2>&1

pdf:
	marp README.md --html --pdf

clean:
	rm -rf *.html *.pdf
