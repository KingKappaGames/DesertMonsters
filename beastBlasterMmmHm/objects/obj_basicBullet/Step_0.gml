if (live_call()) return live_result;

x += xChange;
y += yChange;

bulletHeight -= bulletDrop;
if(bulletHeight <= 0) {
	hit();
}