function invariant_distribution = hugget_invariant(policy,trans_mat)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Here we want compute the invariance distribution over states and assets.
% This is the trickiest part I found, the approach here is to contruct the
% markov transition matrix for the (asset,state) combination. Then figure
% out the invariant distribution...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[n_asset_states,n_shocks] = size(policy);

policy_hat = policy';
policy_hat = policy_hat(:);
% Ok so what this does is create a n_shocks*n_asset_states vector that
% specifies a first asset, then state policy choice. So in the 2by3 case
% this is just saying low asset, low state = 1, low asset, high state = 2,
% etc.

asset_index = repmat(1:n_asset_states,n_shocks,1);
asset_index = asset_index(:);
% Now we need to specify an asset index to go along with the formulation
% above, so this should look like, (1,1,2,2,3,3)' so this is indexing the
% asset level.

% shock_index = repmat(1:n_shocks,1,n_asset_states)';
% I don't think we need this, but it indexes the shocks. So it goes in the
% 2by3 case (1,2,1,2,1,2)'

indicator = zeros(n_shocks.*n_asset_states);
indicator_all = ones(n_shocks*n_asset_states,1);

% Then this is a matrix which will record a one or a zero if the policy
% function specifies a transition.
for zzz = 1:n_shocks*n_asset_states
    % So we are fixing a asset/shock combination and record the policy (it
    % should be a number corresponding with an asset value).
    
    % See the old version for a more tranparent treatment. But this just
    % takes an asset/shock and creates and indicator if a transition is
    % possible. 
    ind = policy_hat(zzz) == asset_index;
    
    indicator(zzz,:) = indicator_all.*ind;

end
asset_state_transition = repmat(trans_mat,n_asset_states,n_asset_states).*indicator;

% Note...I've tried a bunch of stuff...this is probably the fastest...see
% older approaches below. 
L = zeros(1,n_shocks*n_asset_states);
L(1) = 1.0;

% the strategy is to compute Lnew = Q' * L; until Lnew -  L.
% This is similar to doing mpower, but will stop whenever we are "close
% enough" and doesn't do quite as much computation.

for zzz = 1:2000
    L_new = L*asset_state_transition;
    
    if norm(L_new-L) < 10^-10
        break
    end
    
    L = L_new;
end

step_one_invariant = L;

% Again...just like a transition matrix, take of a row and you have it. Note that
% each column is for an asset, shock combination, so it goes [(1,1),
% (1,2),..(2,1),(2,2)...]

invariant_distribution = reshape(step_one_invariant,n_shocks,n_asset_states)';
% Reshape it so I have it where columns are shocks, rows are assets. Then
% if you sum across the columns this will give you the mass at asset
% holdings, which you can then plot the density of.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alternative approaches...
% 
% % step_one_invariant = mpower(asset_state_transition,1000); This is also
% % the most computationally demanding aspects of the code, initially, I was
% % just taking the matrix above to a big power to compute the invariant
% % distribution, the eigenvalue approach is much faster. 
% 
% [V,D] = eigs(asset_state_transition',[],2);
% 
% index = round(diag(D),2) == 1;
% 
% step_one_invariant = abs(V(:,index))./sum(abs(V(:,index)));
% 
% % Here was the trouble I was having, given the simple code, if a agent
% % started with asset state 1, the policy function said it will always
% % stayin 1. Thus the invariant distribution was looking odd/hard to
% % understand, because there was an abosrbing state....multiple of them.
% % This is an area to be midfull of.
% 
% % step_one_invariant = step_one_invariant(1,:); 
% % Just like a transition matrix, take of a row and you have it. Note that
% % each column is for an asset, shock combination, so it goes [(1,1),
% % (1,2),..(2,1),(2,2)...]
% 
% invariant_distribution = reshape(step_one_invariant,n_shocks,n_asset_states)';
% % Reshape it so I have it where columns are shocks, rows are assets. Then
% % if you sum across the columns this will give you the mass at asset
% % holdings, which you can then plot the density of.