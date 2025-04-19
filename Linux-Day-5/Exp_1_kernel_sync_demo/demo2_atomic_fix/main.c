#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/kthread.h>
#include <linux/delay.h>
#include <linux/atomic.h>

#define ITERATIONS 500000

static struct task_struct *thread1;
static struct task_struct *thread2;
static atomic_t a_counter = ATOMIC_INIT(0);
static int counter = 0;

int thread_fn(void *data)
{
    int i;
    for (i = 0; i < ITERATIONS; i++) {
#ifdef USE_SYNC
        atomic_inc(&a_counter);
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
    printk(KERN_INFO "Demo: Using atomic operation\n");
#else
    printk(KERN_INFO "Demo: Using plain counter (non-atomic)\n");
#endif

    counter = 0;
    atomic_set(&a_counter, 0);

    thread1 = kthread_run(thread_fn, NULL, "thread1");
    thread2 = kthread_run(thread_fn, NULL, "thread2");

    msleep(2000);

    printk(KERN_INFO "Expected Counter = %d\n", 2 * ITERATIONS);
#ifdef USE_SYNC
    printk(KERN_INFO "Actual Counter   = %d\n", atomic_read(&a_counter));
#else
    printk(KERN_INFO "Actual Counter   = %d\n", counter);
#endif
    return 0;
}

static void __exit mod_exit(void)
{
    printk(KERN_INFO "Exiting module\n");
}

module_init(mod_init);
module_exit(mod_exit);
MODULE_LICENSE("GPL");

