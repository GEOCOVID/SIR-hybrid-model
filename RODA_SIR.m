clear all;

addpath('src')                                           % path de códigos-fonte
%%                     ARQUIVOS DE ENTRADA DI�RIA


arqState=['input' filesep 'states_summary_2020-03-26.csv'];      % arquivo com parametros dos estados
arqCity=['input' filesep 'cities_summary_2020-03-26.csv'];       % arquivo com parametros e populacoes estimadas dos municipios
lockMun=readtable(['data' filesep 'lock_BA_+pop.xlsx']);       % arquivo com munic�pios com lock, caso vazio se aplica em todos

%%                       PAR�METROS DE VARIA��O

T=100;                      % N�mero de dias de proje��o
vetFlux=[1,0.5];            % Varia��o do fluxo geral (INTERmunicipal)
vetFluxLock=[1,0.05];       % Varia��o do lock        (INTERmunicipal)
vetBeta=[1.5,1];            % Varia��o da quarentena  (INTRAmunicipal)

%%                        CONFIGURA��ES FIXAS

resultPath=['results' filesep];                  % Nome da pasta dos reports
arqFlu=['data' filesep 'FluxBR.xlsx'];                   % Fluxo hidro e rodoviario
arqAvi=['data' filesep 'AviaoBR.xlsx'];                  % Fluxo aereo
arqCod=['data' filesep 'codBR.xlsx'];                    % Codigo IBGE de cada estado
arqCoord=['data' filesep 'coordBR.xlsx'];                % Coordenadas dos municipios e popula��es Totais
Titulo='Brasil';                        % T�tulo para escrita de alguns arquivos
Ssa=2927408;                            % C�digo da cidade principal

lockMun=lockMun.id;
mkdir(resultPath);
Tb=table();
cen=1;
numCenarios=length(vetFlux);

for i=1:numCenarios
        outName=[resultPath 'Serie_cen' num2str(i) '_F' num2str(vetFlux(i),2) '_L' num2str(vetFluxLock(i),2) '_B' num2str(vetBeta(i),2)];
        Ta=Covid19(arqCoord,arqFlu,arqAvi,arqState,arqCod,arqCity,outName,vetFlux(i),vetFluxLock(i),vetBeta(i),Ssa,T,cen,lockMun);
        Tb=[Tb;Ta];
        cen=cen+1;
end

disp('Exportando tabelas');
outNameTb=[resultPath Titulo '_Mun.csv'];               % Report Brasil_mun.csv
writetable(Tb,outNameTb,'Delimiter',',');

BrasilUF(Tb,numCenarios,resultPath,T);       % Report Brasil_UF.csv

BA=find(ismember(Tb.UF,29));                            % Report Bahia.csv
BATable=Tb(BA,:);
writetable(BATable,[resultPath 'Bahia.csv'],'Delimiter',',');
disp('Fim');
