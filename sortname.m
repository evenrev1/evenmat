function nn=sortname(nn)
s=getnamelist(nn);
[ans,is]=sort(s);
nn=nn(is);
