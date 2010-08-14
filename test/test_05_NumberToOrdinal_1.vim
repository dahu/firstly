source ../plugin/firstly.vim
edit test_05_NumberToOrdinal_1.in
:%s/\(.\+\)/\=NumberToOrdinal(submatch(0))/
write test_05_NumberToOrdinal_1.out
quit!
