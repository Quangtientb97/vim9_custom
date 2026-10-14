"=============================================================================
" UPF (Unified Power Format) Snippets
"=============================================================================
call snippet_engine#add('upf_power_domain_Ent', [
            \ 'create_power_domain ${1:PD_TOP} \\',
            \ '    -elements { ${2:u_top} } \\',
            \ '    -scope ${3:.}',
            \ '${0}',
            \ ], { 'filetype': 'upf', 'desc': 'Create UPF power domain' })

call snippet_engine#add('upf_supply_net_Ent', [
            \ 'create_supply_net  ${1:VDD} -domain ${2:PD_TOP}',
            \ 'create_supply_net  ${3:VSS} -domain ${2:PD_TOP}',
            \ 'set_domain_supply_net ${2:PD_TOP} -primary_power_net ${1:VDD} -primary_ground_net ${3:VSS}',
            \ '${0}',
            \ ], { 'filetype': 'upf', 'desc': 'Create and connect primary supply nets' })
