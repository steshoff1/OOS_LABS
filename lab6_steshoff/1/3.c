#include <stdio.h>

extern char** environ;

int main()
{
	char** ptr;
	for (ptr = environ; *ptr && ptr - environ < 10; ++ptr)
		printf("[%d] %s\n", ptr - environ, *ptr);

	return 0;
}
