"=============================================================================
" Jinja2 Snippets
"=============================================================================
call snippet_engine#add('jj2_for_Ent', [
            \ '{%- for ${1:item} in ${2:items} %}',
            \ '    ${0}',
            \ '{%- endfor %}',
            \ ], { 'filetype': 'jinja2', 'desc': 'Jinja2 for loop' })

call snippet_engine#add('jj2_if_Ent', [
            \ '{%- if ${1:condition} %}',
            \ '    ${0}',
            \ '{%- endif %}',
            \ ], { 'filetype': 'jinja2', 'desc': 'Jinja2 if block' })

call snippet_engine#add('jj2_set_Ent', [
            \ '{%- set ${1:var} = ${2:value} %}${0}',
            \ ], { 'filetype': 'jinja2', 'desc': 'Jinja2 set statement' })
