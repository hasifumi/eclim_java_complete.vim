let s:source = {
      \ 'name': 'eclim_java_complete',
      \ 'kind': 'ftplugin',
      \ 'filetypes': { 'java': 1 },
      \ }
 
function! s:source.initialize()
endfunction
 
function! s:source.finalize()
endfunction
 
function! s:source.get_keyword_pos(cur_text)
  if !eclim#project#util#IsCurrentFileInProject(0)
    return a:cur_text ? -1 : []
  endif

  call eclim#lang#SilentUpdate(1)

	let line = getline('.')
 
	let start = col('.') - 1

  if line[start] == "." && line[start - 1] != "."
    let start -= 1
  endif

  while start > 0 && line[start - 1] =~ '\w'
    let start -= 1
  endwhile

	return start
endfunction
 
function! s:source.get_complete_words(cur_keyword_pos, cur_keyword_str)
  call eclim#lang#SilentUpdate(1)

  let s:project = eclim#project#util#GetCurrentProjectName()
  let s:file = eclim#lang#SilentUpdate(1,0)
  if s:file == ''
    return []
  endif
  let s:offset = eclim#util#GetOffset() + len(a:cur_keyword_str)
  let s:encoding = eclim#util#GetEncoding()
  if &completeopt !~ 'preview' && &completeopt =~ 'menu'
    let s:layout = 'standard'
  else
    let s:layout = 'compact'
  endif

  let s:complete_command = 
        \ '-command java_complete'
        \ ' -p ' . s:project . 
        \ ' -f ' . s:file .
        \ ' -o ' . s:offset .
        \ ' -e ' . s:encoding .
        \ ' -l ' . s:layout
  "echo complete_command

  let s:completions = []
  call add(s:completions, {'word': 'test', 'menu': 'test'})
  "let response = eclim#Execute(complete_command)
  "if type(response) != g:DICT_TYPE
  "  return
  ""else
  ""  echo response
  "endif

  return s:completions
endfunction

function! neocomplcache#sources#eclim_java_complete#define()
	return s:source
endfunction
