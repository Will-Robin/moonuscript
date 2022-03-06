---
figure: Figures
---

# Inserting figures and captions using tags

The tag below should be replaced by `test_img.png` from the `Figures` directory, as defined in the `yaml` metadata block above.

{#f:test_img:i}

The tag below does not have a file associated with it, and so will not be replaced:

{#f:dead_link:i}

The `:i` component of the tag indicates that it should be replaced by a figure. Any other letter here will not result in a figure insertion.

# Examples

Some more examples of what happens when the tags are placed in varying parts of the markdown are given below.

This tag is placed in an inline code field.

`{#f:test_img:i}`

This tag is placed in a code block:

```
{#f:test_img:i}
```

This tag is placed in a figure field with an empty figure url.

![{#f:test_img:i}]()

This tag is placed in a figure field with a valid figure url.

![{#f:test_img:i}](Figures/test_img.png)

