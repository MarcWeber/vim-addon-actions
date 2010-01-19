exec scriptmanager#DefineAndBind('s:c','g:vim_actions', '{}')
let s:c['actions'] = get(s:c,'actions',{})

fun! actions#AddAction(label,dict)
  let s:c['actions'][a:label] = a:dict
endf

fun! actions#Bind(lhs)
  let labels = values(map(copy(s:c['actions']),'v:key." ".get(v:val,"buffer","")'))
  let index = tlib#input#List('si', 'select action which will be bound to '.a:lhs, labels)
  let a = values(s:c['actions'])[index-1]
  let rhs = funcref#Call(a['action'])
  let rhs_s = type(rhs) == type([]) ? join(rhs,'<bar>') : rhs
  exec 'noremap '.a:lhs.' '.get(a,'buffer','').' '.rhs_s.get(a,'cr','<cr>')
endf
