" ============================================================================
" File:        firstly.vim
" Description: Convert between cardinal, ordinal and written numbers
" Author:      Barry Arthur <barry dot arthur at gmail dot com>
" Last Change: 9 August, 2010
" Website:     http://github.com/dahu/Firstly
" Depends:     NumberToEnglish (http://www.vim.org/scripts/script.php?script_id=2561)
"
" See firstly.txt for help by doing:
"
" :helptags ~/.vim/doc
" :help Firstly
"
" Licensed under the same terms as Vim itself.
" ============================================================================
let s:Firstly_version = '0.0.2'  " beta testing

" History
" * v0.0.2 - Ready for testing
"   * Handles the twelve conversions between cardinal, ordinal, ord and
"     written forms of numnbers.
" * v0.0.1 - Initial Release
"   * Handles cardinal -> ordinal (short (1st) and long (first) forms)
"
" TODO
" * Provide maps for
"   * cardinal -> short ordinal          (? <leader>fco)
"   * cardinal -> long ordinal           (? <leader>fcO)
"   * ordinal -> cardinal                (? <leader>foc)
"   * toggle between these three states  (? <leader>ft)
" * Provide maps for
"   * <leader><c-a> to increment any type
"   * <leader><c-x> to decrement any type

" Setup {{{1
let s:old_cpo = &cpo
set cpo&vim

" Private Data & Functions {{{1

let s:numberToOrdinalSuffix = [
      \ 'th',
      \ 'st',
      \ 'nd',
      \ 'rd',
      \ 'th',
      \ 'th',
      \ 'th',
      \ 'th',
      \ 'th',
      \ 'th' ]

let s:numberToOrdinal = {
      \ 'zero'      : 'zeroth',
      \ 'one'       : 'first',
      \ 'two'       : 'second',
      \ 'three'     : 'third',
      \ 'four'      : 'fourth',
      \ 'five'      : 'fifth',
      \ 'six'       : 'sixth',
      \ 'seven'     : 'seventh',
      \ 'eight'     : 'eighth',
      \ 'nine'      : 'ninth',
      \ 'ten'       : 'tenth',
      \ 'eleven'    : 'eleventh',
      \ 'twelve'    : 'twelfth',
      \ 'thirteen'  : 'thirteenth',
      \ 'fourteen'  : 'fourteenth',
      \ 'fifteen'   : 'fifteenth',
      \ 'sixteen'   : 'sixteenth',
      \ 'seventeen' : 'seventeenth',
      \ 'eighteen'  : 'eighteenth',
      \ 'nineteen'  : 'nineteenth',
      \ 'twenty'    : 'twentieth',
      \ 'thirty'    : 'thirtieth',
      \ 'forty'     : 'fortieth',
      \ 'fifty'     : 'fiftieth',
      \ 'sixty'     : 'sixtieth',
      \ 'seventy'   : 'seventieth',
      \ 'eighty'    : 'eightieth',
      \ 'ninety'    : 'ninetieth',
      \ 'hundred'   : 'hundredth',
      \ 'thousand'  : 'thousandth',
      \ 'million'   : 'millionth',
      \ 'billion'   : 'billionth' }

let s:ordinalToNum = {
      \ 'zeroth'      : 0,
      \ 'first'       : 1,
      \ 'second'      : 2,
      \ 'third'       : 3,
      \ 'fourth'      : 4,
      \ 'fifth'       : 5,
      \ 'sixth'       : 6,
      \ 'seventh'     : 7,
      \ 'eighth'      : 8,
      \ 'ninth'       : 9,
      \ 'tenth'       : 10,
      \ 'eleventh'    : 11,
      \ 'twelfth'     : 12,
      \ 'thirteenth'  : 13,
      \ 'fourteenth'  : 14,
      \ 'fifteenth'   : 15,
      \ 'sixteenth'   : 16,
      \ 'seventeenth' : 17,
      \ 'eighteenth'  : 18,
      \ 'nineteenth'  : 19,
      \ 'twentieth'   : 20,
      \ 'thirtieth'   : 30,
      \ 'fortieth'    : 40,
      \ 'fiftieth'    : 50,
      \ 'sixtieth'    : 60,
      \ 'seventieth'  : 70,
      \ 'eightieth'   : 80,
      \ 'ninetieth'   : 90,
      \ 'hundredth'   : 100,
      \ 'thousandth'  : 1000,
      \ 'millionth'   : 1000000,
      \ 'billionth'   : 1000000000 }

