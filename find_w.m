function w = find_w(f, df, l, u, key)
    syms x;
    syms h;
    if key == 1
        df = df;
    else
        df = diff(f);
    end
    h(x) = df(x) * (x - l) - (f(x) - f(l));
    w = bisection(h, l, u);
end

function w = bisection(h, l, u)
    for i = 1:1000
        w = (u+l)/2;
        hw = h(w);
        if abs(hw) < 10^-8
            return  
        end
        if hw > 0
            l = w;
        elseif hw < 0
            u = w;
        end
    end
    disp("hit maximum iterations in bisection search")
    w = (u+l)/2 ;
end