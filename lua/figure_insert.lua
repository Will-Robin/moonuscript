-- pattern for finding figure references
-- Example: {#f:fig1ref:t}
local patt = '{%#%l:.+:%a}'
local id_patt = ":(.+):"
local type_patt =  "{#(.+):.+:%a}"
local part_of_text_patt = ":(%a)}"

-- Variables
local img_filetype = ".png"
local img_caption_filetype = ".md"
local fig_dir = ""

local function file_exists(file)
  -- Check if a file exists.
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil end

function text_from_file(fname)
  -- Get the text contents from a file.
  if file_exists(fname) then
    local file = io.open(fname, 'r')
    local text = file:read('*a')
    file:close()
    return text
  else
    return nil
  end
end

function get_figure_path(meta)
  -- Find the figure directory field from the document metadata.
  fig_dir = meta.figure[1].text
end

function insert_figure_and_caption(s)
  --[[ Finds a figure tag (`{#f:tag:t}`) and uses `tag` to find contruct
  file names in combination with the `fig_dir` variable.
  ]]

  if s.text:match(patt) then

    local pot_tag = s.text:match(part_of_text_patt)
    local id = s.text:match(id_patt)

    if pot_tag == 'i' then

      local filename = fig_dir.."/"..id..img_filetype
      local caption_filename = fig_dir.."/"..id..img_caption_filetype
      local caption = ""
      local fig_title = "fig:"

      caption_file_contents = text_from_file(caption_filename)

      if caption_file_contents ~= nil then
        local doc = pandoc.read(caption_file_contents)
        caption = doc.blocks[1].content
        fig_title = fig_title..caption_file_contents
      end

      -- If the image file does not exist, Pandoc will replace the element with
      -- the 'description', which will be empty.
      return pandoc.Image(
                          caption,
                          filename,
                          fig_title
                          )
    end

  end
end

return {
  { Meta = function (meta) get_figure_path(meta) end },
  { Str = function (s) local res = insert_figure_and_caption(s) return res end },
}
