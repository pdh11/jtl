#include <unistd.h>
#include <semaphore.h>
#include <fcntl.h>
#include <stdio.h>
#include <errno.h>
#include <signal.h>
#include <stdlib.h>
#include <string.h>

void SignalHandler(int x)
{
    sem_unlink("/onesync");
    exit(1);
}

int main(int argc, char *argv[])
{
    struct sigaction ssa;
    memset(&ssa, '\0', sizeof(ssa));
    ssa.sa_handler = SignalHandler;
    
    sigaction(SIGINT, &ssa, NULL);

    sem_t *sem = sem_open("/onesync", O_CREAT, 0666, 1);

    if (sem == SEM_FAILED)
    {
	perror("sem_open");
	return 1;
    }

    int rc = sem_trywait(sem);
    if (rc < 0 && errno == EAGAIN)
    {
	// Someone else running
	sem_unlink("/onesync");
	return 0;
    }
	
    if (rc < 0)
    {
	perror("sem_trywait");
	sem_unlink("/onesync");
	return 1;
    }

    sync();

    sem_post(sem);
    sem_unlink("/onesync");
    
    return 0;
}
