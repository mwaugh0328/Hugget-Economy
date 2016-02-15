# Hugget-Economy
Solves and Simulates the Hugget JECD (1993) Economy

This provides a set of code that solves and simulates the Hugget economy. I really like this model. It is a nice instance where the primitives + dynamic behavior induce a demand and supply curve for assets. The interst rate is found so that demand and supply are equall. It closely follows the presentation and numerical results discussed in Recursive Macroeconomic Theory.

The file ''hugget_driver.m'' is the main file. It takes a guess of the real interest rate, solves the workers problem via value function iteration ''hugget_value_fun.m''. In this code it uses the ''bsxfun'' operation that is crazy fast. Given a solution to the workers problem, then computes the invariant distribution of assets ''hugget_invariant.m'' and then checks to see if the asset market clears. And updated interest rate is guessed and continues in this fastion.

After a market clearing interest rate is found, the code ''hugget_simmulate.m'' simulates a panel of workers from which various statistics can be computed. This one runs a ''townsend-style'' regression of income on consumption as a measure of insurance. 

Note requires ''rouwenhorst.m'' which computes the markov chain approaximation to the AR(1) process of income shocks. 
