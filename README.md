# Sigmoidal Programming
## Overview
Sigmoidal Programming (SP) is a class of non-convex, NP-hard problems relating to maximizing a sum of sigmoidal functions over a convex constraint set. There exist a large number of practical problems which can be modeled as such problems, in domains ranging from economics, marketing to machine learning and network optimization. As SP problems have non-convex objective functions, most traditional optimization techniques cannot be directly applied. A branch-and-bound method involving the use of concave envelope approximation is applied for solving such problems.

This project develops solver in MATLAB for sigmoidal programming. The methods are mainly based on the paper "Maximizing a Sum of Sigmoids" by Madeleine Udell and Stephen Boyd (2014). Extension in concave approximation is developed for more automatic and convenient solver, which has not been explored by the paper.

## Problem Formulation
The standard form Sigmoidal Programming problem is,
![alt text](https://github.com/Yanxding/Sigmoidal-Optimization/raw/master/src/common/images/icon48.png "Logo Title Text 1")
