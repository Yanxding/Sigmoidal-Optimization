function [pq, bestnodes, optimal_x, optimal_value, lbs, ubs] = solve_sp(l, u, objective, A, B, val)
    TOL = length(l)*val;
    maxiters = 100;
    subtol = (TOL/length(l))/10;
    
    root = Node(l,u,{},{},subtol);
    Node_wo(root, objective, A, B, subtol)
    
    if isempty(root.ub) 
        disp("Problem infeasible")
        return
    end

    bestnodes(1) = root;
    qindex = 1;
    root.ub;
    ubs(1) = root.ub;
    lbs(1) = root.lb;
    nodeList(qindex) = root ;

    pq = PQ2();
    pq.push(qindex,root.ub);
    for i=1:maxiters
        if ubs(end) - lbs(end) < TOL 
              fprintf('found solution within tolerance %f \n',ubs(end)-lbs(end) )
              optimal_x = bestnodes(end).x;
              optimal_value = zeros(length(l),1);
              for j = 1:length(l)
                  optimal_value(j) = objective.f{j}(optimal_x(j));
              end
            break 
        end
        if (pq.nElements == 0)
            optimal_x = bestnodes(end).x;
            optimal_value = zeros(length(l),1);
            for j = 1:length(l)
                optimal_value(j) = objective.f{j}(optimal_x(j));
            end
            break
        end
            
        node = nodeList(pq.pop());
        ubs(length(ubs) + 1) = min(node.ub,ubs(end));
        [left, right] = split(node, objective, subtol, A, B);

        if left.lb > lbs(end) && left.lb >= right.lb
            lbs(length(lbs) + 1) = left.lb ;
            bestnodes(length(bestnodes) + 1) = left;
        elseif right.lb > lbs(end)
            lbs(length(lbs) + 1) = right.lb ;
            bestnodes(length(bestnodes) + 1) = right;   
        else 
            lbs(length(lbs) + 1) = lbs(end) ;
        end
        
        fprintf("(lb, ub) = (%f, %f)\n", lbs(end), ubs(end))

        if ~isnan(left.ub) && left.ub >= lbs(end)
            qindex = qindex+1;
            nodeList(qindex) = left;
            pq.push(qindex,left.ub);
            fprintf("enqueued left\n")
        else
            fprintf("pruned left\n")
        end
        
        if ~isnan(right.ub) && right.ub >= lbs(end)
            qindex = qindex+1;
            nodeList(qindex) = right;
            pq.push(qindex,right.ub);
            fprintf("enqueued right\n")
        else
            fprintf("pruned right\n") 
        end
    end
end