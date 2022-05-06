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

local template = [[
\begin{wrapfigure}{r}{<<size>>in}
  \begin{center}
  \includegraphics{<<target>>}
  \end{center}
  \caption{<<caption>>}
\end{wrapfigure}
]]

local size_patt = "<<size>>"
local target_patt = "<<target>>"
local caption_patt = "<<caption>>"
local latex_caption_patt = "caption{(.+)}"

local function create_wrapped_figure(caption, size, target)

  local latex_string_size = string.gsub(template, size_patt, size)
  latex_string_target = string.gsub(latex_string_size, target_patt, target)
  latex_string_caption = string.gsub(latex_string_target, caption_patt, caption)

  latex_code = pandoc.RawInline(FORMAT, latex_string_caption)

  return latex_code

end

function wrapfig(img)

  -- Extract attributes to create new Image elements
  local target = img.src
  local title = img.title
  local attributes = img.attr
  local caption = pandoc.Pandoc({img.caption})

  caption_latex = pandoc.write(caption,'latex')

  local wrap_attr =  img.attr.attributes["wrap"]

  if wrap_attr ~= nil then

    local size = wrap_attr

    if FORMAT == 'latex' then

      local latex_code = create_wrapped_figure(caption_latex, size, target)

      return latex_code

    else
      -- return the image without the caption size token.
      return pandoc.Image(caption, target, title, attributes)

    end
  end

end

return {
  {Image = wrapfig}
}
