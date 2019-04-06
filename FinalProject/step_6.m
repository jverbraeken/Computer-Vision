function [] = step_6(mergedCloud)
    X = mergedCloud(1,:)';
    Y = mergedCloud(2,:)';
    Z = mergedCloud(3,:)';
    scatter3(X, Y, Z, 20, [1 0 0], 'filled');
    axis( [-500 500 -500 500 -500 500] )
    daspect([1 1 1])
    rotate3d
end

