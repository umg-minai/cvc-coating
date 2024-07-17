-- taken from https://github.com/jgm/pandoc/issues/3109#issuecomment-742440387
function strip_meta(meta)
  meta.subtitle = nil
  meta.author = nil
  meta.date = nil
  return meta
end

return {{Meta = strip_meta}}
