function ym = metrics1(run_id1,run_id2,reshapedMatrix1,reshapedMatrix2,fineSpace,dataTypeOption)
%   ym is the vector of time relative smooth rms by position of fineSpace.
%   reshapedMatrix1 should be the first result of reshapeLDT(d1, times1,
%   link_lengths1, startDate, dataTypeOption); idem for run 2; fineSpace the second result. 
%   The only purpose of run_id as imputs is for legend of plotting.
yx=reshapedMatrix2-reshapedMatrix1;
[ny,nx]=size(yx);
ym=zeros(ny,1);
for y=1:ny
    yx_smoothed=smooth(yx(y,:));
    ym(y,1)=rms(yx_smoothed)*2/mean(reshapedMatrix1(y,:)+reshapedMatrix2(y,:));
end

figure
plot(fineSpace',ym)
xlabel('Position (miles)','Fontsize',28)
legend(['relative RMS by position Run',num2str(run_id2),'-Run',num2str(run_id1)],28)
if strcmp(dataTypeOption, 'velocity')
    ylabel('Relative velocity RMS','Fontsize',28)
    title(['Relative Velocity RMS Comparison of Two Runs'],'Fontsize',32,'Fontweight','bold')
else
    ylabel('Relative density RMS','Fontsize',28)
    title(['Relative Density RMS Comparison of Two Runs'],'Fontsize',32,'Fontweight','bold')
end

end

