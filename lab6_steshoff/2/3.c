#include <stdio.h>
#include <unistd.h>

int main(void)
{
	int pid = fork();

    	int i;
	for (i = 0; i < 10; ++i)
		if (pid)
			fork();
    	
	sleep(5);

	return 0;
}
