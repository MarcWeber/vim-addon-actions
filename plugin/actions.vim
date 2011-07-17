" exec vam#DefineAndBind('s:c','g:vim_actions', '{}')
if !exists('g:vim_actions') | let g:vim_actions = {} | endif | let s:c = g:vim_actions

let s:c['bindable_keys'] = get(s:c, 'bindable_keys', [ ['<s-f2>', '<f2>'], ['<s-f3>', '<f3>'], ['<s-f4>', '<f4>'], ['<s-f5>', '<f5>'], ['<s-f6>', '<f6>'], ['<s-f7>', '<f7>'] ] )

fun! s:Init()
  for l in s:c['bindable_keys']
    exec 'noremap '.l[0].' :call actions#Bind('.string(l[1]).')<cr>'
  endfor
endf

call s:Init()

command! -bang ActionOnWrite :call actions#SetActionOnWrite(1, "<bang>")
command! -bang ActionOnWriteBuffer :call actions#SetActionOnWrite(0, "<bang>")

call actions#AddAction("command from history",{'buffer':'', 'action':funcref#Function('return actions#CommandFromHistory()')})
call actions#AddAction("write & source current vim buffer",{'buffer':'<buffer>', 'action':funcref#Function('return ["w","source %"]')})
call actions#AddAction('run make', {'action': funcref#Function('actions#CompileRHSMake')})
" perl: not using all of $VIMRUNTIME/compiler/perl.vim because if you dont'
" flush valuable stdout output could be lost cause errors appear before stdout
" dump and the compiler error format drops those lines
call actions#AddAction('perl current file', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [['set efm=\%m\ at\ %f\ line\ %l.'], ["perl", funcref#Function('return expand("%")')]]})})
call actions#AddAction('gcc -gdbb current file', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [[], ["gcc", '-o', funcref#Function('return expand("%:r:t")'), '-ggdb', '-O0', funcref#Function('return expand("%")')]]})})
call actions#AddAction('g++ -gdbb current file', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [[], ["g++", '-o', funcref#Function('return expand("%:r:t")'), '-ggdb', '-O0', funcref#Function('return expand("%")')]]})})
call actions#AddAction('shebang (run this script)', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [[], [funcref#Function('return expand("%:p")')]]})})

call actions#AddAction('run php background', {'action': funcref#Function('actions_more#RunPHPRHS', {'args': [1]})})
call actions#AddAction('run python background', {'action': funcref#Function('actions_more#RunPythonRHS', {'args': [1]})})
call actions#AddAction('run python using make', {'action': funcref#Function('actions_more#RunPythonRHS', {'args': [0]})})


call actions#AddAction('sass', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [[], ["sass", funcref#Function('return expand("%")'), funcref#Function('return expand("%:r:t").".css"')]]})})

" scala see addon vim-addon-scala
" haxe see addon vim-haxe
"
"
call actions#AddAction('test', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [[], ["g++", '-o', funcref#Function('return expand("%:r:t")'), '-ggdb', '-O0', funcref#Function('return expand("%")')]]})})
