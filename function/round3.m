function xs = round3(x,xi) % Snap vector of x to vector xi
    dx = abs(xi(2) - xi(1));
    minxi = min(xi);
    maxxi = max(xi);

    %% Perform rounding on interval dx
    xs = (dx * round((x - minxi)/dx)) + minxi;

    %% Outside the range of xi is marked NaN
    % Fix edge cases
    xs((xs==minxi-dx) & (x > (minxi - (dx)))) = minxi;
    xs((xs==maxxi+dx) & (x < (maxxi + (dx)))) = maxxi;
    % Make NaNs
    xs(xs < minxi) = NaN;
    xs(xs > maxxi) = NaN;
end