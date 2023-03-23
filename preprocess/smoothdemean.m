function nW = smoothdemean(W)

yy2 = smoothdata(W,'movmedian',100);
nW = W-yy2;
end