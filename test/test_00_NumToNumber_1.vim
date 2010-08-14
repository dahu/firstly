source ../plugin/firstly.vim
edit test_00_NumToNumber_1.in
:%s/\(.\+\)/\=NumToNumber(submatch(0))/
write test_00_NumToNumber_1.out
quit!
