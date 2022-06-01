SHELL = /bin/bash

zip:
	rm -f proj03-code.zip
	@if (( $$(find . -name "input.txt" | wc -l) < 1 )); then echo "ERROR: No input.txt file found. You must include this in your submission"; exit 1; fi
	@if (( $$(find . -name "bomb*" -type d | wc -l) < 1 )); then echo "ERROR: No bomb directory found. You must include this in your submission"; exit 1; fi
	zip -r proj03-code.zip *

.PHONY: zip
