local function load_file_contents(filename)
  --[[
    Reads in the file given by the path filename
    and outputs a new pandoc table element
    filename: string
    new_section: pandoc.Table or nil
  ]]

  local f = io.open(filename, "r")

  if f ~= nil then
    local contents = f:read("*all")
    f:close()
    return contents
  end

end

local function file_to_table(filename)
  --[[
  ]]

  if filename == nil then
    return nil
  end

  if string.match(filename, "csv") then
    local text = load_file_contents(filename)

    if text ~= nil then
      local doc = pandoc.read(text, "csv")

      return doc.blocks
    end
  else
    return nil
  end
end

local function create_ast_table(filename, caption)

  local table_blocks = file_to_table(filename)

  if table_blocks ~= nil then
    local table_block = table_blocks[1]

    table_block.caption.short = { caption }

    return table_block
  end

end

local function handle_div(div)
  --[[
  ]]

  local caption = div.content

  local filename = div.attr.attributes.csv_file

  local table_blocks = create_ast_table(filename, caption)

  return table_blocks

end

local function handle_codeblock(codeblock)
  --[[
  ]]

  local caption = pandoc.Str(codeblock.text)

  local filename = codeblock.attr.attributes.csv_file

  local table_blocks = create_ast_table(filename, caption)

  return table_blocks
end

return {
  { CodeBlock = handle_codeblock },
  { Div = handle_div },
}
