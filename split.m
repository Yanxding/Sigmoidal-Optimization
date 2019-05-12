function [left, right] = split(obj, objective, subtol, A, B)
    %i is the splitting coordinate
    i = obj.maxdiff_index;
    %# split at x for x < z; otherwise split at z
    %# (this achieves tighter fits on both children when z < x < w)
    splithere = obj.x(i);
    fprintf("split on coordinate %d at x=%f\n",i,obj.x(i)) 
%     # left child
    left_u = obj.u;
    left_u(i) = splithere;
    left_w = obj.w;
    left_I = obj.I;
    [left_w{i},left_I{i}] = envelope(objective.f{i}, objective.df{i}, obj.l(i), left_u(i), objective.z{i}, objective.c{i});
    left = Node(obj.l, left_u, left_w, left_I, subtol);
    Node_w(left, objective, A, B,subtol);
%     # right child
    right_l = obj.l;
    right_l(i) = splithere;
    right_w = obj.w;
    right_I = obj.I;
    [right_w{i},right_I{i}] = envelope(objective.f{i}, objective.df{i}, right_l(i), obj.u(i), objective.z{i}, objective.c{i});
    right = Node(right_l, obj.u, right_w, right_I, subtol);
    Node_w(right, objective, A, B,subtol);
    return 
end