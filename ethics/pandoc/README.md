# Reference ODT

- has to be odt (docx is not supported)
- generate reference

```
pandoc -o reference/reference.odt --print-default-data-file reference.odt
```

## Variables in header/footer

- *Datei-\>Eigenschaften-\>Benutzerdefiniert* (File-\>Properties-\>User defined)
- *Feld* einfügen (insert field), *benutzerdefiniert* (user defined).
- Define field name as variable in YAML header

See also: https://github.com/jgm/pandoc/issues/2839

## Pagebreaks

https://github.com/pandoc/lua-filters/tree/master/pagebreak#usage-with-odt

> To use with ODT you must create a reference ODT with a named paragraph style called Pagebreak (or whatever you set the metadata field newpage_odt_style or the environment variable PANDOC_NEWPAGE_ODT_STYLE to) and define it as having no extra space before or after but set it to have a pagebreak after it https://help.libreoffice.org/Writer/Text_Flow.
>
> (There will be an empty dummy paragraph, which means some extra vertical space, and you probably want that space to go at the bottom of the page before the break rather than at the top of the page after the break!)
