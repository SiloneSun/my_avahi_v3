// test_getpwuid.c
#define _GNU_SOURCE
#include <pwd.h>
#include <stdio.h>
#include <errno.h>

int main() {
    struct passwd *pw = getpwuid(0);
    if (pw) {
        printf("Success: name=%s, uid=%d, dir=%s\n", pw->pw_name, pw->pw_uid, pw->pw_dir);
    } else {
        printf("getpwuid(0) failed, errno=%d (%s)\n", errno, strerror(errno));
    }
    return 0;
}