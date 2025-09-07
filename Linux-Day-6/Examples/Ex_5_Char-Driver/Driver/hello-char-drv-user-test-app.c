#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>

int main() {
    char buffer[256];
    int fd = open("/dev/hello_chr", O_RDWR); // open the character device (/dev/hello_chr) with read-write permissions (O_RDWR)
    if (fd < 0) {
        perror("open");
        return 1;
    }

    const char *msg = "Hello from user space!\n";
    ssize_t written = write(fd, msg, strlen(msg)); // it is used to send the message to the device
    if (written < 0) {
        perror("write");
        close(fd);
        return 1;
    }

    lseek(fd, 0, SEEK_SET); // this set the file pointer to the beginning of the device (SEEK_SET).

    ssize_t bytes_read = read(fd, buffer, sizeof(buffer) - 1); // read from the device and store the data in the buffer.
    if (bytes_read < 0) {
        perror("read");
        close(fd);
        return 1;
    }

    buffer[bytes_read] = '\0';  // null terminate
    printf("Bytes read = %zd\n", bytes_read);
    printf("Data from hello char driver i.e. kernel space: %s", buffer);

    close(fd); // The device file is closed using close()
    return 0;
}

