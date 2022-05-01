--[[
Adapted from
https://github.com/pandoc/lua-filters/tree/master/multiple-bibliographies

To prevent duplication of reference entries between bibliographies, set
split_ref_no_duplicates: true in the document metadata yaml.
]]

if PANDOC_VERSION == nil then -- if pandoc_version < 2.1
  error("ERROR: pandoc >= 2.1 required for refs filter")
else
  PANDOC_VERSION:must_be_at_least {2,8}
end

-- Aliases for Pandoc functions
local utils = require 'pandoc.utils'
local run_json_filter = utils.run_json_filter

--- Container for the document's metadata
local meta

-- Storage for intermediate references
local allrefs
local split_refs = {}
local processed_entries = {}
local accumulated_refids = {}

-- Index variable for reference section (order)
local iref = 1

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
    return run_json_filter(doc, 'pandoc', args)
  else
    return run_json_filter(doc, 'pandoc-citeproc', {FORMAT, '-q'})
  end
end

local function check_div(div)
  -- Populate a refs div with references
  if table.contains(div.classes, "refs") then
    print("Adding references into a ref div number: ", iref)
    div.content = split_refs[iref]
    iref = iref+1
  end
  return div
end

local function make_refs_subset(allrefs, subset_ids)
  -- Create a bibliography table using allrefs and subset_ids.
  local local_refs_subset = {}

  local i = 1

  for k,v in pairs(allrefs.content) do
    already_included = false
    for idnum, refid in pairs(subset_ids) do
      if "ref-"..refid==v.identifier then

        print(k, idnum, refid, v.identifier)

        if processed_entries[v.identifier] then
          print("Reference included in previous bibliography:", v.identifier)
          already_included = true
        end

        if meta['split_ref_no_duplicates'] and already_included then
          print("skipping")
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
  -- Iterate through the div to find the one which contains "refs" in its
  -- classes. The current contents of accumulated_refids is deposited inside,
  -- and accumulated_refids is emptied for a new collection of references to be
  -- scraped in further iterations.
  for i,p in pairs(div) do
      if type(p) == 'table' then
        for k,v in pairs(p) do
          if v.classes ~= nil and table.contains(v.classes, "refs") then
            print("Found refs div. Ref count:", #accumulated_refids)
            make_refs_subset(allrefs, accumulated_refids)
            accumulated_refids = {}
          end
        end
      end
  end
end

local function traverse_doc(doc)
  -- get the complete citation table, which we will use to
  -- create the split versions
  doc_with_cites = run_citeproc(doc)

  allrefs = doc_with_cites.blocks:find_if(function (b)
    return b.identifier == 'refs'
  end)

  if not allrefs then
    return nil
  end

  -- allrefs is the table of all references. print its count
  print("Total citations: ", #allrefs.content)

  for block_id,block_data in pairs(doc.blocks) do
    -- Walk through each block of the document and apply filters which
    -- collect references in Inlines, then deposit them in "ref" class
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

function set_up_document (doc)
  -- Set up: wrap all sections in Div elements.
  -- save meta for other filter functions
  meta = doc.meta
  section_refs_level = tonumber(meta["section-refs-level"]) or 1
  orig_bibliography = meta.bibliography
  meta.bibliography = meta['section-refs-bibliography'] or meta.bibliography
  local sections = utils.make_sections(true, nil, doc.blocks)
  return pandoc.Pandoc(sections, doc.meta)
end

return {
  -- remove result of previous pandoc-citeproc run (for backwards
  -- compatibility)
  remove_pandoc_citeproc_results,
  {Pandoc = set_up_document},
  {Pandoc = traverse_doc},
  {Div = check_div},
}
