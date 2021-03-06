#include <unistd.h>
#include <stdio.h>
#include <getopt.h>
#include <errno.h>
#include <stdlib.h>

#include <string>

namespace {

class VFS
{
public:
    virtual ~VFS() {}

    virtual int rename(const char *oldpath, const char *newpath) = 0;
    virtual int unlink(const char *path) = 0;
};

class RealVFS: public VFS
{
public:
    int rename(const char *oldpath, const char *newpath)
    {
        return ::rename(oldpath, newpath);
    }

    int unlink(const char *path)
    {
        return ::unlink(path);
    }
};

class FakeVFS: public VFS
{
    unsigned m_ops;
    unsigned m_failAt;

public:
    FakeVFS(unsigned failAt)
        : m_ops(0),
          m_failAt(failAt)
    {
    }
    
    int rename(const char*, const char*)
    {
        ++m_ops;
        if (m_ops == m_failAt) {
            printf("Fake rename FAIL\n");
            errno = EIO;
            return -1;
        }
        return 0;
    }

    int unlink(const char*)
    {
        ++m_ops;
        if (m_ops == m_failAt) {
            printf("Fake unlink FAIL\n");
            errno = EIO;
            return -1;
        }
        return 0;
    }
};

void recover(const char *to, VFS *vfs)
{
    std::string backup(to);
    backup += "~";

    printf("rename(%s, %s)\n", backup.c_str(), to);
    int rc = vfs->rename(backup.c_str(), to);
    if (rc<0) {
        perror("emergency restore");
    }
}

bool doRename(const char *from, const char *to, VFS *vfs)
{
    std::string backup(to);
    backup += "~";
    printf("unlink(%s)\n", backup.c_str());
    int rc = vfs->unlink(backup.c_str());
    if (rc<0) {
        perror("unlink backup");
        return false;
    }
    printf("rename(%s, %s)\n", to,  backup.c_str());
    rc = vfs->rename(to, backup.c_str());
    if (rc<0) {
        perror("rename backup");
        return false;
    }

    printf("rename(%s, %s)\n", from, to);
    rc = vfs->rename(from, to);
    if (rc<0) {
        perror("rename");

        recover(to, vfs);
        return false;
    }
    printf("%s -> %s OK\n", from, to);
    return true;
}

int doRenames(char *names[], unsigned count, VFS *vfs)
{
    unsigned progress = 0;
    bool ok = true;

    for ( ; progress < count; progress += 2) {
        if (!doRename(names[progress], names[progress+1], vfs)) {
            ok = false;
            break;
        }
    }

    if (!ok) {
        while (progress > 0) {
            progress -= 2;
            recover(names[progress+1], vfs);
        }
    }

    return ok ? 0 : 1;
}

void Usage(FILE *f)
{
    fprintf(f, "usage: dirswitch [opts] from to [from to]...\n");
    fprintf(f, "    Perform all or none of a bunch of directory renames\n\n");
    fprintf(f, "Options are:\n");
    fprintf(f, "  -h, --help\n");
    fprintf(f, "  -n, --dryrun   Just print what would be done\n");
    fprintf(f, "      --fail N   Do a dry run and pretend that operation N fails\n");
}

int dirswitch(int argc, char *argv[])
{
    static const struct option options[] =
    {
        { "help", no_argument, NULL, 'h' },
        { "dry-run", no_argument, NULL, 'n' },
	{ "fail", required_argument, NULL, 1 },
    };

    bool dryRun = false;
    unsigned failAt = 0;

    int option_index, option;
    while ((option = getopt_long(argc, argv, "hn", options, &option_index))
           != -1)
    {
        switch (option) {
        case 'h':
            Usage(stdout);
            return 0;
        case 'n':
            dryRun = true;
            break;
        case 1:
            dryRun = true;
            failAt = strtoul(optarg, NULL, 10);
            break;
        default:
            Usage(stderr);
            return 1;
        }
    }

    if (argc == optind || ((argc-optind) % 2)) {
        Usage(stderr);
        return 1;
    }

    FakeVFS fakeVFS(failAt);
    RealVFS realVFS;
    
    return doRenames(argv+optind, argc-optind, dryRun ? (VFS*)&fakeVFS
                     : (VFS*)&realVFS);
}

} // anon namespace

int main(int argc, char *argv[])
{
    return dirswitch(argc, argv);
}
