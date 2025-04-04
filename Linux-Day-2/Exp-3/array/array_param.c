#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Maneesh");
MODULE_DESCRIPTION("Module with an array parameter");

static int my_array[5] = {1, 2, 3, 4, 5};
static int arr_argc = 0;
module_param_array(my_array, int, &arr_argc, 0644);
MODULE_PARM_DESC(my_array, "An array of integers (max 5 elements)");

static int __init mod_init(void) {
    int i;
    printk(KERN_INFO "Array Module loaded!\n");
    for (i = 0; i < arr_argc; i++) {
        printk(KERN_INFO "my_array[%d] = %d\n", i, my_array[i]);
    }
    return 0;
}

static void __exit mod_exit(void) {
    printk(KERN_INFO "Array Module unloaded!\n");
}

module_init(mod_init);
module_exit(mod_exit);
