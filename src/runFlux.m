function [PsA,PiA,PrA,PtA]=runFlux(mFlux,PsA,PiA,PrA,PtA)
assert(all(size(mFlux) <= [6000 6000]));
assert(isa(mFlux, 'double'));
assert(all(size(PsA) <= 6000));
assert(isa(PsA, 'double'));
assert(all(size(PiA) <= 6000));
assert(isa(PiA, 'double'));
assert(all(size(PrA) <= 6000));
assert(isa(PrA, 'double'));
assert(all(size(PtA) <= 6000));
assert(isa(PtA, 'double'));

% Criação de auxiliares que mantém o valor das populações antes do fluxo do dia
PsAA=PsA;   PiAA=PiA;   PrAA=PrA;   PtAA=PtA;

N=length(PsA);
for i=1:N
    [PsA,PiA,PrA,PtA]=transp(i,mFlux,PsA,PiA,PrA,PtA,PsAA,PiAA,PrAA,PtAA);
    
end
end

%%
function [PsA,PiA,PrA,PtA]=transp(i,mFlux,PsA,PiA,PrA,PtA,PsAA,PiAA,PrAA,PtAA)

T=mFlux(i,:)';

% Estimate the fraction of each place to travel
Psx=(T*(PsAA(i)/PtAA(i)));      % variáveis auxiliares que contem o valor antes 
Pix=(T*(PiAA(i)/PtAA(i)));      % do fluxo para que o fluxo das cidades posteriores não seja 
Prx=(T*(PrAA(i)/PtAA(i)));      % interferido pela variação que já sofreu pelo fluxo das cidades anteriores


% Decrease the Population of Source
PsA(i)=PsA(i)-sum(Psx);
PiA(i)=PiA(i)-sum(Pix);
PrA(i)=PrA(i)-sum(Prx);
PtA(i)=PtA(i)-sum(T);
% Increase Population of Target
PsA=PsA+Psx;
PiA=PiA+Pix;
PrA=PrA+Prx;
PtA=PtA+T;

% Zera em caso de flutuação negativa
PsA(PsA<0)=0;      
PiA(PiA<0)=0;
PrA(PrA<0)=0;
end
