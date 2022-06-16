--[[
Filter to extract the comments from a docx file and create a separate document
containing only the comment contents and information.

For this filter to work, the --track-changes=all flag must be used,
e.g.
pandoc -f docx -t markdown example.docx --track-changes=all -o comments.md.
]]

local read_state = false
local current_author
local current_date
local selected_text = ""
local current_comment = ""
local compiled_comments = {}

local function process_date_time(date_time)
    --[[
    Extract the date and time from a string containing the date and time
    combined.

    date_time: string

    date, time: (string, string)
  ]]

    local date_pattern = "(%d+%-%d+%-%d+)"
    local time_pattern = "%d+%:%d+%:%d+"

    local date = string.match(date_time, date_pattern)
    local time = string.match(date_time, time_pattern)

    return date, time
end

local function dump_comment()
    --[[
    Add scraped comment contents and information into a set of elements for a
    new document and wipe their storage container variables.
  ]]

    local date_string, time_string = process_date_time(current_date)
    local auth = pandoc.Header(2, pandoc.Str(current_author .. "\n"))

    local date = pandoc.Str(date_string .. " @ " .. time_string .. "\n")

    local comment = pandoc.Str(current_comment:sub(1, -2) .. "\n\n")

    local quoted_text = pandoc.BlockQuote(pandoc.Str(selected_text:sub(1, -2) .. "\n"))

    local comment_info = pandoc.Inlines({ date })
    local info = pandoc.Para(comment_info)

    local comment_content = pandoc.Para(comment)

    table.insert(compiled_comments, auth)
    table.insert(compiled_comments, info)
    table.insert(compiled_comments, quoted_text)
    table.insert(compiled_comments, comment_content)

    current_author = ""
    current_date = ""
    current_comment = ""
    selected_text = ""
end

local function check_span(subject)
    --[[
    Check if a span is a comment and extract relevent information.
  ]]

    local span_class = subject.classes[1]
    if span_class == "comment-start" then
        read_state = true
    elseif span_class == "comment-end" then
        dump_comment()
        read_state = false
    end

    if subject.attr.attributes.author then
        current_author = subject.attr.attributes.author
        current_date = subject.attr.attributes.date

        subject.content:walk({
            Str = function(str_elem)
                current_comment = current_comment .. str_elem.text .. " "
            end,
        })
    end
end

local function load_text(str_elem)
    --[[
    Read text into selected_text if the read state is true.
  ]]

    if read_state then
        selected_text = selected_text .. str_elem.text .. " "
    end
end

local function traverse_doc(doc)
    --[[
    Walk through the document and scrape out comment information.
  ]]

    -- Iterate through the blocks of the document.
    for block_id, block_data in pairs(doc.blocks) do
        pandoc.walk_block(block_data, {
            Span = check_span,
            Str = load_text,
        })
    end

    return pandoc.Pandoc(compiled_comments)
end

return {
    { Pandoc = traverse_doc },
}
