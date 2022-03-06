function createTableElement(filename)
  -- Reads in the file given by the path filename
  -- and outputs a new pandoc table element

  local f = io.open(filename, "r")

  if f ~= nil then
    local csv = f:read("*all")
    f:close()
    local new_section = pandoc.read(csv, "csv")
    return new_section
  end

  return nil

end

function CodeBlock(e)
  -- turns a CodeBlock element into a table
  local caption = e.text
  local filename = e.attr.classes[1]

  if filename == nil then
    return e
  end

  if string.match(filename,"csv") then
    local new_section = createTableElement(filename)

    if new_section ~= nil then
      local ast_table = new_section.blocks[1]

      ast_table.caption.short = {pandoc.Str(caption)}

      return ast_table
    end
  else
    return e
  end
end

function Div(e)
  -- turns a Div element into a table
  local caption = e.content[1].content[1]

  local filename = e.attr.classes[1]

  if filename == nil then
    return e
  end

  
  if string.match(filename,"csv") then
    local f = io.open(filename, "r")
    local csv = f:read("*all")
    f:close()

    local new_section = pandoc.read(csv, "csv")

    local ast_table = new_section.blocks[1]

    ast_table.caption.short = {pandoc.Str(caption)}

    return ast_table
  else
    return e
  end
end
