exec scriptmanager#DefineAndBind('s:c','g:vim_actions', '{}')

let s:c['bindable_keys'] = get(s:c, 'bindable_keys', [ ['<s-f2>', '<f2>'], ['<s-f3>', '<f3>'], ['<s-f4>', '<f4>'], ['<s-f5>', '<f5>'], ['<s-f6>', '<f6>'], ['<s-f7>', '<f7>'] ] )

fun! s:Init()
  for l in s:c['bindable_keys']
    exec 'noremap '.l[0].' :call actions#Bind('.string(l[1]).')<cr>'
  endfor
endf

call s:Init()
