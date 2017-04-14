set nocompatible

let g:THORIDE_ROOT_DIRECTORY = expand('<sfile>:p:h')

let thoride_configuration_files = [
      \'config/.core.vimrc',
      \'config/.user_settings.vimrc',
      \'config/.editor.vimrc',
      \'config/.plugins.vimrc',
      \'config/.autocommands.vimrc',
      \'config/.commands.vimrc',
      \'config/.python.vimrc'
      \]

for file in thoride_configuration_files
  execute('source' . g:THORIDE_ROOT_DIRECTORY . '/' . file)
endfor
