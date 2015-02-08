function result = linear_interp(y1,y2,x)

% use weighted sum method of interpolating
result = x*y2 + (1-x)*y1;
