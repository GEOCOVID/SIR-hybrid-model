function outTable=Covid19(fileCoord,fileFlux,fileFAviao,fileState,fileCod,fileCity,fileOut,IntervFlux,IntervFluxLock,IntervR0,ssa,T,cen,lockMun)
%%                  CARREGA ARQUIVOS DE ENTRADA
disp('Carregando arquivos de entrada');
tic;
Pop=readtable(fileCoord);           % Tabela com municipios, geocode, Pt e coordenadas
N=length(Pop.id);                   % Quantidade de municipios
ssa=find(Pop.id==ssa);              % Localização de Salvador na Pop
Flux=readtable(fileFlux);           % Tabela com rede de fluxo
Flux.Flux=Flux.Flux/7;              % Divide por 7 pois dados são semanais
stateTb=readtable(fileState);       % Parâmetros estaduais
codTb=readtable(fileCod);           % Cdigos ibge de cada estado
cityTb=readtable(fileCity);         % População de S,I,R por município

if ~isempty(fileFAviao)
    Aviao=readtable(fileFAviao);    % Tabela com rede de fluxo aéreo
    Aviao.Pax=Aviao.Pax/365;        % Divide por 365 pois dados são anuais
else
    Aviao=[];
end

Pop=loadEsti(Pop,cityTb);           % Carrega população estimada de S,I,R
toc;

disp('Montando matriz de fluxo');
tic;
mFlux=doMatFlux(Pop,Flux,Aviao);    % Monta a matriz de fluxo terrestre e aéreo
toc;
%%                      PARAMETROS DO MODELO

disp('Montando parâmetros');
tic;
[beta,gamma]=montaBeta(stateTb,cityTb,codTb,Pop);      % Monta vetor com os betas e gammas para todos os municípios

beta=beta*IntervR0;                             % Aplica intervenção sobre os betas (alteração da quarentena)

iBA=find(ismember(Pop.UF,{'BA'}));

if ~isempty(lockMun)
    locs=find(ismember(Pop.id,lockMun));
    mFluxA=mFlux;
    mFlux=mFlux*IntervFlux;                     % Aplica intervenção sobre toda a matriz
    for h=1:length(locs)                        % Aplica intervenção nos municipios locks
       mFlux(:,locs(h))=mFluxA(:,locs(h))*IntervFluxLock;
       mFlux(locs(h),:)=mFluxA(locs(h),:)*IntervFluxLock;
    end
else
    mFlux=mFlux*IntervFlux;
end

zer=zeros(T,1);
tS=zer;          % Total de suscetíveis
tI=zer;          % Total de Infectados
tR=zer;          % Total de Recuperados
tNw=zer;         % Total acumulado
tMIn=zer;        % Total municipios infectados

BAs=zer;         % Bahia suscetíveis etc
BAi=zer;         
BAr=zer;
BAnw=zer;
BAMIn=zer;

SSAs=zer;         % Salvador suscetíveis etc
SSAi=zer;
SSAr=zer;
SSAnw=zer;

outTable=table('Size',[N*T 8],...               % Criando a tabela de report geral
    'VariableTypes',{'uint32','uint16','uint64','uint64','uint64','uint64','uint16','uint16'},...
    'VariableNames',{'Geocode','dia','S','I','R','I_Acum','cenario','UF'});

lt=1;

auxUF=zeros(length(Pop.UF),1);                  % Troca siglas da UF por código do IBGE
for sig=1:length(codTb.Sigla)
    aux=ismember(Pop.UF,codTb.Sigla(sig));
    auxUF(aux)=codTb.Cod(sig);
end
Pop.UF=auxUF;
toc;
disp('Laço temporal, iteração:');
%%                          LAÇO TEMPORAL
for time=1:T
    tic;
    
        PsA=Pop.Ps; PiA=Pop.Pi; PnwA=Pop.Pnw;
    PrA=Pop.Pr; PtA=Pop.Pt;      % Guarda população em array para entrar no Flux e EDO
    
    
    [PsA,PiA,PrA,PnwA]=runEdo(beta,gamma,PsA,PiA,PrA,PnwA);  % Roda modelo EDO para os municipios com >1 infectado
   
    [PsA,PiA,PrA,PtA]=runFlux(mFlux,PsA,PiA,PrA,PtA);        % Atualiza o fluxo de pessoas para todos os municipios
        
    Pop.Ps=PsA; Pop.Pi=PiA; Pop.Pnw=PnwA;
    Pop.Pr=PrA; Pop.Pt=PtA;      % Atualiza população após Flux e EDO
    
    
    tS(time)=sum(Pop.Ps);           % Separa as populações do BRASIL
    tI(time)=sum(Pop.Pi);
    tR(time)=sum(Pop.Pr);
    tNw(time)=sum(Pop.Pnw);
    tMIn(time)=sum(Pop.Pi>=0.99);
    
    BAs(time)=sum(Pop.Ps(iBA));     % Separa as populacoes DA BAHIA
    BAi(time)=sum(Pop.Pi(iBA));
    BAr(time)=sum(Pop.Pr(iBA));
    BAnw(time)=sum(Pop.Pnw(iBA));
    BAMIn(time)=sum(Pop.Pi(iBA)>=1);
    
    SSAs(time)=Pop.Ps(ssa);          % Separa as populacoes de SSA
    SSAi(time)=Pop.Pi(ssa);
    SSAr(time)=Pop.Pr(ssa);
    SSAnw(time)=Pop.Pnw(ssa);
    
    tt=repmat(time,N,1);            % Repete os valores para preencher na tabela de report
    cenario=repmat(cen,N,1);
    
    S=floor(Pop.Ps);
    I=floor(Pop.Pi);
    R=floor(Pop.Pr);
    Nw=floor(Pop.Pnw);
    if time > T/2
        I(I<2)=0;                   % Zera flutuações no valor de Infectados
    end
    
    outTable(lt:lt+N-1,:)=num2cell([Pop.id tt S I R Nw cenario Pop.UF]);    % Preenche a tabela de report
    lt=lt+N;
    
    toc;
    disp(time);
end

%%                        REPORT Covid19.m

outTable=sortrows(outTable,2);      % Organizando a tabela em ordem crescente pelo dia

tb=table('Size',[T 15],...          % Criando a tabela de reprot da série temporal
    'VariableTypes',{'uint16','uint64','uint64','uint64','uint64','uint64','uint64','uint64','uint64','uint64','uint64','uint64','uint64','uint32','uint32'},...
    'VariableNames',{'dia','BR_S','BR_I','BR_R','BR_Acum','BA_S','BA_I','BA_R','BA_Acum','SSA_S','SSA_I','SSA_R','SSA_Acum','BA_MunI','BR_MunI'});
tb.BR_S=floor(tS);tb.BR_I=floor(tI);tb.BR_R=floor(tR);tb.BR_Acum=floor(tNw);
tb.BA_S=floor(BAs);tb.BA_I=floor(BAi);tb.BA_R=floor(BAr);tb.BA_Acum=floor(BAnw);
tb.SSA_S=floor(SSAs);tb.SSA_I=floor(SSAi);tb.SSA_R=floor(SSAr);tb.SSA_Acum=floor(SSAnw);
tb.dia=(1:T)';  tb.BR_MunI=tMIn;  tb.BA_MunI=BAMIn;

outName=[ fileOut '.csv'];
writetable(tb,outName,'Delimiter',',');     % Report Serie_varFlux_varLock_varBeta.csv
end