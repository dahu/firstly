source ../plugin/firstly.vim
edit test_08_OrdToOrdinal_1.in
:%s/\(.\+\)/\=OrdToOrdinal(submatch(0))/
write test_08_OrdToOrdinal_1.out
quit!
