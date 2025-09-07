#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/usb.h>
#include <linux/hid.h>

// Probe function: called when a matching USB device is connected
static int my_usb_probe(struct usb_interface *interface,
                        const struct usb_device_id *id)
{
    printk(KERN_INFO "[Ankur_USB_NOTIFIER] USB device plugged in: vendor=%04x, product=%04x\n",
           id->idVendor, id->idProduct);
    return 0;
}

// Disconnect function: called when the USB device is disconnected
static void my_usb_disconnect(struct usb_interface *interface)
{
    printk(KERN_INFO "[Ankur_USB_NOTIFIER] USB device unplugged\n");
}

// USB device ID table: match HID keyboard and mouse devices
static struct usb_device_id my_usb_table[] = {
    { USB_INTERFACE_INFO(USB_INTERFACE_CLASS_HID, USB_INTERFACE_SUBCLASS_BOOT, USB_INTERFACE_PROTOCOL_KEYBOARD) },
    { USB_INTERFACE_INFO(USB_INTERFACE_CLASS_HID, USB_INTERFACE_SUBCLASS_BOOT, USB_INTERFACE_PROTOCOL_MOUSE) },
    {} // Terminating entry
};
MODULE_DEVICE_TABLE(usb, my_usb_table);

// USB driver structure
static struct usb_driver my_usb_driver = {
    .name = "my_usb_driver",
    .id_table = my_usb_table,
    .probe = my_usb_probe,
    .disconnect = my_usb_disconnect,
};

// Register the USB driver
module_usb_driver(my_usb_driver);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Ankur Pandey");
MODULE_DESCRIPTION("USB Keyboard/Mouse detector kernel module with unique logging");

