-- pattern for finding figure references
-- Example: {#f:fig1ref:t}
local patt = "{%#%l:.+:%a}"
local id_patt = ":(.+):"
local type_patt = "{#(.+):.+:%a}"

-- to keep track of which figures have already been seen
local seen_elements = {}

-- storage for figure numbers arranged by figure type
local figure_numbers = {}

local function table_length(t)
  -- get the length of a table
  local counter = 0
  for v in pairs(t) do
    counter = counter + 1
  end
  return counter
end

local function in_table(t, thing)
  -- check if thing is in table t
  for i, p in pairs(t) do
    if p == thing then
      return true
    end
  end
  return false
end

local function get_figure_number(fig_table, id)
  -- get the number of the figure with id
  for i, p in pairs(fig_table) do
    for a, b in pairs(p) do
      if a == id then
        replacement = tostring(b)
        return replacement
      end
    end
  end
  return nil
end

local function replace_tag(pandocStr, type_tag, id, figure_numbers)
  replacement = get_figure_number(figure_numbers[type_tag], id)

  numbered_tag = pandocStr.text:gsub(patt, replacement)

  return numbered_tag
end

function Str(s)
  if s.text:match(patt) then
    local type_tag = s.text:match(type_patt)
    local id = s.text:match(id_patt)
    local replacement = "0"

    if in_table(seen_elements, id) then
      replacement = replace_tag(s, type_tag, id, figure_numbers)
      return pandoc.Str(replacement)
    else
      table.insert(seen_elements, id)
      if figure_numbers[type_tag] ~= nil then
        local num_elems = table_length(figure_numbers[type_tag])
        local insert = {}

        insert[id] = num_elems + 1
        table.insert(figure_numbers[type_tag], insert)
      else
        figure_numbers[type_tag] = {}
        local insert = {}
        insert[id] = 1
        table.insert(figure_numbers[type_tag], insert)
      end

      replacement = replace_tag(s, type_tag, id, figure_numbers)

      return pandoc.Str(replacement)
    end
  else
    return s
  end
end

return {
  { Str = Str },
}
