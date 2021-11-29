function panel = hugget_simmulate(policy,grid,R,W,shocks,trans_mat)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This just simmulates a pannel of income, consumption and assets such
% that, one could compute stuff....

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up grid for asset holdings. 

n_shocks = length(shocks);

n_asset_states = grid(1);
asset_space = linspace(grid(2),grid(3),n_asset_states);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
burn_in = 10000;
time_series = 500000;

rng(03281978)

[~, shock_states] = hmmgenerate(time_series+burn_in,trans_mat,ones(n_shocks));

shock_states = shock_states(burn_in+1:end);

asset_state = 20;

labor_income = zeros(time_series,1);
gross_income = zeros(time_series,1);
consumption = zeros(time_series,1);
assets = zeros(time_series+1,1);

assets(1,1) = asset_space(asset_state);

for xxx = 1:time_series
    
    labor_income(xxx,1) = W.*shocks(shock_states(xxx)) ;
    
    gross_income(xxx,1) = labor_income(xxx,1) + R.*assets(xxx,1);
    
    asset_state_p = policy(asset_state,shock_states(xxx));
    
    assets(xxx+1,1) = asset_space(asset_state_p);
    
    consumption(xxx,1) = gross_income(xxx,1) - assets(xxx+1,1);
    
    asset_state = asset_state_p;
    
end
    
panel = [labor_income,consumption,assets(1:end-1,1)];


