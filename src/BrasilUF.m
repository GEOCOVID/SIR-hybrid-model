function BrasilUF(Tb,codTb,cen,resultPath,T)

BRest=table('Size',[27*T*cen 8],...
    'VariableTypes',{'uint16','uint16','uint64','uint64','uint64','uint64','uint32','uint16'},...
    'VariableNames',{'UF','dia','S','I','R','I_Acum','MunI','cenario'});

num=length(Tb.dia)/cen;
ind=1;
for k=1:cen
    auxTable=Tb((k-1)*num +1:k*num,:);
    for j=1:T
        aux2=ismember(auxTable.dia(:),j);
        auxTable2=auxTable(aux2,2:end);
        for i=1:length(codTb.Cod)
            aux3=ismember(auxTable2.UF(:),codTb.Cod(i));
            auxTable3=auxTable2(aux3,:);
            auxTable3S=sum(auxTable3.S);            BRest.S(ind)=auxTable3S;
            auxTable3I=sum(auxTable3.I);            BRest.I(ind)=auxTable3I;
            auxTable3R=sum(auxTable3.R);            BRest.R(ind)=auxTable3R;
            auxTable3acum=sum(auxTable3.I_Acum);    BRest.I_Acum(ind)=auxTable3acum;
            auxTable3muninf=sum(auxTable3.I>=0.99); BRest.MunI(ind)=auxTable3muninf;
            BRest.UF(ind)=codTb.Cod(i);
            BRest.dia(ind)=j;
            BRest.cenario(ind)=k;
            ind=ind+1;
        end
    end
end
writetable(BRest,[resultPath 'Brasil_UF.csv'],'Delimiter',',');
end
