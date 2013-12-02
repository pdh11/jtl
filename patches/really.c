/* really.c */

#include <unistd.h>
#include <stdio.h>

int main( int argc, char *argv[] )
{
    if ( argc < 2 )
    {
	fprintf( stderr, "Usage: %s <cmd> [<args>]\n", argv[0] );
	return 1;
    }
    setuid(0);
    setgid(0);
    execvp( argv[1], argv+1 ); // If this returns, it's an error
    perror( argv[1] );
    return 1;
}
