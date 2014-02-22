" exec vam#DefineAndBind('s:c','g:vim_actions', '{}')
if !exists('g:vim_actions') | let g:vim_actions = {} | endif | let s:c = g:vim_actions

let s:c.next_key = get(s:c, 'next_key', 'actions#NextKey')

" TODO: honor follow_up
command! -bang ActionOnWrite :call actions#SetActionOnWrite(1, "<bang>")
command! -bang ActionOnWriteBuffer :call actions#SetActionOnWrite(0, "<bang>")
command! -bang MapAction :call actions#Map("", "")

" this requires github.com/MarcWeber/vim-addon-erroformats:
let s:set_efm =  funcref#Function('return "call vim_addon_errorformats#SetErrorFormat(".string(vim_addon_errorformats#InputErrorFormatNames()).")"')

call actions#AddAction("command from history",{'buffer':'', 'action':funcref#Function('return actions#CommandFromHistory()')})
call actions#AddAction("write & source current vim buffer",{'buffer':'<buffer>', 'action':funcref#Function('return ["w","source %"]')})
call actions#AddAction('run make', {'action': funcref#Function('actions#CompileRHSMake')})
call actions#AddAction('cmake', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [['set efm=CMake\ Error\ at\ %f:%l\ %m,%f:%l:'], funcref#Function('return ["cmake","../"]')]})})

" perl: not using all of $VIMRUNTIME/compiler/perl.vim because if you dont'
" flush valuable stdout output could be lost cause errors appear before stdout
" dump and the compiler error format drops those lines
call actions#AddAction('perl current file', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [['set efm=\%m\ at\ %f\ line\ %l.,\%m\ at\ %f\ line\ %l\,\ at\ end\ of\ line,%m\ at\ %f\ line\ %l\,\ near'], ["perl", funcref#Function('return expand("%")')]]})})
call actions#AddAction('gcc -gdbb current file', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [[], ["gcc", '-o', funcref#Function('return expand("%:r:t")'), '-ggdb', '-O0', funcref#Function('return expand("%")')]]})})
call actions#AddAction('g++ -gdbb current file', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [[], ["g++", '-o', funcref#Function('return expand("%:r:t")'), '-ggdb', '-O0', funcref#Function('return expand("%")')]]})})
call actions#AddAction('shebang (run this script)', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [[], [funcref#Function('return expand("%:p")')]]})})


call actions#AddAction('run ddc background', {'action': funcref#Function('actions_more#RunDDCRHS', {'args': [1]})})

call actions#AddAction('run ruby background', {'action': funcref#Function('actions_more#RunRUBYRHS', {'args': [1, funcref#Function('return ["ruby", expand("%")]')]})})
call actions#AddAction('run rspec background', {'action': funcref#Function('actions_more#RunRUBYRHS', {'args': [1, funcref#Function('return ["rspec", expand("%")]')]})})

for cmd in ['rake', 'drake', 'make']
  call actions#AddAction(cmd.' -j custom error format', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [[s:set_efm], [cmd, '-j', funcref#Function('return split(system("nproc"), "\n")[0]')]]})})
endfor

call actions#AddAction('run php background', {'action': funcref#Function('actions_more#RunPHPRHS', {'args': [1]})})
call actions#AddAction('run python background', {'action': funcref#Function('actions_more#RunPythonRHS', {'args': [1]})})
call actions#AddAction('run python using make', {'action': funcref#Function('actions_more#RunPythonRHS', {'args': [0]})})


call actions#AddAction('sass', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [[], ["sass", funcref#Function('return expand("%")'), funcref#Function('return expand("%:r:t").".css"')]]})})
call actions#AddAction('haml', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [['set efm=Syntax\ error\ on\ line\ %l:%m,Haml\ error\ on\ line\ %l:%m'], ["haml", funcref#Function('return expand("%")'), funcref#Function('return expand("%:r:t").".html"')]]})})


call actions#AddAction('run rust', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [['set efm=%f:%l:%c%m'], ["rustc", funcref#Function('return expand("%")')]]})})

" most simple gcc/ ocamlopt/ ocamlc/ .. compilers create an executable which
" is named like the current file
call actions#AddAction('run compiler result', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [[], [funcref#Function('return "./".expand("%:r:t")')]]})})

" scala see addon vim-addon-scala
" haxe see addon vim-haxe
"
"
call actions#AddAction('test', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [[], ["g++", '-o', funcref#Function('return expand("%:r:t")'), '-ggdb', '-O0', funcref#Function('return expand("%")')]]})})
