#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/kthread.h>
#include <linux/delay.h>
#include <linux/semaphore.h>
#include <linux/mutex.h>

#define ITERATIONS 5

static struct task_struct *thread1;
static struct task_struct *thread2;
static int counter = 0;

static DEFINE_MUTEX(my_mutex);
static struct semaphore my_sema;

int thread_fn1(void *data)
{
    int i;
#if defined(USE_MUTEX)
    printk(KERN_INFO "[Thread1] Locking mutex\n");
    mutex_lock(&my_mutex);
#elif defined(USE_SEMAPHORE)
    printk(KERN_INFO "[Thread1] Downing semaphore\n");
    down(&my_sema);
#endif

    for (i = 0; i < ITERATIONS; i++) {
        counter++;
        printk(KERN_INFO "[Thread1] Counter = %d\n", counter);
        msleep(100);
    }

    printk(KERN_INFO "[Thread1] Holding lock, Thread2 will try to unlock it\n");
    return 0;
}

int thread_fn2(void *data)
{
    msleep(500);  // let thread1 acquire lock first

#if defined(USE_MUTEX)
    printk(KERN_INFO "[Thread2] Trying to unlock mutex (wrong thread!)\n");
    mutex_unlock(&my_mutex);  // This is incorrect usage
#elif defined(USE_SEMAPHORE)
    printk(KERN_INFO "[Thread2] Up semaphore (even if not owner)\n");
    up(&my_sema);  // Allowed!
#endif

    return 0;
}

static int __init mod_init(void)
{
    printk(KERN_INFO "Demo: Comparing Mutex vs Semaphore Ownership Behavior\n");

    counter = 0;
    sema_init(&my_sema, 1);

    thread1 = kthread_run(thread_fn1, NULL, "thread1");
    thread2 = kthread_run(thread_fn2, NULL, "thread2");

    return 0;
}

static void __exit mod_exit(void)
{
    printk(KERN_INFO "Exiting demo module\n");
}

module_init(mod_init);
module_exit(mod_exit);
MODULE_LICENSE("GPL");

