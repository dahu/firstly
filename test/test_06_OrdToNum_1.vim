source ../plugin/firstly.vim
edit test_06_OrdToNum_1.in
:%s/\(.\+\)/\=OrdToNum(submatch(0))/
write test_06_OrdToNum_1.out
quit!
