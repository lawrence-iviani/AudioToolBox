function color=UTIL_getColor(index)
    color=['b' 'g' 'y' 'r' 'c' 'm' 'k'];
    if (index==length(color))
        color=color(length(color));
    else
        color=color(mod(index, length(color)));
    end
