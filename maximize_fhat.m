function [x_val, t, cvx_status] =  maximize_fhat(l, u, w, I, objective, A, B, subtol)
    nvar = length(l) ;
    maxiters = 10*nvar ;
    fs = objective.f ;
    dfs = objective.df ;
    l = l';
    u = u';
    TOL = subtol;
    n = nvar;
    
    cvx_begin quiet
    variables x(n) t(n)
    maximize sum(t)
    subject to
        l <= x ;
        x <= u ;
        A*x <= B;
        for i=1:nvar
            w_i = w{i};
            I_i = I{i};
            for j=1:length(w_i)-1
                if I_i(j) == 1 % 1 indicates original function active
                    t(i) <= fs{i}(w_i(j)) + dfs{i}(w_i(j))*(x(i) - w_i(j));
                    t(i) <= fs{i}(w_i(j+1)) + dfs{i}(w_i(j+1))*(x(i) - w_i(j+1));
                elseif I_i(j) == 0 % 0 indicates original function inactive
                    slope = ( fs{i}(w_i(j+1)) - fs{i}(w_i(j)) )/( w_i(j+1) - w_i(j) );
                    t(i) <= fs{i}(w_i(j)) + slope*( x(i) - w_i(j) );
                end
            end
        end
    cvx_end

    for m=1:maxiters
        x_val = x;
        t_val = t;
        
        solved = 1;
        indices = [];
        tconstr = [];
        for i=1:length(x_val)
%       # Check if t is in the hypograph of f, allowing some tolerance
            xi = x_val(i);
            ti = t_val(i);
            w_i = w{i};
            I_i = I{i};
            for j=1:length(I_i)
                if I_i(j) == 0
                    continue
                elseif (w_i(j) < xi) && (xi < w_i(j+1))
                    if ti > fs{i}(xi) + TOL
                        solved = 0;
                        indices = [indices i];
                        tconstr(i) = fs{i}(xi) + dfs{i}(xi)*(x(i) - xi);
                    end
                else
                    continue
                end
            end
        end
        if solved==1
            fprintf("solved problem to within %d in %d iterations\n",TOL,i);
            break
        else
             cvx_begin quiet
                variables x(n) t(n)
                maximize sum(t)
                subject to
                    l <= x ;
                    x <= u ;
                    A*x <= B;
                    for i=1:nvar
                        w_i = w{i};
                        I_i = I{i};
                        for j=1:length(w_i)-1
                            if I_i(j) == 1 % 1 indicates original function active
                                t(i) <= fs{i}(w_i(j)) + dfs{i}(w_i(j))*(x(i) - w_i(j));
                                t(i) <= fs{i}(w_i(j+1)) + dfs{i}(w_i(j+1))*(x(i) - w_i(j+1));
                            elseif I_i(j) == 0 % 0 indicates original function inactive
                                slope = ( fs{i}(w_i(j+1)) - fs{i}(w_i(j)) )/( w_i(j+1) - w_i(j) );
                                t(i) <= fs{i}(w_i(j)) + slope*( x(i) - w_i(j) );
                            end
                        end
                    end
                    t(indices) <= tconstr(indices)';
                cvx_end
        end
    end 
    
    %# refine t a bit to make sure it's really on the convex hull
    t = zeros(1,nvar);
    x_val = x;
    for i=1:nvar
        xi = x_val(i);
        w_i = w{i};
        I_i = I{i};
        for j=1:length(I_i)
            if (w_i(j) <= xi) && (xi <= w_i(j+1))
                if I_i(j) == 1
                    t(i) = fs{i}(xi);
                else
                    slope = ( fs{i}(w_i(j+1)) - fs{i}(w_i(j)) )/( w_i(j+1) - w_i(j) );
                    t(i) = fs{i}(w_i(j)) + slope*( xi - w_i(j) );
                end
            else
                continue
            end
        end
    end
end

