SRCS		= $(wildcard *.md)
HTMLS		= $(SRCS:.md=.html)
PDF		= $(shell basename $(shell pwd)).pdf
PDF_KINDLE	= $(shell basename $(shell pwd))-kindle.pdf

%.html: %.md
	sed -e 's:(\([^)]*\).md):(\1.html):' < $< |\
		pandoc -o $@ -f markdown -s --mathjax

all: $(HTMLS)

pdf: $(SRCS) template.tex
	mkdir -p .build
	for i in *md; do\
		sed -e 's:^# .*:\\newpage:' < $$i |\
		sed -e 's:^## :# :' |\
		sed -e 's:^### :## :' |\
		sed -e 's:\[\([^]]*\)\](\(ch[^)]*\).md):\1:' >\
		.build/$$i; done
	pandoc .build/*.md -o $(PDF)\
		--template template.tex --pdf-engine=xelatex\
		-f markdown+escaped_line_breaks\
		-M "title=`grep '^# ' < README.md | sed 's:^# \(.*\):\1:'`"\
		-V geometry:"top=2.2cm,bottom=2cm,left=1.8cm,right=1.8cm"\
		-V papersize:b5paper -V fontsize=11pt
	pandoc .build/*.md -o $(PDF_KINDLE)\
		--template template.tex --pdf-engine=xelatex\
		-f markdown+escaped_line_breaks\
		-M "title=`grep '^# ' < README.md | sed 's:^# \(.*\):\1:'`"\
		-V geometry:"top=0.2cm,bottom=0.4cm,left=0.15cm,right=0.15cm"\
		-V papersize:a6paper -V fontsize=12pt
	rm -rf .build

clean:
	rm -f $(HTMLS) $(PDF) $(PDF_KINDLE)
