" exec vam#DefineAndBind('s:c','g:vim_actions', '{}')
if !exists('g:vim_actions') | let g:vim_actions = {} | endif | let s:c = g:vim_actions
let s:c['actions'] = get(s:c,'actions',{})

if !exists('g:prevent_action')
  " sometimes you want to write a buffer without triggering the action
  let g:prevent_action = 0
endif

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

fun! actions#SetActionOnWrite(any, bang)
  let a = actions#ActionFromUser('')

  aug ACTION_ON_WRITE
    au!
    exec 'au BufWritePost '.(a:any ? '*' : '<buffer>' ).' if !g:prevent_action | '.a['rhs'].' | endif'
  aug END

  if a:bang == '!'
    exec a['rhs']
  endif
endf

fun! actions#CompileRHSMake()
  let args = ["make"]
  let args = actions#ConfirmArgs(args)
  return "call bg#RunQF(".string(args).", 'c', 0)"
endfun

" cmds: can be used to set errorformat etc
" cmd: the command and arguments. current fle name will be appended by default
fun! actions#CompileRHSSimple(cmds, cmd)
  let args = funcref#Call(a:cmd)
  let args = map(args,'funcref#Call(v:val)') " evaluate funcref#Function arguments
  let args = actions#ConfirmArgs(args)
  return a:cmds + ["call bg#RunQF(".string(args).", 'c', 0)"]
endf

fun! actions#CommandFromHistory()
  let list = []
  for nr in range(-1, -10, -1)
    call add(list,histget("cmd",nr))
  endfor
  return tlib#input#List("s","select command from history", list)
endf

" depreceated name
fun! actions#VerifyArgs(args, ...)
  return call(function('actions#ConfirmArgs'), [a:args] + a:000)
endfun

fun! actions#ConfirmArgs(args, ...)
  let extraLabel = a:0 > 0 ? a:1 : ""
  return eval(input('cmd '.extraLabel.': ', string(a:args)))
endf

" this is used multiple times:
" global state is bad - ther is no other way
let s:glob_patterns = []
fun! actions#AskFile(title, list_of_glob_patterns)
  let s:glob_patterns = a:list_of_glob_patterns
  return input(a:title,'','customlist,actions#InputCompletion')
endf

fun! actions#InputCompletion(ArgLead, CmdLine, CursorPos)
  let files = []
  for p in s:glob_patterns
    call extend(files, split(glob(p), "\n") )
  endfor
  return filter(files,'v:val =~'.string(a:ArgLead))
endf
