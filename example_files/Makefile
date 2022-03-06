all: figure_insertion_example.pdf code_block_to_table_example.pdf figure_tags_example.pdf

figure_insertion_example.pdf: figure_insertion_example.md
	pandoc -f markdown -t pdf figure_insertion_example.md \
	--lua-filter=../lua/figure_insert.lua -s -o figure_insertion_example.pdf

code_block_to_table_example.pdf: code_block_to_table_example.md
	pandoc -f markdown -t pdf code_block_to_table_example.md \
	--lua-filter=../lua/code_block_table.lua -s -o code_block_to_table_example.pdf

figure_tags_example.pdf: figure_tags_example.md
	pandoc -f markdown -t pdf figure_tags_example.md \
	--lua-filter=../lua/figure_numbers.lua -s -o figure_tags_example.pdf

# Cleaning up png files.
.PHONY: clean

clean:
	rm figure_insertion_example.pdf
	rm code_block_to_table_example.pdf
	rm figure_tags_example.pdf

