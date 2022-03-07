# Moonuscript

Pandoc Lua filters (Pandoc 2.17.1.1).

- To organise the components of a document.
- To debug when something goes wrong.
- To automate the boring stuff.

Filters are in the `lua` directory. Examples are in the `example_files` directory (results can be generated using the `Makefile`, or you can copy the commands from them. Note the directory structure!).

## Contents

`code_block_table.lua` converts a code block to a table given a `.csv` file attribute.

`figure_insert.lua` inserts a figure using a tag in the markdown.

`figure_numbers.lua` automatically numbers instances of figure tags in a document.
