# Sigmoidal Programming
## Overview
Sigmoidal Programming (SP) is a class of non-convex, NP-hard problems relating to maximizing a sum of sigmoidal functions over a convex constraint set. There exist a large number of practical problems which can be modeled as such problems, in domains ranging from economics, marketing to machine learning and network optimization. As SP problems have non-convex objective functions, most traditional optimization techniques cannot be directly applied. A branch-and-bound method involving the use of concave envelope approximation is applied for solving such problems.

This project develops solver in MATLAB for sigmoidal programming. The methods are mainly based on the paper ["Maximizing a Sum of Sigmoids" by Madeleine Udell and Stephen Boyd (2014)](http://www.web.stanford.edu/~boyd/papers/pdf/max_sum_sigmoids.pdf). Extension in concave approximation is developed for more automatic and convenient solver, which has not been explored by the paper.

## Problem Formulation
The standard form Sigmoidal Programming problem is,
![alt text](https://github.com/Yanxding/Sigmoidal-Optimization/blob/appendix/SP.PNG)
A sigmoidal function is any Lipshitz continuous function _f_ over a finite interval _[l,u]_ and is either concave or convex or convex in _[l,z]_ and concave in _[z,u]_.
Madeleine Udell and Stephen Boyd (2014)
## Methodology
SP problem can be solved by using the classical branch-and-bound method where in each splitted region we construct a minimal concave overapproximator (envelope) of the function. Then in each region the upper and lower bound can be solved by applying traditional convex optimization techniques such as descent method and Newton's method. The paper shows that this technique is guaranteed to converge eventually, although the theoretical worst-case upper bound on convergence is exponential in the size of the problem.

As by definition, sigmoidal function can have at most one inflection point. In practice, many functions that we wish to use as objectives have more than a single inflection point such as the Friedman-Savage utility function which is widely used in economics and market design. The authors in the paper note that a function _f_ which is not sigmoidal can be decomposed into a sum of _O(k)_ sigmoidal functions, and then the methodology can be applied.

However, fast convergence of the algorithm depends on a tight concave approximation to the original function. For certain sigmoidal functions, it is hard to develop a tight concave approximation, and as a result the algorithm must endure additional iterations to achieve the desired accuracy is reached. This is notably the case when the sigmoidal functions in question are formed as the decomposition of a single nonsigmoidal function. Moreover, some class of nonsigmoidal functions might be difficult to be decomposed. Therefore, being able to develop a tight concave envelope on the original function could improve convergence rate for certain problems and provide more automatic solution.

## Implementation
In this project, an algorithm is proposed for constructing an overall concave envelope rather than decomposing the non-sigmoidal function. After approximating an overall concave envelope, the SP problem can be solved by branch-and-bound method as presented by the paper. The solver in this project is implemented in MATLAB and the concave subproblems are solved using [CVX solvers](http://cvxr.com/cvx/).

## Usage Guideline
The function _solve_sp_ can be called to solve a SP problem.
![alt text](https://github.com/Yanxding/Sigmoidal-Optimization/blob/appendix/func.PNG)
_l_ and _u_ are vectors of lower and upper bounds for the ranges of decision variables. _A_ and _B_ are matrix for linear constraints such that _Ax <= B_.  _objective_ is the objective function of the problem, which is in _struct_ data structure with the objective functions, first derivatives of the functions, and inflection points and convex/concave indicators of each function included inside.

## Experimental Examples
### Overall Concave Envelope
The following images show how envelopes are constructed on a variety of functions with multiple inflection points.
<img src="https://github.com/Yanxding/Sigmoidal-Optimization/blob/appendix/gaussian_env.png" width="400">
<img src="https://github.com/Yanxding/Sigmoidal-Optimization/blob/appendix/poly_env.png" width="400">
<img src="https://github.com/Yanxding/Sigmoidal-Optimization/blob/appendix/sine_env.png" width="400">
<img src="https://github.com/Yanxding/Sigmoidal-Optimization/blob/appendix/logistic_env.png" width="400">

The example below is a polynomial function with 2 inflection points and a shape close to the Friedman-Savage utility function. The overall envelope gives a much tighter concave approximation than the decomposition.
<img src="https://github.com/Yanxding/Sigmoidal-Optimization/blob/appendix/envelope_compare.png" width="800">

### SP Problems
#### Sample bidding optimization problem
The bidding optimization problem presented in the paper by Madeleine Udell and Stephen Boyd (2014) is used as the first experiment sample.
![alt text](https://github.com/Yanxding/Sigmoidal-Optimization/blob/appendix/sample1.PNG)
The table below shows comparison between the method by the paper and in this project. In this problem, all functions in the objective have only one inflection point. The computational time difference between the two methods varies with different size and parameters of the problem. Generally, for the case when functions have only one inflection point, the method by the paper is much faster - especially when the problem size scales - due to much less computation in constructing the concave envelope.

| N        | Iterations (Method A)  | Iterations (Method B)   | Iterations (Methhod A)  | Iterations (Method B)  |
| -------- |:----------------------:|:-----------------------:|:-----------------------:|-----------------------:|
| 2        | 3                      | 3                       | 1.47 s                  | 1.88 s                 |
| 5        | 2                      | 3                       | 34.87 s                 | 2.53 s                 |
| 10       | 1                      | 3                       | 41.99 S                 | 184.53 s               |

#### Sample with complex objective
The second sample involved functions in the objective with multiple inflection points.
![alt text](https://github.com/Yanxding/Sigmoidal-Optimization/blob/appendix/sample2.PNG)
Both methods yields similar optimal solutions. The overall envelope method in this project costs **7.41 s** with 3 iterations. However, by decomposition, it takes **165.22 s** in 3 iterations. The much tighter envelope enables much faster convergence to optimality. Specifically, we know that for functions in polynomial form, such as in this example, the overall envelope method by this project is more computational efficient.
