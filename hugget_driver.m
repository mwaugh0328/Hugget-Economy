%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This program computes the equillibrium of the Hugget(1993) economy. By
% Michael Waugh 01/20/2016. It used the following matlab files...
% hugget_eq_solve.m, hugget_value_fun.m, hugget_invariant.m,
% hugget_simmulate.m
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % The Hugget economy....
% gamma = 1.5;
% beta = 0.96^(1/6);A = (1-gamma).^-1;
% 
% shocks = [0.1;1]
% trans_mat = [0.50, 0.50;1-0.925,0.925]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Ljungovist and Sargent Red pg 584.
gamma = 3; W = 1;
beta = 0.96 ; A = (1-gamma).^-1;

rho = 0.20;
sigma = 0.4*sqrt((1-rho.^2)); 

n_shocks = 20;

[shocks,trans_mat] = rouwenhorst(n_shocks,rho,sigma);

shocks = exp(shocks);

grid = [100,-3,16];

% natrual_debt_limit = (W./(R-1)).*min(shocks);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Here we will compute an equillibrium...so for a given R solve the value
% function, invarian distribution, compute excess demand, then update the
% interest rate to clear the market. 

asset_space = linspace(grid(2),grid(3),grid(1));

save hugget_eq_params gamma W beta shocks trans_mat grid

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% options = optimset('Display','iter','MaxFunEvals',1e2,'MaxIter',1e2,'TolFun',1e-5,'TolX',1e-5);
% 
% tic
% R = fminbnd(@(x) hugget_eq_solve(x,grid,W,beta,gamma,shocks,trans_mat),beta,1/beta,options);
% toc

R = 1.0292;

tic

[policy, value_fun] = hugget_value_fun(grid,1.0292,W,beta,gamma,shocks,trans_mat);
toc

tic
invariant_distribution = hugget_invariant(policy,trans_mat);

toc 

save hugget_ss policy value_fun invariant_distribution R

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot the density of assets. Use the ``townsedn test'' to see how income shocks
% are passed through to consumption. 

panel = hugget_simmulate(policy,grid,R,W,shocks,trans_mat);

townsend = cov((log(panel(:,[1,2]))))/var((log(panel(:,1))));

disp('Townsend Test: Regression of Consumption on Income')
disp(townsend(1,2))
disp('Standard Deviation of Log Income')
disp(std((log(panel(:,1)))))
disp('Standard Deviation of Log Consumption')
disp(std((log(panel(:,2)))))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot the density of assets
close all

figure_density = figure;
axes1 = axes('Parent',figure_density,'YGrid','on','XGrid','on','FontWeight','bold',...
    'FontSize',14);
xlim([min(asset_space)-1,max(asset_space)+1]);

hold(axes1,'all');

xlabel('Assets','FontWeight','bold','FontSize',16);
ylabel('Probability','FontWeight','bold','FontSize',16);
prob_assets = sum(invariant_distribution,2);
plot(asset_space,prob_assets,'LineWidth',3,'LineStyle','-','Color',[1 0 0])