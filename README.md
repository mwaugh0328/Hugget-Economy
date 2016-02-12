# Hugget-Economy
Solves and Simulates the Hugget JECD (1993) Economy

This provides a set of code that solves and simulates the Hugget economy. I really like this model. It is a nice instance where the primitives induce a demand and supply curve for assets. It closely follows the presentation and numerical results discussed in Recursive Macroeconomic Theory.

The file hugget_driver is the main file. It takes a guess of the real interest rate, solves the workers problem via value function iteration (hugget_value_fun.m). It then computes the invariant distribution of assets (hugget_invariant.m), then checks to see if the asset market clears. After a market clearing interest rate is found, the code hugget_simmulate.m simulates a panel of workers from which various statistics can be computed. This one runs a ``townsend'' style regression of income on consumption. 
