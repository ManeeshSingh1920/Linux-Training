#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Maneesh");
MODULE_DESCRIPTION("Module B - Depends on Module A");

// Declare dependency on Module A's symbol
extern void exported_function(void);

static int __init mod_init(void) {
    printk(KERN_INFO "Module B loaded\n");
    exported_function(); // Call Module A's function
    return 0;
}

static void __exit mod_exit(void) {
    printk(KERN_INFO "Module B unloaded\n");
}

module_init(mod_init);
module_exit(mod_exit);

// Specify that this module depends on Module A
MODULE_SOFTDEP("pre: module_a");
