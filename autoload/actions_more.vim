
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
