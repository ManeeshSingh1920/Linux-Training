// hello_chr.c
#include <linux/init.h>
#include <linux/module.h>
#include <linux/fs.h>
#include <linux/uaccess.h>

#define DEVICE_NAME "hello_chr"
static int major;

static char message[256] = "Hello from kernel!\n";
static int msg_len = 0;


// this function is called when the device is opened by a process (via the open() system call).
static int dev_open(struct inode *inode, struct file *file) {
    pr_info("hello_chr: device opened\n");
    return 0;
}

//This function is called when a process tries to read from the device (via read() system call).
static ssize_t dev_read(struct file *file, char __user *buf, size_t len, loff_t *offset) {
    pr_info("hello_chr: device read at offset %lld\n", *offset);

    if (*offset >= msg_len) //checks if the offset is greater than or equal to msg_len. If so, returns 0, 
        return 0;  // EOF

    size_t bytes_to_read = min((size_t)(msg_len - *offset), len); // otherwise read the msg and check its size. 

    if (copy_to_user(buf, message + *offset, bytes_to_read)) // this function is used to copy data from kernel space to user space
        return -EFAULT;

    *offset += bytes_to_read;
    pr_info("hello_chr: %zu bytes read\n", bytes_to_read);
    return bytes_to_read;  // Returns the number of bytes read.
}


// This function is called when a process writes to the device (via write() system call).
static ssize_t dev_write(struct file *file, const char __user *buf, size_t len, loff_t *offset) {
    pr_info("hello_chr: device write\n");

    if (len > sizeof(message) - 1)
        len = sizeof(message) - 1;  // avoid overflow

    memset(message, 0, sizeof(message)); // Clear buffer
    if (copy_from_user(message, buf, len)) {   // This function is used to copy data from user space to kernel space.
        pr_err("hello_chr: failed to copy from user\n");
        return -EFAULT;
    }

    msg_len = len;
    message[msg_len] = '\0';  // Ensure null-terminated
    pr_info("hello_chr: written message: %s\n", message);
    return msg_len; // returns the number of bytes written
}



// This function is called when the device is closed (via close() system call).
static int dev_release(struct inode *inode, struct file *file) {
    pr_info("hello_chr: device closed\n");
    return 0;
}

// This structure defines the file operations for the character device.
static struct file_operations fops = {
    .owner = THIS_MODULE,
    .open = dev_open,
    .read = dev_read,
    .write = dev_write,
    .release = dev_release,
};

static int __init hello_init(void) {
    major = register_chrdev(0, DEVICE_NAME, &fops); // This function is to registers the character device with register_chrdev() and obtains the major number for the device.
    if (major < 0) {
        pr_alert("Failed to register character device\n");
        return major;
    }
    pr_info("hello_chr: registered with major number %d\n", major);
    msg_len = strlen(message);
    return 0;
}

static void __exit hello_exit(void) {
    unregister_chrdev(major, DEVICE_NAME);
    pr_info("hello_chr: unregistered\n");
}

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Maneesh");
MODULE_DESCRIPTION("Simple Char Driver Demo");
MODULE_VERSION("1.0");

module_init(hello_init);
module_exit(hello_exit);

