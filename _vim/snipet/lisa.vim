"=============================================================================
" LISA / LISA+ Snippets
"=============================================================================
call snippet_engine#add('lisa_component_Ent', [
            \ 'component ${1:ComponentName} {',
            \ '    properties {',
            \ '        version = "${2:1.0}";',
            \ '        description = "${3:Component description}";',
            \ '    }',
            \ '    includes {',
            \ '        ${4}',
            \ '    }',
            \ '    resources {',
            \ '        ${0}',
            \ '    }',
            \ '}',
            \ ], { 'filetype': 'lisa', 'desc': 'LISA component declaration' })

call snippet_engine#add('lisa_protocol_Ent', [
            \ 'protocol ${1:ProtocolName} {',
            \ '    properties {',
            \ '        version = "${2:1.0}";',
            \ '    }',
            \ '    behavior {',
            \ '        ${0}',
            \ '    }',
            \ '}',
            \ ], { 'filetype': 'lisa', 'desc': 'LISA protocol declaration' })
