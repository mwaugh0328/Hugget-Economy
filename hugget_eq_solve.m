function excess_demand = hugget_eq_solve(R,grid,W,beta,gamma,shocks,trans_mat)

asset_space = linspace(grid(2),grid(3),grid(1));
% note if you wanted to have the naturual bowworing limit, then
% the debt limit depends on the interest rate, we need to have it in the routine. 
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute the policy function and the invariant distribution....this
% would be a place to use par for, just solve this for a lot of
% different interest rates and then look for very small steps
    
policy = hugget_value_fun(grid,R,W,beta,gamma,shocks,trans_mat);
    
%   norm(policy-policy_howard)

invariant_distribution = hugget_invariant(policy,trans_mat);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute excess demand of assets
    
asset_demand_state = asset_space(policy);
aggregate_asset_demand = invariant_distribution.*asset_demand_state;

% Just take the state by state asset demand, then multiply it by the
% invarianet distribution. So each entry's iterpertation is the total
% demand of agents in that bin.

excess_demand = (sum(sum(aggregate_asset_demand))).^2;
 