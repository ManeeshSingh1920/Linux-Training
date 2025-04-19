#include <linux/init.h>
#include <linux/module.h>
#include <linux/gpio.h>
#include <linux/interrupt.h>
#include <linux/delay.h>

#define GPIO_IN   165  // example: rotary encoder A channel (e.g., gpma 5)
#define GPIO_OUT  170  // example: LED or output pin

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Maneesh");
MODULE_DESCRIPTION("Simple GPIO Toggle Driver");

static int __init gpio_test_init(void)
{
    int ret;

    pr_info("GPIO Driver: Init\n");

    // Request input GPIO
    ret = gpio_request(GPIO_IN, "gpio_input");
    if (ret) {
        pr_err("Failed to request GPIO_IN %d\n", GPIO_IN);
        return ret;
    }
    gpio_direction_input(GPIO_IN);

    // Request output GPIO
    ret = gpio_request(GPIO_OUT, "gpio_output");
    if (ret) {
        gpio_free(GPIO_IN);
        pr_err("Failed to request GPIO_OUT %d\n", GPIO_OUT);
        return ret;
    }
    gpio_direction_output(GPIO_OUT, 0);

    // Read and toggle once for demo
    if (gpio_get_value(GPIO_IN)) {
        gpio_set_value(GPIO_OUT, 1);
        pr_info("Input is HIGH, Output set to HIGH\n");
    } else {
        gpio_set_value(GPIO_OUT, 0);
        pr_info("Input is LOW, Output set to LOW\n");
    }

    return 0;
}

static void __exit gpio_test_exit(void)
{
    gpio_set_value(GPIO_OUT, 0);
    gpio_free(GPIO_OUT);
    gpio_free(GPIO_IN);
    pr_info("GPIO Driver: Exit\n");
}

module_init(gpio_test_init);
module_exit(gpio_test_exit);
