#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/gpio.h>
#include <linux/init.h>

#define GPIO_IN 160  // In telehcip we have GPIOMA_07 i.e 160 pin number

static int __init gpio_example_init(void)
{
    int ret;

    printk(KERN_INFO "GPIO Driver: Initializing\n");

    // Request the GPIO
    ret = gpio_request(GPIO_IN, "gpio_input_pin");
    if (ret) {
        printk(KERN_ERR "Failed to request GPIO %d\n", GPIO_IN);
        return ret;
    }

    // Set direction
    ret = gpio_direction_input(GPIO_IN);
    if (ret) {
        printk(KERN_ERR "Failed to set GPIO direction\n");
        gpio_free(GPIO_IN);
        return ret;
    }

    // Read and print value
    int val = gpio_get_value(GPIO_IN);
    printk(KERN_INFO "GPIO %d value is %d\n", GPIO_IN, val);

    return 0;
}

static void __exit gpio_example_exit(void)
{
    printk(KERN_INFO "GPIO Driver: Exiting\n");
    gpio_free(GPIO_IN);
}

module_init(gpio_example_init);
module_exit(gpio_example_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Maneesh");
MODULE_DESCRIPTION("Simple GPIO Input Reader");

