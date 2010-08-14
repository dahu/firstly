" ============================================================================
" File:        firstly.vim
" Description: A Vim plugin to convert between cardinal and ordinal numbers
" Author:      Barry Arthur <barry dot arthur at gmail dot com>
" Last Change: 9 August, 2010
" Website:     http://github.com/dahu/Firstly
" Depends:     NumberToEnglish (http://www.vim.org/scripts/script.php?script_id=2561)
"
" See firstly.txt for help.  This can be accessed by doing:
"
" :helptags ~/.vim/doc
" :help Firstly
"
" Licensed under the same terms as Vim itself.
" ============================================================================
let s:Firstly_version = '0.0.1'  " alpha, unreleased

" History
" * v0.0.1 - Initial Release
"   * Handles cardinal -> ordinal (short (1st) and long (first) forms)
"
" TODO
" * Implement ordinal -> cardinal
" * Provide maps for
"   * cardinal -> short ordinal          (? <leader>fco)
"   * cardinal -> long ordinal           (? <leader>fcO)
"   * ordinal -> cardinal                (? <leader>foc)
"   * toggle between these three states  (? <leader>ft)

" Setup {{{1
let s:old_cpo = &cpo
set cpo&vim

" Private Functions {{{1
let g:numberToOrdinalSuffix = [ 'th', 'st', 'nd', 'rd', 'th', 'th', 'th', 'th', 'th', 'th' ]
let g:numberToOrdinal = {
      \ 'one' : 'first',
      \ 'two' : 'second',
      \ 'three' : 'third',
      \ 'four' : 'fourth',
      \ 'five' : 'fifth',
      \ 'six' : 'sixth',
      \ 'seven' : 'seventh',
      \ 'eight' : 'eighth',
      \ 'nine' : 'ninth',
      \ 'ten' : 'tenth',
      \ 'eleven' : 'eleventh',
      \ 'twelve' : 'twelfth',
      \ 'thirteen' : 'thirteenth',
      \ 'fourteen' : 'fourteenth',
      \ 'fifteen' : 'fifteenth',
      \ 'sixteen' : 'sixteenth',
      \ 'seventeen' : 'seventeenth',
      \ 'eighteen' : 'eighteenth',
      \ 'nineteen' : 'nineteenth',
      \ 'twenty' : 'twentieth',
      \ 'thirty' : 'thirtieth',
      \ 'forty' : 'fortieth',
      \ 'fifty' : 'fiftieth',
      \ 'sixty' : 'sixtieth',
      \ 'seventy' : 'seventieth',
      \ 'eighty' : 'eightieth',
      \ 'ninety' : 'ninetieth',
      \ 'hundred' : 'hundredth',
      \ 'thousand' : 'thousandth',
      \ 'million' : 'millionth',
      \ 'billion' : 'billionth'}

" Capitalize(string, mode)
" mode:
"   0 - all lower-case
"   1 - Leading capital
"   2 - Title Case
"   3 - ALL UPPER-CASE
function! s:Capitalize(str, ...)
  let result = a:str
  let mode = 0
  if a:0 == 1
    let mode = a:1
  endif
  if mode == 0
    let result = tolower(result)
  elseif mode == 1
    let result = substitute(result, '\(\a\)', '\U\1', '')
  elseif mode == 2
    let result = substitute(result, '\<\(\a\)', '\U\1', 'g')
  elseif mode == 3
    let result = toupper(result)
  endif
  return result
endfunction

function! s:StrToNum(str)
  if match(a:str, '^\d\+$') == -1
    return ''
  endif
  return str2nr(a:str)
endfunction

" Wrapper for functions converting from a number
" Handles non-numeric arguments gracefully
" Calls the provided real function on the number
" Returns the possibly capitalised value.
function! s:Numerically(funcref, num, ...)
  let num = s:StrToNum(a:num)
  if num == ''
    return ''
  endif
  let result = call(function(a:funcref), [num])
  return call(function('s:Capitalize'), [result] + a:000)
endfunction

" Wrapper for functions converting from a string
" Calls the provided real function on the string
" Returns the possibly capitalised value.
function! s:Wordly(funcref, engnum, ...)
  " following regex to match '^\s*[[:alpha:][:space:]]\+\s*$' is ugly as sin...
  " but the clearer regex constantly failed for some reason... ? (XXX)
  if a:engnum !~ '^\s*\%(\%(\a\)\|\%(\s\)\)\+\s*$'
    return ''
  endif
  let result = call(function(a:funcref), [a:engnum])
  return call(function('s:Capitalize'), [result] + a:000)
endfunction

