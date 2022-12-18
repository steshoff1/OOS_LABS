#include <stdio.h>

extern char** environ;

// printenv | wc -l

int main()
{
	int cnt = 0;
	char** ptr = environ;
	while (*ptr++) cnt++;

	printf("Number of environment variables: %d\n", cnt);

	return 0;
}
