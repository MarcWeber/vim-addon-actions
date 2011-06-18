
fun! actions_more#RunPythonRHS(background)
  " errorformat taken from http://www.vim.org/scripts/script.php?script_id=477
  let ef= 
	\  '%A\ \ File\ \"%f\"\\\,\ line\ %l\\\,%m,'
	\ .'%C\ \ \ \ %.%#,'
	\ .'%+Z%.%#Error\:\ %.%#,'
	\ .'%A\ \ File\ \"%f\"\\\,\ line\ %l,'
	\ .'%+C\ \ %.%#,'
	\ .'%Z%m,'


  let args = ["python"] + [ expand('%')]
  let args = eval(input('command args: ', string(args)))
  return a:background
    \ ? "call bg#RunQF(".string(args).", 'c', ".string(ef).")"
    \ : ['exec "set efm='.ef.'" ',"set makeprg=python", "make ".join(args, ' ') ]
  " think about proper quoting in : case
endf


fun! actions_more#RunPHPRHS(background)
  " errorformat taken from http://www.vim.org/scripts/script.php?script_id=477
  let ef= 
        \  '%EFatal\ error:\ %m\ in\ %f\ on\ line\ %l,'
        \ .'%m\ %f:%l,'
        \ .'%f:%l,'
        \ .'%m\ %f:%l,'
        \ .'%E<b>Parse\ error</b>:\ %m\ in\ <b>%f</b>\ on\ line\ <b>%l</b><br\ />,'
        \ .'%EPHP\ Fatal\ error:\ %m\ in\ %f\ on\ line\ %l,'
        \ .'%EPHP\ Parse\ error:\ %m\ in\ %f\ on\ line\ %l,'
        \ .'%EFatal\ error:\ %m\ in\ %f:%l,'
        \ .'%W<b>Notice</b>:\ %m\ in\ <b>%f</b>\ on\ line\ <b>%l</b><br\ />,'
        \ .'%EParse\ error:\ %m\ in\ %f\ on\ line\ %l,'
        \ .'%E#0\ %f(%l):\ %m,'
        \ .'%E#1\ %f(%l):\ %m,'
        \ .'%E#2\ %f(%l):\ %m,'
        \ .'%E#3\ %f(%l):\ %m,'
        \ .'%E#4\ %f(%l):\ %m,'
        \ .'%E#5\ %f(%l):\ %m,'
        \ .'%E#6\ %f(%l):\ %m,'
        \ .'%E#7\ %f(%l):\ %m,'
        \ .'%E#8\ %f(%l):\ %m,'
        \ .'%E#9\ %f(%l):\ %m,'
        \ .'%E#10\ %f(%l):\ %m,'
        \ .'%E#11\ %f(%l):\ %m,'
        \ .'%E#12\ %f(%l):\ %m,'
        \ .'%E#13\ %f(%l):\ %m,'
        \ .'%E#14\ %f(%l):\ %m,'
        \ .'%E#15\ %f(%l):\ %m,'
        \ .'%E#16\ %f(%l):\ %m,'
        \ .'%E#17\ %f(%l):\ %m,'
        \ .'%E#18\ %f(%l):\ %m,'
        \ .'%E#19\ %f(%l):\ %m,'
        \ .'%E#20\ %f(%l):\ %m,'
        \ .'%E#21\ %f(%l):\ %m,'
        \ .'%E#22\ %f(%l):\ %m,'
        \ .'%E#23\ %f(%l):\ %m,'
        \ .'%E#24\ %f(%l):\ %m,'
        \ .'%E#25\ %f(%l):\ %m,'
        \ .'%E#26\ %f(%l):\ %m,'
        \ .'%WNotice:\ %m\ in\ %f</b>\ on\ line\ %l,'
        \ .'%m.\ %f:%l,'
        \ .'%f:%l'


  let args = ["php"] + [ expand('%')]
  let args = eval(input('command args: ', string(args)))
  return a:background
    \ ? "call bg#RunQF(".string(args).", 'c', ".string(ef).")"
    \ : ['exec "set efm='.ef.'" ',"set makeprg=python", "make ".join(args, ' ') ]
  " think about proper quoting in : case
endf
