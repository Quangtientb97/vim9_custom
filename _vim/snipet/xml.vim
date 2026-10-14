"=============================================================================
" XML Snippets
"=============================================================================
call snippet_engine#add('xml_template_Ent', [
            \ '<?xml version="1.0" encoding="UTF-8"?>',
            \ '<${1:component}>',
            \ '    <${2:property}>${3:value}</${2:property}>',
            \ '    ${0}',
            \ '</${1:component}>',
            \ ], { 'filetype': 'xml', 'desc': 'XML root template' })

call snippet_engine#add('xml_tag_Ent', [
            \ '<${1:tag}>${2}</${1:tag}>${0}',
            \ ], { 'filetype': 'xml', 'desc': 'XML tag pair' })
