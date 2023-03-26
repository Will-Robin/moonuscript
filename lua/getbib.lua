-- from https://twitter.com/pandoc_tips/status/1481910457145434113
-- extracts the bibliography from a document

PANDOC_VERSION:must_be_at_least("2.17")

function Pandoc(d)
  d.meta.references = pandoc.utils.references(d)
  d.meta.bibliography = nil
  return d
end
