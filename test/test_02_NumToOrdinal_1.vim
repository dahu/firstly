source ../plugin/firstly.vim
edit test_02_NumToOrdinal_1.in
:%s/\(.\+\)/\=NumToOrdinal(submatch(0))/
write test_02_NumToOrdinal_1.out
quit!
