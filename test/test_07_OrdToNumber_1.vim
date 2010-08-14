source ../plugin/firstly.vim
edit test_07_OrdToNumber_1.in
:%s/\(.\+\)/\=OrdToNumber(submatch(0))/
write test_07_OrdToNumber_1.out
quit!
