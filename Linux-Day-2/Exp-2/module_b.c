#include <linux/module.h>
#include <linux/kernel.h>

extern int exported_function(int);  // Declare the external symbol

static int __init mod_b_init(void) {
    int val = exported_function(10);  // Call exported function
    printk(KERN_INFO "Module B: exported_function returned %d\n", val);
    return 0;
}

static void __exit mod_b_exit(void) {
    printk(KERN_INFO "Module B unloaded\n");
}

module_init(mod_b_init);
module_exit(mod_b_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Maneesh");
MODULE_DESCRIPTION("Module B: Using symbol from Module A");
