exec scriptmanager#DefineAndBind('s:c','g:vim_actions', '{}')

fun! actions#AddAction(label,dict)
  let s:c['actions'][a:label'] = a:dict
endf

fun! actions#Bind(lhs)
  let labels = map(s:c['actions'],'v:key.' '.gets(v:val,"buffer","")')
  let index = tlib#input#List('si', 'select action which will be bound to '.a:lhs, [100,200,300])
  let a = values(s:c['actions'])[index]
  let rhs = funcref#Call(a['action'])
  exec 'map '.a:lhs.' '.gets(a,'buffer','').' '.rhs.gets(a,'cr','<cr>')
endf
