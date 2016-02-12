function [policy_function, value_function] = hugget_value_fun(grid,R,W,beta,gamma,shocks,trans_mat)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n_iterations = 2000;
tol = 10^-5;

n_shocks = length(shocks);

A = (1-gamma).^-1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up grid for asset holdings. 
n_asset_states = grid(1);
asset_space = linspace(grid(2),grid(3),n_asset_states);
asset_grid  = meshgrid(asset_space,asset_space);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up the matricies for value function itteration

v_prime = zeros(n_asset_states,n_shocks); 
policy = zeros(n_asset_states,n_shocks);
v_old = ones(n_asset_states,n_shocks);

net_assets = R.*asset_grid' - asset_grid;

utility_mat = zeros(n_asset_states,n_asset_states,n_shocks);

for zzz = 1:n_shocks
    utility_mat(:,:,zzz) = A.*(max(net_assets + W.*shocks(zzz),10^-5)).^(1-gamma);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Commence value function itteration.

for iter = 1:n_iterations
    
    v_hat = v_old;
    
    for zzz = 1:n_shocks
                
        expected_value = beta.*(trans_mat(zzz,:)*v_hat');
              
    % Compute expected discounted value. The value function matrix is set up so
    % each row is an asset holding; each coloumn is a state for the shocks. So 
    % by multiplying the matrix, by the vector of the transition matrix given 
    % the state we are in, this should create the expected value that each level of
    % asset holdings will generate. If there is something messed up it would 
        
        [v_test, p_test] = max(bsxfun(@plus,utility_mat(:,:,zzz),expected_value),[],2);
               
        v_prime(:,zzz) = v_test';
        
        policy(:,zzz) = p_test';
    % This takes the max over the matrix. See older code to see more
    % mechanichally (but slower) how it works through state by state.
        
        v_hat(:,zzz) = v_prime(:,zzz);
    % update the value function within the itteration. This speeds things
    % up faster than vectorizing...
    end    
%     disp(iter)
%     disp([norm(v_old - v_prime,Inf),iter])
    if norm(log(-1.*v_old) - log(-1.*v_prime),Inf) < tol
%         disp('value function converged')
%         disp(toc)
%         disp(iter)
        break
    else
    v_old = v_prime;
    end
end

if norm(log(-1.*v_old) - log(-1.*v_prime),Inf) > tol
    disp('value function did NOT converge')
end

value_function = v_prime;
policy_function = policy;