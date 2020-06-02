function [beta,gamma]=montaBeta(stateTb,cityTb,codTb,Pop)
    tam=length(Pop.id);
    beta=zeros(tam,1);
    gamma=zeros(tam,1);

    for i=1:tam
        takeCity=0;
        takeState=0;
        takeCountry=0;
        if ismember(Pop.id(i),cityTb.ibgeID)
            idC=find(ismember(cityTb.ibgeID,Pop.id(i)));
            if cityTb.I_reported(idC)>=75
                takeCity=1;
            end
        end
        if ~ismember(Pop.id(i),cityTb.ibgeID) || takeCity==0
            cd=floor(Pop.id(i)/100000);         % pega os dois primeiros dígitos do codigo
            sg=codTb.Sigla(ismember(codTb.Cod,cd));
            idU=find(strcmp(stateTb.state,sg));
            if stateTb.I_reported(idU)>=75
                takeState=1;
            else
                takeCountry=1;
                idB=find(strcmp(stateTb.state,'BR'));
             end
        end
        
        if takeCity
           beta(i)=cityTb.beta(idC)/Pop.Pt(i);   % Divide Beta pela população uma vez que os valores de S,I e R não são frações
           gamma(i)=cityTb.gamma(idC);
        end
        if takeState
           beta(i)=stateTb.beta(idU)/Pop.Pt(i);   % Divide Beta pela população uma vez que os valores de S,I e R não são frações
           gamma(i)=stateTb.gamma(idU);
        end
        if takeCountry
           beta(i)=stateTb.beta(idB)/Pop.Pt(i);   % Divide Beta pela população uma vez que os valores de S,I e R não são frações
           gamma(i)=stateTb.gamma(idB);
        end
    end    
end