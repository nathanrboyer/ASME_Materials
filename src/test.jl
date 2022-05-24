nt = (a=1, b=2, c=3, d=4, e=5)

f(a,b,c,d) = a+b-c+d
g(; a, b, c, d, _...) = a+b-c+d

f(nt...)
g(; nt...)
g(; 1,2,3,4)