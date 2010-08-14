source ../plugin/firstly.vim
edit test_01_NumToOrd_1.in
:%s/\(.\+\)/\=NumToOrd(submatch(0))/
write test_01_NumToOrd_1.out
quit!
