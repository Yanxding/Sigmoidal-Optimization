function [W,I,g] = envelope(f, df, l, u, z, c)
    syms x;
    syms g;
    g(x) = f(x);
    if isempty(z)
        W = [l;u];
        if c == 0
            g(x) = ((g(u)-g(l))/(u-l)*(x-l) + g(l)) * heaviside(x-l) * (1 - heaviside(x-u));
            I = 0;
        else
            I = 1;
        end
        return
    end
    idx = find((l<=z)&(z<=u));
    k = [z((l<=z)&(z<=u));u];
    if isempty(idx)
        W = [l;u];
        if z(end) < l
            if c(end) == 0
                I = 0;
                g(x) = ((g(u)-g(l))/(u-l)*(x-l) + g(l)) * heaviside(x-l) * (1 - heaviside(x-u));
            else
                I = 1;
            end
        else
            if c(find(u<z,1)) == 0
                I = 0;
                g(x) = ((g(u)-g(l))/(u-l)*(x-l) + g(l)) * heaviside(x-l) * (1 - heaviside(x-u));
            else
                I = 1;
            end
        end
        return
    end
    c = c([idx' idx(end)+1]);
    c_new = c;
    n = length(c);
    
    i = 1;
    delta = 10^-6;
    if (c_new(1) == 0) && (c_new(2) == 1)
        w = find_w(g, df, l, k(i+1), 1);
        g(x) = ((g(w)-g(l))/(w-l)*(x-l) + g(l)) * heaviside(x-l) * (1 - heaviside(x-w)) + g(x) * heaviside(x-w);
        W = [l;w];
        I = 0;
        i = i + 1;
        c_new = [1; c(i+1:n)];
    else
        W = l;
        I = [];
    end
    while length(c_new) > 2
        [m1, m2] = find_m(g, df, l, k(i+2), k(i), k(i+1));
        g(x) = ((g(m2)-g(m1))/(m2-m1)*(x-m1) + g(m1)) * heaviside(x-m1) * (1 - heaviside(x-m2)) + g(x) * (1 - heaviside(x-m1) * (1 - heaviside(x-m2)));
        ix = find(W<(m1-delta));
        W = W(W<m1);
        if isempty(ix)
            W = [m1;m2];
            I = 0;
        else
            W = [W; m1; m2];
            I = [I(1:max(ix)-1); 1; 0];
        end
        i = i + 2;
        if i < length(k)
            c_new = [1; c(i+1:n)];
        else
            c_new = 1;
        end
    end
    if length(c_new) == 2
        w = find_w(g, df, u, l, 0);
        g(x) = ((g(u)-g(w))/(u-w)*(x-w) + g(w)) * heaviside(x-w) * (1 - heaviside(x-u)) + g(x) * (1-heaviside(x-w));
        ix = find(W<w);
        W = W(W<w);
        if isempty(ix)
            W = [l;w;u];
            I = [1;0];
        else
            W = [W; w; u];
            I = [I(1:max(ix)-1); 1; 0];
        end
    elseif W(end) < u
        W = [W; u];
        I = [I; 1];
    else
        return
    end
end