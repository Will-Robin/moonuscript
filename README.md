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

`extract_comments.lua` extracts the comments from a `docx` file and creates a separate document containing the information contained in them.

`split_refs.lua` creates 'split' bibliographies within a document wherever a `<div id="refs"></div>` is placed. Is is possible to avoid duplicating references across the bibliographies. Adapted from [a similar filter on the Pandoc Lua Filters repository](https://github.com/pandoc/lua-filters/tree/master/multiple-bibliographies).

`wrap_fig.lua` lua adaptation of [pandoc-wrapfig](https://github.com/scotthartley/pandoc-wrapfig) for wrapping figures in LaTeX/pdf output.

## Related

If you like this, you may like:

[The Pandoc Lua Filters Documentation](https://pandoc.org/lua-filters.html)
[The official Pandoc Lua Filters Repo](https://github.com/pandoc/lua-filters)
[Quarto](https://quarto.org)
[RMarkdown](https://rmarkdown.rstudio.com)

