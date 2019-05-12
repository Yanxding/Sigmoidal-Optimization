function [m1, m2] = find_m(f, df, l, u, k1, k2)
    syms x;
    syms p;
    syms q;
    syms h;
    syms m;
    h(x,p) = df(x) * (x - p) + f(p) - f(x);
    m(x,p,q) = (f(q)-f(p))/(q-p)*(x-p) + f(p) - f(x);
    k = k1;
    for i = 1:1000
        m1 = (l+k)/2;
        F = matlabFunction(h(x,m1));
        [x_val,F_val] = fminbnd(F, k2, u);
        if (abs(m1-l) < 10^-6) || (abs(F_val) < 10^-8)
            break
        elseif F_val > 0
            l = m1;
        elseif F_val < 0
            k = m1;
        end
    end
    m2 = x_val;
    if (abs(m1-l) < 10^-6) && (abs(F_val) > 10^-8)
        M = matlabFunction(m(x,m1,m2));
        [x_val,M_val] = fminbnd(M, k2, u);
        iter = 1;
        while (abs(M_val) > 10^-8) && (iter < 1000)
            m2 = x_val;
            M = matlabFunction(m(x,m1,m2));
            [x_val,M_val] = fminbnd(M, k2, u);
            iter = iter + 1;
        end
    end
    M = matlabFunction(m(x,m1,m2));
    [x_val,M_val] = fminbnd(M, l, k1);
    iter = 1;
    while (abs(M_val) > 10^-8) && (iter < 1000)
        m1 = x_val;
        M = matlabFunction(m(x,m1,m2));
        [x_val,M_val] = fminbnd(M, l, k1);
        iter = iter + 1;
    end
end

%{
s = vpasolve(df==0, x, [k2,u]);
if isempty(s) == 0
    m2 = s;
    return
end
%}