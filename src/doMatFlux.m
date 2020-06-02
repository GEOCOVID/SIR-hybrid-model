function mFlux=doMatFlux(Pop,Flu,Aviao)
tamPop=length(Pop.id);
tamFlu=length(Flu.Source);

mFlux=zeros(tamPop,tamPop);
for i=1:tamFlu
    k=find(Pop.id==Flu.Source(i));
    p=find(Pop.id==Flu.Target(i));
    if k==p
        continue;
    end
    mFlux(k,p)=Flu.Flux(i);
    mFlux(p,k)=Flu.Flux(i);
end
if ~isempty(Aviao)
    tamAvi=length(Aviao.Source);
    for i=1:tamAvi
        k=find(Pop.id==Aviao.Source(i));
        p=find(Pop.id==Aviao.Target(i));
        mFlux(k,p)=mFlux(k,p)+Aviao.Pax(i);
        mFlux(p,k)=mFlux(p,k)+Aviao.Pax(i);
    end
end
end