let s:numberToNum = {
      \ "zero"        : 0,
      \ "one"         : 1,
      \ "two"         : 2,
      \ "three"       : 3,
      \ "four"        : 4,
      \ "five"        : 5,
      \ "six"         : 6,
      \ "seven"       : 7,
      \ "eight"       : 8,
      \ "nine"        : 9,
      \ "ten"         : 10,
      \ "eleven"      : 11,
      \ "twelve"      : 12,
      \ "thirteen"    : 13,
      \ "fourteen"    : 14,
      \ "fifteen"     : 15,
      \ "sixteen"     : 16,
      \ "seventeen"   : 17,
      \ "eighteen"    : 18,
      \ "nineteen"    : 19,
      \ "twenty"      : 20,
      \ "thirty"      : 30,
      \ "forty"       : 40,
      \ "fifty"       : 50,
      \ "sixty"       : 60,
      \ "seventy"     : 70,
      \ "eighty"      : 80,
      \ "ninety"      : 90,
      \ "hundred"     : 100,
      \ "thousand"    : 1000,
      \ "million"     : 1000000,
      \ "billion"     : 1000000000}

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
  if match(a:str, '^-\?\d\+$') == -1
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
  if num =~ '^$'
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

" CombineNumberSequence([2, 100, 30, 8]) => 238
" Following function converted to VimL from perl.
" Original algorithm and code taken from:
" http://blog.cordiner.net/2010/01/02/parsing-english-numbers-with-perl/
function! s:CombineNumberSequence(numbers)
  let prior = 0
  let total = 0
  let length = len(a:numbers)
  let i = 0

  while i < length
    if prior == 0
      let prior = a:numbers[i]
    elseif prior > a:numbers[i]
      let prior += a:numbers[i]
    else
      let prior = prior * a:numbers[i]
    endif

    if (a:numbers[i] >= 1000) || (i == (length - 1))
      let total += prior
      let prior = 0
    endif
    let i += 1
  endwhile
  return total
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
    let result = a:num . s:numberToOrdinalSuffix[0]
  else
    let result = a:num . s:numberToOrdinalSuffix[a:num[len(a:num)-1]]
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

" Naieve parser for recognising English written numbers, like 'twenty one'.
" To say that this algorithm is forgiving is generous. It'll take any string
" of ill-formed numeric words and assume they represent a valid number.
" Let me say that another way: This 'parser' makes NO attempt to verify that
" what it's parsing is a valid number. You could ask it to parse "twenty and
" four" and it will spit out 24.
"03: one -> 1
function! s:_NumberToNum(engnum, ...)
  let negative = match(a:engnum, 'negative', '', 'i')
  let result = s:CombineNumberSequence(map(filter(split(tolower(a:engnum), '[ ,.-]\|\<and\>\|\<negative\>'), 'v:val != ""'), 's:numberToNum[v:val]'))
  if negative != -1
    return -result
  else
    return result
  endif
endfunction

function! NumberToNum(engnum, ...)
  return call(function('s:Wordly'), ['s:_NumberToNum', a:engnum] + a:000)
endfunction

"04: one -> 1st
function! s:_NumberToOrd(engnum, ...)
  return NumToOrd(NumberToNum(a:engnum))
endfunction

function! NumberToOrd(engnum, ...)
  return call(function('s:Wordly'), ['s:_NumberToOrd', a:engnum] + a:000)
endfunction

"05: one -> first
function! s:_NumberToOrdinal(engnum, ...)
  let lastword = matchstr(a:engnum, '\v(<\w+>)$')
  return substitute(a:engnum, '\v<\w+>$', s:numberToOrdinal[lastword], '')
endfunction

function! NumberToOrdinal(engnum, ...)
  return call(function('s:Wordly'), ['s:_NumberToOrdinal', a:engnum] + a:000)
endfunction

"06: 1st -> 1
function! s:_OrdToNum(ord, ...)
  return matchstr(a:ord, '^\(\d\+\)\ze\c[' . join(s:numberToOrdinalSuffix, '|') .']')
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

"09: first -> 1
function! s:_OrdinalToNum(engnum, ...)
  return NumberToNum(OrdinalToNumber(a:engnum))
endfunction

function! OrdinalToNum(engnum, ...)
  return call(function('s:Wordly'), ['s:_OrdinalToNum', a:engnum] + a:000)
endfunction

"10: first -> one
function! s:_OrdinalToNumber(engnum, ...)
  let lastword = matchstr(a:engnum, '\v(<\w+>)$')
  return substitute(a:engnum, '\v<\w+>$', NumToNumber(s:ordinalToNum[lastword]), '')
endfunction

function! OrdinalToNumber(engnum, ...)
  return call(function('s:Wordly'), ['s:_OrdinalToNumber', a:engnum] + a:000)
endfunction

"11: first -> 1st
function! s:_OrdinalToOrd(engnum, ...)
  return NumToOrd(OrdinalToNum(a:engnum))
endfunction

function! OrdinalToOrd(engnum, ...)
  return call(function('s:Wordly'), ['s:_OrdinalToOrd', a:engnum] + a:000)
endfunction

" Teardown:{{{1
"reset &cpo back to user's setting
let &cpo = s:old_cpo

" vim: set sw=2 sts=2 et fdm=marker:
