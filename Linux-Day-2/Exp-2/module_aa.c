#include <linux/module.h>
#include <linux/kernel.h>

int exported_function(int x) {
    printk(KERN_INFO "exported_function called with %d\n", x);
    return x * 2;
}
EXPORT_SYMBOL(exported_function);  // <-- This makes it visible to other modules

static int __init mod_a_init(void) {
    printk(KERN_INFO "Module A loaded\n");
    return 0;
}

static void __exit mod_a_exit(void) {
    printk(KERN_INFO "Module A unloaded\n");
}

module_init(mod_a_init);
module_exit(mod_a_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Maneesh");
MODULE_DESCRIPTION("Module A: Exporting symbol");
