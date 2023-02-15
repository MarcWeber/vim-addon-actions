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
call actions#AddAction('dart2js', {'action': funcref#Function('actions#CompileRHSDart2JS')})

call actions#AddAction('bucklesscript standard', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [['Errorformat bucklescript ocaml_long'], ["npm", "run", "build"]]})})
call actions#AddAction('dart2js', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [['Errorformat dart'], ["dart2js", funcref#Function('return expand("%")'), '-o', funcref#Function('return expand("%:r").".js"')]]})})
call actions#AddAction('cmake', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [['set efm=CMake\ Error\ at\ %f:%l\ %m,%f:%l:'], funcref#Function('return ["cmake","../"]')]})})

" perl: not using all of $VIMRUNTIME/compiler/perl.vim because if you dont'
" flush valuable stdout output could be lost cause errors appear before stdout
" dump and the compiler error format drops those lines
call actions#AddAction('webpack', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [['Errorformat webpack'], ["webpack"]]})})
call actions#AddAction('fuse', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [['Errorformat typescript'], ["node", "fuse"]]})})
call actions#AddAction('tern-lint', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [['Errorformat webpack'], ["tern-lint"]]})})

call actions#AddAction('node ts-node/transpile', {'action': funcref#Function('actions#CompileRHSNodeTS', {'args': [1, []]})})
call actions#AddAction('node ts-node', {'action': funcref#Function('actions#ComopileRHSNodeTS', {'args': [0, []]})})
call actions#AddAction('node ts-node/transpile --preserve-symlinks', {'action': funcref#Function('actions#CompileRHSNodeTS', {'args': [1, ['--preserve-symlinks']]})})
call actions#AddAction('node ts-node --preserve-symlinsk', {'action': funcref#Function('actions#ComopileRHSNodeTS', {'args': [0, ['--preserve-symlinks']]})})

call actions#AddAction('ts-node transpile', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [['Errorformat ts-node'], ["ts-node", '-T', funcref#Function('return expand("%")')]]})})
call actions#AddAction('ts-node', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [['Errorformat ts-node'], ["ts-node", funcref#Function('return expand("%")')]]})})

call actions#AddAction('tslint', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [['Errorformat tslint'], ["tslint", "-p", "."]]})})
call actions#AddAction('tslint fix', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [['Errorformat tslint'], ["tslint", "--fix", "-p", "."]]})})
call actions#AddAction('tsc', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [['set efm=%f(%l\\\,%c):%m'], ["tsc", "-p", "."]]})})
call actions#AddAction('perl current file', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [['set efm=\%m\ at\ %f\ line\ %l.,\%m\ at\ %f\ line\ %l\,\ at\ end\ of\ line,%m\ at\ %f\ line\ %l\,\ near'], ["perl", funcref#Function('return expand("%")')]]})})
call actions#AddAction('gcc -gdbb current file', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [[], ["gcc", '-o', funcref#Function('return expand("%:r:t")'), '-ggdb', '-O0', funcref#Function('return expand("%")')]]})})
call actions#AddAction('g++ -gdbb current file', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [[], ["g++", '-o', funcref#Function('return expand("%:r:t")'), '-ggdb', '-O0', funcref#Function('return expand("%")')]]})})
call actions#AddAction('shebang (run this script)', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [[], [funcref#Function('return expand("%:p")')]]})})

call actions#AddAction('rubber current file', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [[], ["rubber", funcref#Function('return expand("%")')]]})})
call actions#AddAction('rubber pdf current file', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [[], ["rubber", '--pdf', funcref#Function('return expand("%")')]]})})
call actions#AddAction('latex current file', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [[], ["latex", funcref#Function('return expand("%")')]]})})
call actions#AddAction('pdflatex current file', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [[], ["pdflatex", funcref#Function('return expand("%")')]]})})

call actions#AddAction('run ddc background', {'action': funcref#Function('actions_more#RunDDCRHS', {'args': [1]})})

call actions#AddAction('run ruby background', {'action': funcref#Function('actions_more#RunRUBYRHS', {'args': [1, funcref#Function('return ["ruby", expand("%")]')]})})
call actions#AddAction('run rspec background', {'action': funcref#Function('actions_more#RunRUBYRHS', {'args': [1, funcref#Function('return ["rspec", expand("%")]')]})})

for cmd in ['rake', 'drake', 'make']
  call actions#AddAction(cmd.' -j custom error format', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [[s:set_efm], [cmd, '-j', funcref#Function('return split(system("nproc"), "\n")[0]')]]})})
endfor

call actions#AddAction('run php background', {'filetype_regex' : 'php$', 'action': funcref#Function('actions_more#RunPHPRHS', {'args': [1]})})
call actions#AddAction('run python background', {'action': funcref#Function('actions_more#RunPythonRHS', {'args': [1]})})
call actions#AddAction('run python using make', {'action': funcref#Function('actions_more#RunPythonRHS', {'args': [0]})})


call actions#AddAction('sass',   {'action': funcref#Function('actions#CompileRHSSimple', {'args': [[], ["sass", funcref#Function('return expand("%")'), funcref#Function('return expand("%:r:t").".css"')]]})})
call actions#AddAction('haml',   {'action': funcref#Function('actions#CompileRHSSimple', {'args': [['set efm=Syntax\ error\ on\ line\ %l:%m,Haml\ error\ on\ line\ %l:%m'], ["haml", funcref#Function('return expand("%")'), funcref#Function('return expand("%:r:t").".html"')]]})})
call actions#AddAction('nodejs', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [['set efm=%f:%l'], ["node", funcref#Function('return expand("%")')]]})})
call actions#AddAction('coffee', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [['call vim_addon_errorformats#SetErrorFormat("coffee")'], ["coffee", funcref#Function('return expand("%")')]]})})
call actions#AddAction('coffee bare', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [['call vim_addon_errorformats#SetErrorFormat("coffee")'], ["coffee", "-b", funcref#Function('return expand("%")')]]})})
call actions#AddAction('grunt test', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [['call vim_addon_errorformats#SetErrorFormat("grunt coffee")'], ["grunt", "--stack", "--no-color", "test"]]})})
" call actions#AddAction('cofeescript_compile_and_run_nodejs', {'action': funcref#Function('actions#CompileRHSSimpleMany', {'args': [ {'cmds': ['set efm=%f:%l'], 'cmd': ["node", funcref#Function('return expand("%")')]}, {'cmds': ['set efm=%f:%l'], 'cmd': ["node", funcref#Function('return expand("%")')]} ]})})


call actions#AddAction('run rust', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [['Errorformat rust'], ["rustc", funcref#Function('return expand("%")')]]})})
call actions#AddAction('run cargo build', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [['Errorformat rust'], ["cargo", "build"]]})})

" most simple gcc/ ocamlopt/ ocamlc/ .. compilers create an executable which
" is named like the current file
call actions#AddAction('run compiler result', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [[], [funcref#Function('return "./".expand("%:r:t")')]]})})

" scala see addon vim-addon-scala
" haxe see addon vim-haxe
"
"
call actions#AddAction('test', {'action': funcref#Function('actions#CompileRHSSimple', {'args': [[], ["g++", '-o', funcref#Function('return expand("%:r:t")'), '-ggdb', '-O0', funcref#Function('return expand("%")')]]})})
