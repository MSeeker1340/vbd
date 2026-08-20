function Div(el)
  return el.content
end

function Span(el)
  return el.content
end

function Figure(el)
  return {}
end

function Image(el)
  return {}
end

function RawBlock(el)
  if el.format == "html" then
    return {}
  end
end

function RawInline(el)
  if el.format == "html" then
    return {}
  end
end

function Header(el)
  el.attr = pandoc.Attr()
  return el
end

function Link(el)
  el.attr = pandoc.Attr()
  return el
end

function Code(el)
  el.attr = pandoc.Attr()
  return el
end

function CodeBlock(el)
  el.attr = pandoc.Attr()
  return el
end

function Table(el)
  el.attr = pandoc.Attr()
  return el
end
