SHELL:=/bin/bash
SHELLOPT:=-exuo pipefail
.DELETE_ON_ERROR:

FILENAME=charles-langlois-cv
FORMATS=pdf docx
PDFENGINE=wkhtmltopdf

PDFOPTIONS=
DOCXOPTIONS=


%.pdf: index.md
	ruby liquid.rb $< | pandoc --pdf-engine=$(PDFENGINE) $(PDFOPTIONS) -o $@ -f gfm+pipe_tables -

%.docx: index.md
	ruby liquid.rb $< | pandoc $(DOCXOPTIONS) -o $@

.PHONY: build
build: $(addprefix $(FILENAME).,$(FORMATS))

OUT=out
.PHONY: install
install: build
	mkdir -p $(OUT)
	mv -t $(OUT) $(addprefix $(FILENAME).,$(FORMATS))

