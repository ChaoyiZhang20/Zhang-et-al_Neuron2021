function FreqByBin=Freq(spk, range, Bin, smoothN)
FreqByBin=zeros(1,round((range(2)-range(1))/Bin));
time=[(range(1)+Bin):Bin:range(2)];
for ii=1:length(time)
    BinSpk=spk(spk>time(ii)-Bin & spk<=time(ii));
    if ~isempty(BinSpk)
        FreqByBin(ii)=length(BinSpk)/Bin;
    else
    end
end

FreqByBin=movmean(FreqByBin, smoothN);

end
