--[[
  Filter for wrapping figures in LaTeX output.

  Adapted from the Python filter by Scott Hartley:
  https://github.com/scotthartley/pandoc-wrapfig

  Requires the wrapfig package in the LaTeX template.

  Need to add a {x} tag to the end of the figure captions, where x is the width
  of the wrap in inches.
]]

-- Should match integers and decimals
local FLAG_PAT = '{(%d*%.?%d+)}'
local remove_patt = '{%d+%.+%d+}'

local centering = "\\centering"
local begin_wrapfigure = "\\begin{wrapfigure}{r}"
local end_wrapfigure = "\\end{wrapfigure}"

local function create_wrapped_figure(stripped_caption, size, target)

  -- begin the wrapfig environment
  local latex_begin = begin_wrapfigure..'{' .. size .. 'in}'..centering

  -- containers for the LaTeX code that will be created
  local latex_fig
  local latex_end
  local latex_code

  if string.len(stripped_caption) > 0 then

    latex_fig = latex_begin..'\\includegraphics{'..target..'}\\caption{'
    latex_end = '}'..end_wrapfigure
    latex_code = pandoc.RawInline(FORMAT, latex_fig..stripped_caption..latex_end)

  else

    latex_fig = latex_begin..'\\includegraphics{'..target..'}'
    latex_end = end_wrapfigure
    latex_code = pandoc.RawInline(FORMAT, latex_fig..latex_end)

  end

  return latex_code

end

function wrapfig(img)

  -- Extract attributes to create new Image elements
  local target = img.src
  local title = img.title
  local attributes = img.attr
  local caption = pandoc.utils.stringify(img.caption)

  -- get the figure size if the pattern is in the caption
  local wrap_match = string.match(caption, FLAG_PAT)

  if wrap_match ~= nil then

    local size = wrap_match

    -- Strip tag from the caption
    local stripped_caption = string.gsub(caption, remove_patt, "")

    if FORMAT == 'latex' then

      local latex_code = create_wrapped_figure(stripped_caption, size, target)

      return latex_code

    else
      -- return the image without the caption size token.
      return pandoc.Image(stripped_caption, target, title, attributes)

    end
  end

end

return {
  {Image = wrapfig}
}
