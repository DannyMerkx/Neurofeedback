function [data,labels]= prepData (clsfrData, targets)
data=[];
count=1;
labels=[];
for i=1:size(clsfrData,2)
    for j=1:size(clsfrData{i},2)
        data(:,:,count)= clsfrData{i}{j}.buf;
        labels{count}= targets{i};
        count=count+1;
    end
end
labels=labels';   