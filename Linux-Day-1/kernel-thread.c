#include <linux/module.h>
#include <linux/kthread.h>
#include <linux/delay.h>

static struct task_struct *task;

int my_thread(void *arg) {
    while (!kthread_should_stop()) {
        pr_info("My Kernel Thread Running...\n");
        ssleep(1);
    }
    return 0;
}

static int __init my_init(void) {
    pr_info("Loading My Kernel Thread ...\n");
    task = kthread_run(my_thread, NULL, "my_kthread");
    return 0;
}

static void __exit my_exit(void) {
    pr_info("Stopping My Kernel Thread ...\n");
    kthread_stop(task);
}

module_init(my_init);
module_exit(my_exit);
MODULE_LICENSE("GPL");
