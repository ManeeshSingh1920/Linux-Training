// panic_mod.c
#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Maneesh");
MODULE_DESCRIPTION("Simple Kernel Panic Module");
MODULE_VERSION("1.0");

static int __init panic_mod_init(void) {
    pr_info("panic_mod: Initializing module and triggering panic!\n");

    // Intentional null pointer dereference
    int *p = NULL;
    *p = 42;  // 💥 Kernel will crash here

    return 0;
}

static void __exit panic_mod_exit(void) {
    pr_info("panic_mod: Exiting module (this won't be called if panic happens).\n");
}

module_init(panic_mod_init);
module_exit(panic_mod_exit);

