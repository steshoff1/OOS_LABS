#include <stdio.h>
#include <unistd.h>

int main()
{
    	int pid = fork();
    	if (!pid)
        	printf("cpid: %d, ppid:%d\n", getpid(), getppid());

	return 0;
}
