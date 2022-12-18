#include <stdio.h>

extern char** environ;

int main(int argc, const char** argv)
{
	int cnt = 0;
	char** ptr = environ;
	while (*ptr++) cnt++;

	printf("Number of environment variables: %d, argc: %d\n", cnt, argc);

	return 0;
}
