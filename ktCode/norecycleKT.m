[data , rows , cols] = loadData('D:\mine_project\code\Matlab\BNT-KT\Question\Q1.txt');
nS = rows * 0.8;
nQ = cols;
[bnet oNodes] = makeBKTmodel(nQ);
bnetLearned = trainBKTmodel(bnet , data , oNodes);