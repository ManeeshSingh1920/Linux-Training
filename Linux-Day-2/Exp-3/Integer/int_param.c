#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Maneesh");
MODULE_DESCRIPTION("Module with an integer parameter");

static int my_int = 10;
module_param(my_int, int, 0644);
MODULE_PARM_DESC(my_int, "An integer parameter");

static int __init mod_init(void) {
    printk(KERN_INFO "Integer Module loaded! my_int = %d\n", my_int);
    return 0;
}

static void __exit mod_exit(void) {
    printk(KERN_INFO "Integer Module unloaded!\n");
}

module_init(mod_init);
module_exit(mod_exit);