" Wrapper for functions converting from a num+string
" Calls the provided real function on the num+string
" Returns the possibly capitalised value.
function! s:Ordly(funcref, ord, ...)
  if a:ord !~? '^\s*\d\+[snrt][dht]\s*$'
    return ''
  endif
  let result = call(function(a:funcref), [a:ord])
  return call(function('s:Capitalize'), [result] + a:000)
endfunction

" Public Interface {{{1
" The conversion methods all consist of a pair of functions.
" The s:_Form holds the real conversion method for that operation.
" The NormalForm merely calls the s:_Form with the right wrapper.

"00: 1 -> one
function! s:_NumToNumber(num, ...)
  return NumberToEnglish(a:num)
endfunction

function! NumToNumber(num, ...)
  return call(function('s:Numerically'), ['s:_NumToNumber', a:num] + a:000)
endfunction"

"01: 1 -> 1st
function! s:_NumToOrd(num, ...)
  let result = ''
  if a:num >= 10 && a:num <= 20
    let result = a:num . g:numberToOrdinalSuffix[0]
  else
    let result = a:num . g:numberToOrdinalSuffix[a:num[len(a:num)-1]]
  endif
  return result
endfunction

function! NumToOrd(num, ...)
  return call(function('s:Numerically'), ['s:_NumToOrd', a:num] + a:000)
endfunction

"02: 1 -> first
function! s:_NumToOrdinal(num, ...)
  return call(function('NumberToOrdinal'), [NumberToEnglish(str2nr(a:num))] + a:000)
endfunction

function! NumToOrdinal(num, ...)
  return call(function('s:Numerically'), ['s:_NumToOrdinal', a:num] + a:000)
endfunction

"03: TODO one -> 1
function! s:_NumberToNum(engnum, ...)
endfunction

function! NumberToNum(engnum, ...)
  return call(function('s:Wordly'), ['s:_NumberToNum', a:engnum] + a:000)
endfunction

"04: TODO one -> 1st
function! s:_NumberToOrd(engnum, ...)
endfunction

function! NumberToOrd(engnum, ...)
  return call(function('s:Wordly'), ['s:_NumberToOrd', a:engnum] + a:000)
endfunction

"05: one -> first
function! s:_NumberToOrdinal(engnum, ...)
  let lastword = matchstr(a:engnum, '\v(<\w+>)$')
  return substitute(a:engnum, '\v<\w+>$', g:numberToOrdinal[lastword], '')
endfunction

function! NumberToOrdinal(engnum, ...)
  return call(function('s:Wordly'), ['s:_NumberToOrdinal', a:engnum] + a:000)
endfunction

"06: 1st -> 1
function! s:_OrdToNum(ord, ...)
  return matchstr(a:ord, '^\(\d\+\)\ze\c[' . join(g:numberToOrdinalSuffix, '|') .']')
endfunction

function! OrdToNum(ord, ...)
  return call(function('s:Ordly'), ['s:_OrdToNum', a:ord] + a:000)
endfunction

"07: 1st -> one
function! s:_OrdToNumber(ord, ...)
  return NumberToEnglish(OrdToNum(a:ord))
endfunction

function! OrdToNumber(ord, ...)
  return call(function('s:Ordly'), ['s:_OrdToNumber', a:ord] + a:000)
endfunction

"08: 1st -> first
"Note: doesn't validate ord (so, 3th is tolerated by this function and returns third)
function! s:_OrdToOrdinal(ord, ...)
  return NumToOrdinal(OrdToNum(a:ord))
endfunction

function! OrdToOrdinal(ord, ...)
  return call(function('s:Ordly'), ['s:_OrdToOrdinal', a:ord] + a:000)
endfunction

"09: TODO first -> 1
function! s:_OrdinalToNum(engnum, ...)
endfunction

function! OrdinalToNum(engnum, ...)
  return call(function('s:Wordly'), ['s:_OrdinalToNum', a:engnum] + a:000)
endfunction

"10: TODO first -> one
function! s:_OrdinalToNumber(engnum, ...)
endfunction

function! OrdinalToNumber(engnum, ...)
  return call(function('s:Wordly'), ['s:_OrdinalToNumber', a:engnum] + a:000)
endfunction

"11: TODO first -> 1st
function! s:_OrdinalToOrd(engnum, ...)
endfunction

function! OrdinalToOrd(engnum, ...)
  return call(function('s:Wordly'), ['s:_OrdinalToOrd', a:engnum] + a:000)
endfunction

" Teardown:{{{1
"reset &cpo back to user's setting
let &cpo = s:old_cpo

" vim: set sw=2 sts=2 et fdm=marker:
