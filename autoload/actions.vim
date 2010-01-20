exec scriptmanager#DefineAndBind('s:c','g:vim_actions', '{}')
let s:c['actions'] = get(s:c,'actions',{})

fun! actions#AddAction(label,dict)
  let s:c['actions'][a:label] = a:dict
endf

fun! actions#ActionFromUser(append)
  let labels = values(map(copy(s:c['actions']),'v:key." ".get(v:val,"buffer","")'))
  let index = tlib#input#List('si', 'select action '.a:append, labels)
  return values(s:c['actions'])[index-1]
endf

fun! actions#Bind(lhs)
  let a = actions#ActionFromUser(' which will be bound to '.a:lhs)
  let rhs = funcref#Call(a['action'])
  let rhs_s = type(rhs) == type([]) ? join(rhs,'<bar>') : rhs
  exec 'noremap '.get(a,'buffer','').' '.a:lhs.' :'.rhs_s.get(a,'cr','<cr>')
endf

fun! actions#SetActionOnWrite()
  let a = actions#ActionFromUser('')
  let rhs = funcref#Call(a['action'])
  let rhs_s = type(rhs) == type([]) ? join(rhs,'|') : rhs
  silent! aug! ACTION_ON_WRITE

  aug ACTION_ON_WRITE
  exec 'au BufWritePost * '.rhs_s
  aug END
endf
