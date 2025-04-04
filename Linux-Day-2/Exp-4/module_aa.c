#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Maneesh");
MODULE_DESCRIPTION("Module A - Exports a symbol");

// Function to be exported
void exported_function(void) {
    printk(KERN_INFO "Hello from exported_function!\n");
}
EXPORT_SYMBOL(exported_function); // Make it available to other modules

static int __init mod_init(void) {
    printk(KERN_INFO "Module A loaded\n");
    return 0;
}

static void __exit mod_exit(void) {
    printk(KERN_INFO "Module A unloaded\n");
}

module_init(mod_init);
module_exit(mod_exit);
