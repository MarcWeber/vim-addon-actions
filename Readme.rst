vim-addon-actions
=================


Example usage adding an action running make: >

    " ~/.vimrc:
    call actions#AddAction("run make",{
      \ 'buffer':'<buffer>'\
      \, 'action':'make'
      \, 'follow_up': 'run compiler result'
      \ })

    " while running vim one of:
    :ActionOnWrite(Buffer)[!]
    :MapAction

then select the action to run, select lhs mapping, be happy.

Continue reading at https://github.com/MarcWeber/vim-addon-actions/blob/master/doc/vim-addon-actions.txt
