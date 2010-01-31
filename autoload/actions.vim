exec scriptmanager#DefineAndBind('s:c','g:vim_actions', '{}')
let s:c['actions'] = get(s:c,'actions',{})

" this list will grow over time. But not much enough to care about
let s:c['bound_actions'] = get(s:c,'bound_actions',[])
let s:bound_actions = s:c['bound_actions']

fun! actions#AddAction(label,dict)
  let s:c['actions'][a:label] = a:dict
endf

" using exec indirection becaus commands may be long
" using exec g:vim_actions["bound_actions"][3] doesn't cause Vim to show a
" press Enter line
fun! actions#ActionFromUser(append)
  let labels = map(keys(s:c['actions']),'v:val." ".get(s:c["actions"][v:val],"buffer","")')
  let index = tlib#input#List('si', 'select action '.a:append, labels)
  let a = copy(s:c['actions'][keys(s:c['actions'])[index-1]])
  let rhs = funcref#Call(a['action'])
  " rhs is either command or list of commands
  call add(s:bound_actions, type(rhs) == type([]) ? join(rhs,'|') : rhs)
  let a['rhs'] = 'exec g:vim_actions["bound_actions"]['.(len(s:bound_actions)-1).']'
  return a
endf

fun! actions#Bind(lhs)
  let a = actions#ActionFromUser(' which will be bound to '.a:lhs)
  exec 'noremap '.get(a,'buffer','').' '.a:lhs.' :'.a['rhs'].get(a,'cr','<cr>')
endf

fun! actions#SetActionOnWrite(any)
  let a = actions#ActionFromUser('')
  silent! aug! ACTION_ON_WRITE

  aug ACTION_ON_WRITE
  exec 'au BufWritePost '.(a:any ? '*' : '<buffer>' ).' '.a['rhs']
  aug END
endf
