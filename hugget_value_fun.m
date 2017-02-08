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
    
    feasible = net_assets + W.*shocks(zzz)>0;
    
    utility_mat(:,:,zzz) = utility_mat(:,:,zzz) + -1e10.*(~feasible);
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
        % asset holdings will generate. If there is something messed up it
        % would here. 
        
        % Surprisingly, the operation above appears to be the most
        % intensive of all. Not the maximization step, but integration. 
    
        value_fun = bsxfun(@plus,utility_mat(:,:,zzz),expected_value);
        
%         value_fun(~feasible(:,:,zzz)) = -1e10;
        
        [v_test, p_test] = max(value_fun,[],2);
        
        % This uses the ``bsxfun'' command to compute the value
        % function. This is superfast. Far supierior to doing, say, repmat
        % and constructing a matrix of expected values and adding it to the
        % utility function. 
             
        v_prime(:,zzz) = v_test';
        
        policy(:,zzz) = p_test';
      
        v_hat(:,zzz) = v_prime(:,zzz);
        % updates the value function within the itteration. This + bsxfun is
        % much faster than vectorizing this opperation over the different
        % shock states. 
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