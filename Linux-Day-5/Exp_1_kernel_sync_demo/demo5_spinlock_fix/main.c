#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/kthread.h>
#include <linux/delay.h>
#include <linux/spinlock.h>

#define ITERATIONS 500000

static struct task_struct *thread1;
static struct task_struct *thread2;
static int counter = 0;

#ifdef USE_SYNC
static spinlock_t my_lock;
#endif

int thread_fn(void *data)
{
    int i;
    for (i = 0; i < ITERATIONS; i++) {
#ifdef USE_SYNC
        spin_lock(&my_lock);
        counter++;
        spin_unlock(&my_lock);
#else
        counter++;
#endif
        cpu_relax();
    }
    return 0;
}

static int __init mod_init(void)
{
#ifdef USE_SYNC
    printk(KERN_INFO "Demo: Using spinlock synchronization\n");
    spin_lock_init(&my_lock);
#else
    printk(KERN_INFO "Demo: Using plain counter (no sync)\n");
#endif

    counter = 0;
    thread1 = kthread_run(thread_fn, NULL, "thread1");
    thread2 = kthread_run(thread_fn, NULL, "thread2");

    msleep(2000);

    printk(KERN_INFO "Expected Counter = %d\n", 2 * ITERATIONS);
    printk(KERN_INFO "Actual Counter   = %d\n", counter);
    return 0;
}

static void __exit mod_exit(void)
{
    printk(KERN_INFO "Exiting module\n");
}

module_init(mod_init);
module_exit(mod_exit);
MODULE_LICENSE("GPL");

