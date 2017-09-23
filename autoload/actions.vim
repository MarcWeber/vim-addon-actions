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

fun! actions#ActionNameFromUser(append)
  let labels = map(keys(s:c['actions']),'v:val." ".get(s:c["actions"][v:val],"buffer","")')
  let index = tlib#input#List('si', 'select action '.a:append, labels)
  return keys(s:c['actions'])[index-1]
endf

fun! actions#PrepareAction(action_name)
  let a = deepcopy(s:c['actions'][a:action_name])
  let rhs = funcref#Call(a['action'])
  " rhs is either command or list of commands
  call add(s:bound_actions, type(rhs) == type([]) ? join(rhs,'|') : rhs)
  let a['rhs'] = 'exec g:vim_actions["bound_actions"]['.(len(s:bound_actions)-1).']'
  return a
endf

" using exec indirection becaus commands may be long
" using exec g:vim_actions["bound_actions"][3] doesn't cause Vim to show a
" press Enter line
fun! actions#ActionFromUser(append)
  let action_name = actions#ActionNameFromUser(a:append)
  return actions#PrepareAction(action_name)
endf

" ask for action, bind to a:lhs
fun! actions#Bind(lhs)
  let a = actions#ActionFromUser(' which will be bound to '.a:lhs)
  exec 'noremap '.get(a,'buffer','').' '.a:lhs.' :'.a['rhs'].get(a,'cr','<cr>')
endf

fun! actions#NextKey(action_name)
  let s:c.f_key_counter = get(s:c, 'f_key_counter', 1)
  let s:c.f_key_counter = 1 + s:c.f_key_counter

  let suggestion = "<F".s:c.f_key_counter.">"
  let answer = input("bind action '".a:action_name."' to key :", suggestion)

  if answer != suggestion
    let s:c.f_key_counter = s:c.f_key_counter -1
  endif

  return answer
endf

" ask for action and "key", then bind.
" if a action has follow up map that, too
fun! actions#Map(key, action)
  let action_name = a:action == "" ? actions#ActionNameFromUser("") : a:action
  echo action_name
  while action_name != ""
    let key = a:key == "" ? call(s:c.next_key, [action_name]) : a:key
    let a = actions#PrepareAction(action_name)
    exec 'noremap '.get(a,'buffer','').' '.key.' :'.a['rhs'].get(a,'cr','<cr>')
    let action_name = get(a, 'follow_up', '')
  endwhile
endf

fun! actions#SetActionOnWrite(any, bang)
  let a = actions#ActionFromUser('')

  aug ACTION_ON_WRITE
    au!
    exec 'au BufWritePost '.(a:any ? '*' : '<buffer>' ).' if !g:prevent_action | '.a['rhs'].' | endif'
  aug END

  let action_name = get(a, 'follow_up', '')
  if action_name != ""
    call actions#Map("", action_name)
  endif

  if a:bang == '!'
    exec a['rhs']
  endif
endf

fun! actions#CompileRHSMake()
  let args = ["make"]
  let args = actions#ConfirmArgs(args)
  return "call bg#RunQF(".string(args).", 'c', 0)"
endfun

fun! actions#PrepareArgs(d)
  let args = funcref#Call(a:d.cmd)
  let args = map(args,'funcref#Call(v:val)') " evaluate funcref#Function arguments
  let args = actions#ConfirmArgs(args)

  let cmds = funcref#Call(a:d.cmds)
  let cmds = map(cmds,'funcref#Call(v:val)') " evaluate funcref#Function arguments
  return {'cmds': cmds, 'cmd': args}
endf

" cmds: can be used to set errorformat etc
" cmd: the command and arguments. current file name will be appended by default
fun! actions#CompileRHSSimple(cmds, cmd) abort
  return actions#CompileRHSSimpleMany([{'cmds': a:cmds, 'cmd': a:cmd}])
  " let [args, cmds] = actions#PrepareArgs(a:cmds, cmd)
  " return cmds + ["call bg#RunQF(".string(args).", 'c', 0)"]
endf

" like CompileRHSSimple, but allow running one command after the other
" cmds: list of {'cmds': ['viml command', 'viml command', ..], 'cmd': ['executable', 'args']}
fun! actions#CompileRHSSimpleMany(cmds) abort
  let command_dicts = map(a:cmds, 'actions#PrepareArgs(v:val)')
  return 'call actions#RunCmd('.string(command_dicts).', 0)'
  " cmds + ["call bg#RunQF(".string(args).", 'c', 0)"]
endf

fun! actions#RunCmd(list, status)
  if a:status != 0 || empty(a:list) | return | endif 
  let h = a:list[0]
  let tail = a:list[1:-1]
  for c in h.cmds | exec c | endfor
  call bg#RunQF(h.cmd, 'c', 0, tail)
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
