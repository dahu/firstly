source ../plugin/firstly.vim
edit test_01_NumToOrd_2.in
:%s/\(.\+\)/\=NumToOrd(submatch(0), 3)/
write test_01_NumToOrd_2.out
quit!
