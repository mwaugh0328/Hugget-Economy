# Hugget-Economy
Solves and Simulates the Hugget JECD (1993) Economy

This provides a set of code that sovles and simulates the Hugget economy. It closely follows the presentation and numerical results discussed in Recursive Macroeconomic Theory. 

The file hugget_driver is the main file. It takes a guess of the real interest rate, solves the workers problem via value function itteration (hugget_value_fun.m). It then computes the invariant distribution of assets (hugget_invariant.m), then checks to see if the asset market clears. After a market clearing interest rate is found, the code hugget_simmulate.m simulates a pannel of workers from which various statistics can be computed. This one runs a ``townsend'' style regression of income on consompution.
