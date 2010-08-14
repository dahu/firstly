source ../plugin/firstly.vim
edit test_01_NumToOrd_3.in
:%s/\(.\+\)/\=NumToOrd(submatch(0), 1)/
write test_01_NumToOrd_3.out
quit!
