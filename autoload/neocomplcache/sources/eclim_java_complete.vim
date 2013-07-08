let s:source = {
      \ 'name': 'eclim_java_complete',
      \ 'kind': 'ftplugin',
      \ 'filetypes': { 'java': 1 },
      \ }
 
function! s:source.initialize()
  "
endfunction
 
function! s:source.finalize()
endfunction
 
function! s:source.get_keyword_pos(cur_text)
  if !eclim#project#util#IsCurrentFileInProject(0)
    "return a:cur_text ? -1 : []
    return
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
        \ '-command java_complete' .
        \ ' -p ' . s:project . 
        \ ' -f ' . s:file .
        \ ' -o ' . s:offset .
        \ ' -e ' . s:encoding .
        \ ' -l ' . s:layout

  let s:completions = []
"  call add(s:completions, {'word': 'test', 'menu': 'test'})
  let response = eclim#Execute(s:complete_command)
  if type(response) != g:DICT_TYPE
    return
"  else
"    echo response
  endif

"    if has_key(response, 'imports') && len(response.imports)
"      let imports = response.imports
"      if exists('g:TestEclimWorkspace') " allow this to be tested somewhat
"        call eclim#java#complete#ImportThenComplete(imports)
"      else
"        let func = "eclim#java#complete#ImportThenComplete(" . string(imports) . ")"
"        call feedkeys("\<c-e>\<c-r>=" . func . "\<cr>", 'n')
"      endif
"      " prevents supertab's completion chain from attempting the next
"      " completion in the chain.
"      return -1
"    endif
"
  if has_key(response, 'error') && len(response.completions) == 0
    "call eclim#util#EchoError(response.error.message)
    "return -1
    return
  endif

  " if the word has a '.' in it (like package completion) then we need to
  " strip some off according to what is currently in the buffer.
  let prefix = substitute(getline('.'),
    \ '.\{-}\([[:alnum:].]\+\%' . col('.') . 'c\).*', '\1', '')

  " as of eclipse 3.2 it will include the parens on a completion result even
  " if the file already has them.
  let open_paren = getline('.') =~ '\%' . col('.') . 'c\s*('
  let close_paren = getline('.') =~ '\%' . col('.') . 'c\s*(\s*)'

  " when completing imports, the completions include ending ';'
  let semicolon = getline('.') =~ '\%' . col('.') . 'c\s*;'

  for result in response.completions
    let word = result.completion

    " strip off prefix if necessary.
    if word =~ '\.'
      let word = substitute(word, prefix, '', '')
    endif

    " strip off close paren if necessary.
    if word =~ ')$' && close_paren
      let word = strpart(word, 0, strlen(word) - 1)
    endif

    " strip off open paren if necessary.
    if word =~ '($' && open_paren
      let word = strpart(word, 0, strlen(word) - 1)
    endif

    " strip off semicolon if necessary.
    if word =~ ';$' && semicolon
      let word = strpart(word, 0, strlen(word) - 1)
    endif

"      " if user wants case sensitivity, then filter out completions that don't
"      " match
"      if g:EclimJavaCompleteCaseSensitive && a:base != ''
"        if word !~ '^' . a:base . '\C'
"          continue
"        endif
"      endif
"
    let menu = result.menu
    let info = eclim#html#util#HtmlToText(result.info)

    let dict = {
        \ 'word': word,
        \ 'menu': menu,
        \ 'info': info,
        \ 'kind': result.type,
        \ 'dup': 1,
      \ }
"        \ 'icase': !g:EclimJavaCompleteCaseSensitive,

    call add(s:completions, dict)
  endfor

  return s:completions
endfunction

function! neocomplcache#sources#eclim_java_complete#define()
	return s:source
endfunction


"" ImportThenComplete {{{
"" Called by CodeComplete when the completion depends on a missing import.
"function! eclim#java#complete#ImportThenComplete(choices)
"  let choice = ''
"  if len(a:choices) > 1
"    let choice = eclim#java#import#ImportPrompt(a:choices)
"  elseif len(a:choices)
"    let choice = a:choices[0]
"  endif
"
"  if choice != ''
"    call eclim#java#import#Import(choice)
"    call feedkeys("\<c-x>\<c-u>", 'tn')
"  endif
"  return ''
"endfunction " }}}

" vim:ft=vim:fdm=marker

