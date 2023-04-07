PANDOC_VERSION:must_be_at_least("2.17")

--- pattern for finding figure references
--- Example: {#f:fig1ref:i}
local patt = "{%#%l:.+:%a}"
local id_patt = ":(.+):"
local part_of_text_patt = ":(%a)}"

--- Variables
local img_filetype = ".png"
local img_caption_filetype = ".md"
local fig_dir = ""
local caption_dir = ""

--- Check if a file exists.
local function file_exists(file)
  local f = io.open(file, "rb")
  if f then
    f:close()
  end
  return f ~= nil
end

--- Get the text contents from a file.
local function text_from_file(fname)
  if file_exists(fname) then
    local file = io.open(fname, "r")
    local text = file:read("*a")
    file:close()
    return text
  else
    return nil
  end
end

--- Find the figure and caption directory fields from the document metadata.
local function get_figure_path(meta)
  if meta.figure_dir ~= nil then
    fig_dir = meta.figure_dir[1].text
  end

  if meta.caption_dir ~= nil then
    caption_dir = meta.caption_dir[1].text
  end
end

--- Finds a figure tag (`{#f:tag:i}`) and uses `tag` to find construct
--- file names in combination with the `fig_dir` and `caption_dir` variables.
local function check_block(block_data)
  local s

  -- Scan through the block and figure tags
  pandoc.walk_block(block_data, {
    Str = function(token)
      if token.text:match(patt) then
        s = token
      end
    end,
  })

  if s ~= nil then
    local pot_tag = s.text:match(part_of_text_patt)
    local id = s.text:match(id_patt)

    if pot_tag == "i" then
      local filename = fig_dir .. "/" .. id .. img_filetype
      local caption_filename = caption_dir .. "/" .. id .. img_caption_filetype
      local caption = ""
      local fig_title = "fig:"

      caption_file_contents = text_from_file(caption_filename)

      if caption_file_contents ~= nil then
        local doc = pandoc.read(caption_file_contents)
        caption = doc.blocks[1].content
        fig_title = fig_title .. caption_file_contents
      end

      -- If the image file does not exist, Pandoc will replace the element with
      -- the 'description', which will be empty.
      local img = pandoc.Image(caption, filename, fig_title)
      return pandoc.Figure(pandoc.Plain({ img }), { caption }, {})
    end
  end
end

return {
  {
    Meta = function(meta)
      get_figure_path(meta)
    end,
  },
  {
    Para = function(para)
      return check_block(para)
    end,
  },
}
