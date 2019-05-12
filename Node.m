classdef Node < handle
   % infrastructure of node for binary branch-and-bound tree  
   properties
      l              % left domain limit
      u              % right domain limit
      w              % points separating the piecewise linear concave approximator
      I              % indicating whether each section separated by w is the linear envelope or the origginal function
      x              % solution at the node
      lb             % lower bound at the node
      ub             % upper bound at the node
      maxdiff_index  % coordinate with the largest difference between upper and lower bounds
      subtol         % tolerence at the node
   end
   methods
      function obj = Node(l, u, w, I, subtol) 
           if nargin > 0   
                obj.l = l;
                obj.u = u;
           end
           if nargin > 2
                obj.w = w;
                obj.I = I;
           end
           if nargin > 4
               obj.subtol = subtol;
           end 
      end
      
      function Node_w(obj, objective, A , B, subtol)
         nvar = length(obj.l);
         [obj.x, t, status] = maximize_fhat(obj.l, obj.u, obj.w, obj.I, objective, A , B, subtol);
         if status == 'Solved'
            for i = 1:nvar
                s(i) = objective.f{i}(obj.x(i));
            end
            obj.ub = sum(t);
            obj.lb = sum(s);
            [~, diff] = max(t-s);
            obj.maxdiff_index = diff;
         else
            obj.ub = -Inf; obj.lb = -Inf; obj.maxdiff_index = 1;
         end
      end
      
      function Node_wo(obj, objective, A , B, subtol)
         nvar = length(obj.l);
         for i=1:nvar
                 [w_cor{i},obj.I{i}] = envelope(objective.f{i},objective.df{i},obj.l(i),obj.u(i),objective.z{i},objective.c{i});
         end
         obj.w = w_cor;
         Node_w(obj, objective, A, B, subtol);
      end
   end
end


