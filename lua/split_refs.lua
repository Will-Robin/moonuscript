--[[
Adapted from
https://github.com/pandoc/lua-filters/tree/master/multiple-bibliographies
and
https://github.com/databio/sciquill/tree/master/pandoc_filters/multi-refs

To prevent duplication of reference entries between bibliographies, set
split_ref_no_duplicates: true in the document metadata yaml.
]]

if PANDOC_VERSION == nil then -- if pandoc_version < 2.1
  error("ERROR: pandoc >= 2.1 required for refs filter")
else
  PANDOC_VERSION:must_be_at_least {2,8}
end

local utils = require('pandoc.utils')

local ref_class = "refs" -- class name for reference divs

local meta -- Container for the document metadata

-- Containers for reference data
local allrefs -- Container for all of the references in the document
local accumulated_refids = {} -- Store for encountered reference IDs
local split_refs = {} -- Store for all references before each div
local processed_entries = {} -- Entries which have already been placed in a div

local current_div = 1 -- Counter used to identify the next ref div to populate

function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

local function run_citeproc(doc)
  if PANDOC_VERSION >= '2.11' then
    local args = {'--from=json', '--to=json', '--citeproc'}
    return utils.run_json_filter(doc, 'pandoc', args)
  else
    return utils.run_json_filter(doc, 'pandoc-citeproc', {FORMAT, '-q'})
  end
end

local function insert_refs(div)
  -- Populate a refs div with references from the split_refs container
  if table.contains(div.classes, ref_class) then
    div.content = split_refs[current_div]
    current_div = current_div+1
  end
  return div
end

local function make_refs_subset(allrefs, subset_ids)

  local local_refs_subset = {} --Container stores refs to add to current biblio

  local i = 1 -- Counter for references going into current bibliography

  for k,v in pairs(allrefs.content) do

    local already_included = false

    for _, refid in pairs(subset_ids) do
      if "ref-"..refid==v.identifier then

        if processed_entries[v.identifier] then
          already_included = true
        end

        if meta['split_ref_no_duplicates'] and already_included then
          print("Skipping", refid, "as duplicated reference between sections.")
        else
          local_refs_subset[i] = v
          i = i+1
          processed_entries[v.identifier] = v.identifier
        end

      end
    end
  end

  table.insert(split_refs, local_refs_subset)

end

local function accumulate(inline)
  -- Iterate through the inline and find elements with 'NormalCitation' modes
  -- and store them in accumulated_refids.
  for i,p in pairs(inline) do
    if p.citations ~= nil then
        for k,v in pairs(p.citations) do
          if v.mode == 'NormalCitation' then
            table.insert(accumulated_refids, v.id)
          end
        end
    end
  end
end

local function populate_refs(div)
  -- Iterate through the div to find the one which contains `ref_class` in its
  -- classes. The current contents of accumulated_refids is deposited inside,
  -- and accumulated_refids is emptied for a new collection of references to be
  -- scraped in further iterations.
  for i,p in pairs(div) do
    if type(p) == 'table' then
      for k,v in pairs(p) do
        if v.classes ~= nil and table.contains(v.classes, ref_class) then
          make_refs_subset(allrefs, accumulated_refids)
          -- Flush out the references accumulated
          accumulated_refids = {}
        end
      end
    end
  end
end

local function traverse_doc(doc)

  doc_with_cites = run_citeproc(doc) -- Create a new document with citations

  -- Find all of the reference elements
  allrefs = doc_with_cites.blocks:find_if(
    function (b)
      return b.identifier == 'refs'
    end
  )

  -- Return early if there are no references
  if not allrefs then
    return nil
  end

  for _, block_data in pairs(doc.blocks) do
    -- Walk through each block of the document and apply filters which
    -- collect references in Inlines, then deposit them in `ref_class` class
    -- divs.
    pandoc.walk_block(
                        block_data,
                        {
                          Inlines = accumulate,
                          Div = populate_refs,
                        }
                      )

  end
end

local remove_pandoc_citeproc_results = {
    -- Filter to the references div and bibliography header added by
    -- pandoc-citeproc.
    Header = function (header)
      return header.identifier == 'bibliography'
        and {}
        or nil
    end,
    Div = function (div)
      return div.identifier == 'refs'
        and {}
        or nil
    end
}

function set_up_document(doc)
  meta = doc.meta
  section_refs_level = tonumber(meta["section-refs-level"]) or 1
  orig_bibliography = meta.bibliography
  meta.bibliography = meta['section-refs-bibliography'] or meta.bibliography
  local sections = utils.make_sections(true, nil, doc.blocks)
  return pandoc.Pandoc(sections, doc.meta)
end

return {
  -- remove result of previous pandoc-citeproc run
  remove_pandoc_citeproc_results,
  {Pandoc = set_up_document},
  {Pandoc = traverse_doc},
  {Div = insert_refs},
}
