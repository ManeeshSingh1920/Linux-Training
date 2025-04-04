#include <linux/init.h>
#include <linux/module.h>
#include <linux/fs.h>
#include <linux/uaccess.h>

#define DEVICE_NAME "hello_chr"
static int major;

static char message[256] = "Hello from kernel!\n";
static int msg_len = 0;

static int dev_open(struct inode *inode, struct file *file) {
    pr_info("hello_chr: device opened\n");
    return 0;
}

static ssize_t dev_read(struct file *file, char __user *buf, size_t len, loff_t *offset) {
    pr_info("hello_chr: device read\n");
    return simple_read_from_buffer(buf, len, offset, message, msg_len);
}

static ssize_t dev_write(struct file *file, const char __user *buf, size_t len, loff_t *offset) {
    pr_info("hello_chr: device write\n");
    memset(message, 0, sizeof(message)); // clear buffer before write
    msg_len = simple_write_to_buffer(message, sizeof(message), offset, buf, len);
    pr_info("hello_chr: written message: %s\n", message);
    return msg_len;
}

static int dev_release(struct inode *inode, struct file *file) {
    pr_info("hello_chr: device closed\n");
    return 0;
}

static struct file_operations fops = {
    .owner = THIS_MODULE,
    .open = dev_open,
    .read = dev_read,
    .write = dev_write,
    .release = dev_release,
};

static int __init hello_init(void) {
    major = register_chrdev(0, DEVICE_NAME, &fops);
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
