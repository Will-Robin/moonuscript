all: output/figure_insertion_example.pdf output/code_block_to_table_example.pdf \
	output/figure_tags_example.pdf output/extract_comments.md \
	output/split_bibliography_example.pdf \
	output/wrap_fig_example.pdf

output/figure_insertion_example.pdf: figure_insertion_example.md ../lua/figure_insert.lua
	pandoc -f markdown -t pdf figure_insertion_example.md \
	--lua-filter=../lua/figure_insert.lua -s -o output/figure_insertion_example.pdf

output/code_block_to_table_example.pdf: code_block_to_table_example.md ../lua/code_block_table.lua
	pandoc -f markdown -t pdf code_block_to_table_example.md \
	--lua-filter=../lua/code_block_table.lua -s -o output/code_block_to_table_example.pdf

output/figure_tags_example.pdf: figure_tags_example.md ../lua/figure_numbers.lua
	pandoc -f markdown -t pdf figure_tags_example.md \
	--lua-filter=../lua/figure_numbers.lua -s -o output/figure_tags_example.pdf

output/extract_comments.md: lorem_ipsum_comments.docx ../lua/extract_comments.lua
	pandoc -f docx -t markdown lorem_ipsum_comments.docx \
	--track-changes=all \
	--lua-filter=../lua/extract_comments.lua -s -o output/extract_comments.md

output/split_bibliography_example.pdf: split_bibliography.md ../lua/split_refs.lua
	pandoc -f markdown -t pdf split_bibliography.md \
	--citeproc \
	--lua-filter=../lua/split_refs.lua \
	--pdf-engine=lualatex \
	-o output/split_bibliography_example.pdf

output/wrap_fig_example.pdf: wrap_fig_example.md ../lua/wrap_fig.lua
	pandoc -f markdown -t pdf wrap_fig_example.md \
	--citeproc \
	--lua-filter=../lua/wrap_fig.lua \
	--pdf-engine=lualatex \
	--template=templates/template.latex \
	-o output/wrap_fig_example.pdf

# Cleaning up png files.
.PHONY: clean

clean:
	rm output/*

