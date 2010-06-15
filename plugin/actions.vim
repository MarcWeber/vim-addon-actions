exec scriptmanager#DefineAndBind('s:c','g:vim_actions', '{}')

let s:c['bindable_keys'] = get(s:c, 'bindable_keys', [ ['<s-f2>', '<f2>'], ['<s-f3>', '<f3>'], ['<s-f4>', '<f4>'], ['<s-f5>', '<f5>'], ['<s-f6>', '<f6>'], ['<s-f7>', '<f7>'] ] )

fun! s:Init()
  for l in s:c['bindable_keys']
    exec 'noremap '.l[0].' :call actions#Bind('.string(l[1]).')<cr>'
  endfor
endf

call s:Init()

command! ActionOnWrite :call actions#SetActionOnWrite(1)
command! ActionOnWriteBuffer :call actions#SetActionOnWrite(0)

call actions#AddAction("command from history",{'buffer':'', 'action':funcref#Function('return actions#CommandFromHistory()')})
call actions#AddAction("write & source current vim buffer",{'buffer':'<buffer>', 'action':funcref#Function('return ["w","source %"]')})
call actions#AddAction('run make', {'action': funcref#Function('actions#CompileRHSMake')})
call actions#AddAction('gcc -gdbb current file', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [[], ["gcc", '-o', funcref#Function('return expand("%:r:t")'), '-ggdb', '-O0', funcref#Function('return expand("%")')]]})})
call actions#AddAction('g++ -gdbb current file', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [[], ["g++", '-o', funcref#Function('return expand("%:r:t")'), '-ggdb', '-O0', funcref#Function('return expand("%")')]]})})
" scala see addon vim-addon-scala
" haxe see addon vim-haxe
