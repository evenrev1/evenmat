function cdots(x,y);
map=colormap;

x=x(:); y=y(:);
plot(x,y,'.'); axis manual; cla; hold on;
for i=1:length(y)
 plot(x(i),y(i),'.','color',map(i,:));
end
hold off;
