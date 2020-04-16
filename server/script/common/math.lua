--math.lua

math_ex = {}
function math_ex.round(n)
    return math.floor(0.5 + n)
end

function math_ex.rand(n1, n2)
    return math.random(n1 * 1000000, n2 * 1000000)/1000000
end

--区间检查
function math_ex.region(n, min, max)
    if n < min then
        return min
    elseif n > max then
        return max
    end
    return n
end

function math_ex.max(n, max)
    if n < max then
        return max
    end
    return n
end

function math_ex.min(n, min)
    if n > min then
        return min
    end
    return n
end
