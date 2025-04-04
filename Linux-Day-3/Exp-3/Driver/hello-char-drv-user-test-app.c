#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>

int main() {
    char buffer[256];
    int fd = open("/dev/hello_chr", O_RDWR);
    if (fd < 0) {
        perror("open");
        return 1;
    }

    write(fd, "Hello from user space!\n", 18);
    lseek(fd, 0, SEEK_SET);
    read(fd, buffer, sizeof(buffer));
    printf("Data from hello char driver i.e. kernel space: %s", buffer);

    close(fd);
    return 0;
}
