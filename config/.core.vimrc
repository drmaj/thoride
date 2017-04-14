" core variables
let g:THORIDE_CONFIG_DIRECTORY = g:THORIDE_ROOT_DIRECTORY . '/' . 'config'

" setup runtime default path without ~/.vim folder
let &runtimepath = printf('%s/vimfiles,%s,%s/vimfiles/after', $VIM, $VIMRUNTIME, $VIM)

" trigger pathogen
execute('source' . g:THORIDE_ROOT_DIRECTORY . '/plugins/vim-pathogen/autoload/pathogen.vim')

execute pathogen#infect(
\   g:THORIDE_ROOT_DIRECTORY                    . '/' . '{}',
\   g:THORIDE_ROOT_DIRECTORY . '/' . 'colors'   . '/' . '{}',
\   g:THORIDE_ROOT_DIRECTORY . '/' . 'plugins'   . '/' . '{}',
\)

