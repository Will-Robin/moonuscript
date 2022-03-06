---
manuscript-figures:
- '{#e:example:m}'
---

# Examples

This is a figure tag in line with the text: {#e:example:t}. Note the `:t` component of the tag in the markdown source at the end.

![Figure {#e:test_img:f} is a tag in a figure caption (note the `:f` in the markdown source). Figure source: Hamonshū. 1, by Mori Yūzan; Yamada Geisōdō, Kyōto-shi, Meiji 36 (1903)](Figures/test_img.png)

Note that LaTeX automatic figure numbering will probably disagree with the tag scheme unless you're lucky. Including the code block below in the yaml metadata will remove the LateX-generated numbering.

```
header-includes:
- \usepackage{caption}
- \captionsetup[figure]{labelformat=empty}
```

Figure tags can also be placed in the metadata (see above, note the `:m` component). These figure tags can refer to tags used in other documents. Their order must be identical to their appearance in these other documents. If there is a group of documents which refer to each other and share a numbering scheme, they can be scraped together and placed in the metadata. Note that their ordering of first appearance in the text file will govern their assigned numbers. The `#x` component allows for separate numbering schemes.

