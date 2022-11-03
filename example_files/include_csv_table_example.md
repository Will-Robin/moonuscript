Here is an example of how to insert a table using a code block, and an external `.csv` file.

```{csv_file="tables/example_table_source.csv"}
Table caption from code block.
```

```python
print("This is a normal codeblock")
```

:::{csv_file="tables/example_table_source.csv"}
Table caption from div.
:::


:::{#hello}
A normal Div
:::

