clear 
close all
clc

%% M. T. Reeves, 01/11/2018
%This script calculates the enstropy, temperature, and
%mean-nearest-neighbour distance histograms from the monte carlo data
%generated by MonteCarloSampling.m (Fig 1 of the manuscript).

disp('Loading Energy and NN distance...')
load('a120_b85_N18_Nsamples1e8_.100pc_D_ell_CB_rad_run1_.mat','H','mean_nnd')
Hnew = H;
ell = mean_nnd(:);

for runs = 2:10
    disp(num2str(runs))
    load(['a120_b85_N18_Nsamples1e8_.100pc_D_ell_CB_rad_run' num2str(runs) '_.mat'],'H','mean_nnd');
    Hnew = [Hnew; H]; 
    ell = [ell; mean_nnd(:)];
end
disp('...done')
clear H mean_nnd

%%
Nv = 18;
Ns = length(Hnew);
[counts,energies] = hist(Hnew,200);
energies = energies/Nv;
dE = energies(2) - energies(1);
counts = counts/Ns/dE;

for ii = 1:length(energies)-1
    ind = (Hnew/Nv >= energies(ii) ) & (Hnew/Nv < energies(ii+1));
    ll(ii) = mean(ell(ind));
    disp(num2str(ii))
end
%%
close all
[val,ind] = max(counts);
Em = energies(ind);

%Calculate temperature, small amount of smoothing at high energy to deal
%with low sampling quality
T = 1./gradient(log(counts))*dE;
T(energies-Em > 1.5) = movmean(T(energies-Em > 1.5),10);
%inds = energies > 5;
ll2 = ll;
ll2 = movmean(ll,5)
xi = 0.53;
a = 120/2;
b = 80/2;

figure(1234)

subplot(211)
%Entropy, normalized according to minimum phase-space volume xi^2
plot(energies-Em,log(counts)+ log((pi*a*b/xi/xi)^Nv),'Linewidth',1.5,'Color','k')
xlim([-1.5 3])
ylim([176 185])
xlabel('Energy per vortex, $(E-E_m)/E_0$','Interpreter','Latex','Fontsize',18)
ylabel('Entropy, $S/k_B$','Interpreter','Latex','Fontsize',18)



%Nearest neighbour distance, normalized to l0 ~ sqrt(a*b/N) which is
%approximately the value for an uncorrelated system
yyaxis right
l0 = sqrt(a*b/xi/xi/Nv);
plot(energies(1:end-1)-Em,ll2/l0,'Linewidth',1.5,'Color',[0.5 0.5 0.5])
hold on
plot(energies(1:end-1)-Em,ll/l0,'Linewidth',1.5,'Color',[0.5 0.5 0.5])
ylabel('Nearest neighbour distance, $\ell/\ell_0$','Interpreter','Latex','Fontsize',18)
ylim([0.85 1.1])

xdata = energies-Em;
ind1 = xdata <0;
ind2 = xdata >0;
subplot(212)
plot(xdata(ind1),T(ind1),'-k','Linewidth',1.5)
hold on
plot(xdata(ind2),T(ind2),'-k','Linewidth',1.5)
ylim([-0.7 0.7])
xlim([-1.5 3])
Ts = -0.25;
plot([2 3],[1 1]*Ts,'--r','Linewidth',1)
plot([0 0 ],ylim,'--k','Linewidth',1)
ylabel('Temperature, $T/T_0 N$','Interpreter','Latex','Fontsize',18)
xlabel('Energy per vortex, $(E-E_m)/E_0$','Interpreter','Latex','Fontsize',18)
