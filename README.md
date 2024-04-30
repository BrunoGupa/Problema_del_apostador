# Gambler's Problem

This repository contains code that solves the Gambler's Problem as described by Sutton and Barto (2017). In the first approach, the problem is tackled using dynamic programming, specifically employing the "value iteration" technique outlined by Kochenderfer (2015).

A second implementation solves the problem by searching directly within the space of possible policies. This search is conducted using Genetic Algorithms.

## Problem Description

The Gambler's Problem involves a scenario where a person starts with an initial amount of money, typically ranging from 1 to 100 units. At each turn, the person must decide how much of their current money to bet. The process continues until the person either reaches a goal of 100 units or loses all their money.

The objective is to find an optimal strategy that maximizes the person's gain over multiple rounds of betting.

## Contents

- **dynamic_programming.py**: Contains the implementation of the Gambler's Problem solved using dynamic programming.
- **genetic_algorithm.py**: Provides a solution to the Gambler's Problem using Genetic Algorithms.
- **utils.py**: Helper functions used in both implementations.


## Results

Graphs and visualizations of the results obtained from each method can be found in the respective output or in the documentation provided within the code. These results demonstrate the effectiveness of each approach in optimizing the gambler's gain over time.

## Acknowledgements

- Sutton, R. S., & Barto, A. G. (2017). Reinforcement learning: An introduction. MIT press.
- Kochenderfer, M. J. (2015). Decision making under uncertainty: Theory and application. MIT press.

Feel free to explore, experiment, and contribute improvements to this repository!
