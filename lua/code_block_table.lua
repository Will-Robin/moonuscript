local function create_table_element(filename)
  --[[
    Reads in the file given by the path filename
    and outputs a new pandoc table element
    filename: string
    new_section: pandoc.Table or nil
  ]]

  local f = io.open(filename, "r")

  if f ~= nil then
    local csv = f:read("*all")
    f:close()
    local new_section = pandoc.read(csv, "csv")
    return new_section
  end

  return nil
end

local function code_block_to_table(e)
  --[[
    turns a CodeBlock element into a table
    e: CodeBlock element
  ]]

  local caption = e.text

  local filename = e.attr.classes[1]

  if filename == nil then
    return e
  end

  if string.match(filename, "csv") then
    local new_section = create_table_element(filename)

    if new_section ~= nil then
      local ast_table = new_section.blocks[1]

      ast_table.caption.short = { pandoc.Str(caption) }

      return ast_table
    end
  else
    return e
  end
end

return {
  {CodeBlock = code_block_to_table},
}
