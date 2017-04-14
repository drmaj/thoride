" setup all the plugin configs

for plugin in split(globpath(g:THORIDE_CONFIG_DIRECTORY . '/plugins', '*.plugin'), '\n')
    execute('source ' . plugin)
endfor