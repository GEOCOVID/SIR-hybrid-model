function [PsA,PiA,PrA,PnwA]=runEdo(bet,gam,PsA,PiA,PrA,PnwA)

assert(all(size(bet) <= 6000));
assert(isa(bet, 'double'));
assert(all(size(gam) <= 6000));
assert(isa(gam, 'double'));
assert(all(size(PsA) <= 6000));
assert(isa(PsA, 'double'));
assert(all(size(PiA) <= 6000));
assert(isa(PiA, 'double'));
assert(all(size(PrA) <= 6000));
assert(isa(PrA, 'double'));
assert(all(size(PnwA) <= 6000));
assert(isa(PnwA, 'double'));

ids=find(PiA>=1);                   % Roda EDO apenas para municipios infectados
S=PsA(ids);
I=PiA(ids);
beta=bet(ids);  
gamma=gam(ids);
                        % EQUAÇÃO EDO
dS= -beta.*S.*I;
dI= beta.* S.* I - gamma .* I;
dR= gamma .* I;
dNw= -dS;

PsA(ids)=PsA(ids)+dS;
PiA(ids)=PiA(ids)+dI;
PrA(ids)=PrA(ids)+dR;
PnwA(ids)=PnwA(ids)+dNw;
end