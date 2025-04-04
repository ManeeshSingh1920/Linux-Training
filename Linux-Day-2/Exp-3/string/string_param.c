#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Maneesh");
MODULE_DESCRIPTION("Module with a string parameter");

static char *my_string = "default";
module_param(my_string, charp, 0644);
MODULE_PARM_DESC(my_string, "A string parameter");

static int __init mod_init(void) {
    printk(KERN_INFO "String Module loaded! my_string = %s\n", my_string);
    return 0;
}

static void __exit mod_exit(void) {
    printk(KERN_INFO "String Module unloaded!\n");
}

module_init(mod_init);
module_exit(mod_exit);
