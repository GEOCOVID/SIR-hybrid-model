function Pop=loadEsti(Pop,tb)

    tamanho=length(Pop.Pt);
    Ps=Pop.Pt;
    Pi=zeros(tamanho,1);
    Pr=zeros(tamanho,1);
    Pnw=zeros(tamanho,1);
    for i=1:length(tb.ibgeID)
        id=find(Pop.id==tb.ibgeID(i));
        if ~isempty(id)             % apenas para casos loalizados na tabela
            Pnw(id)=tb.I_reported(i);
            Pi(id)=Pnw(id);
            Ps(id)=Pop.Pt(id)-Pi(id);
            if isnan(tb.beta(i))    % se não tiver ajuste pula o resto da iteração
                continue;
            end
            Ps(id)=tb.S(i);
            Pi(id)=tb.I(i);
            Pr(id)=tb.R(i);
        end
    end
    aux=table('Size',[tamanho 4],'VariableTypes',{'double','double','double','double'},'VariableNames',{'Ps','Pi','Pr','Pnw'});
    aux.Ps=Ps;  aux.Pi=Pi;  aux.Pr=Pr;  aux.Pnw=Pnw;
    Pop=horzcat(Pop,aux);
end