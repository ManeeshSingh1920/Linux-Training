#!/bin/sh

# Create the required directories one by one for better error handling
echo "Creating directories..."

mkdir -p rootfs/bin || { echo "Failed to create rootfs/bin"; exit 1; }
mkdir -p rootfs/sbin || { echo "Failed to create rootfs/sbin"; exit 1; }
mkdir -p rootfs/etc || { echo "Failed to create rootfs/etc"; exit 1; }
mkdir -p rootfs/proc || { echo "Failed to create rootfs/proc"; exit 1; }
mkdir -p rootfs/sys || { echo "Failed to create rootfs/sys"; exit 1; }
mkdir -p rootfs/usr/bin || { echo "Failed to create rootfs/usr/bin"; exit 1; }
mkdir -p rootfs/usr/sbin || { echo "Failed to create rootfs/usr/sbin"; exit 1; }
mkdir -p rootfs/dev || { echo "Failed to create rootfs/dev"; exit 1; }

# Verify that the directories were created successfully
echo "Verifying directories creation..."
ls -l rootfs

# Copy busybox into bin directory
echo "Copying busybox..."
cp busybox/busybox rootfs/bin/ || { echo "Failed to copy busybox"; exit 1; }

# Verify busybox copy
echo "Verifying busybox copy..."
ls -l rootfs/bin/busybox

# Create symlinks for all busybox commands
busybox --list > /tmp/busybox_cmds.txt

echo "Creating symlinks for busybox commands..."
cd rootfs/bin
while read cmd; do
  if [ ! -e $cmd ]; then
    echo "Creating symlink for: $cmd"
    ln -s busybox $cmd
  fi
done < /tmp/busybox_cmds.txt
cd ../../

#rm /tmp/busybox_cmds.txt

# Create init script
echo "Creating init script..."
cat > rootfs/init << 'EOF'
#!/bin/sh
mount -t proc proc /proc
mount -t sysfs sys /sys
echo "Welcome to Embedded Linux Demo"
exec /bin/sh
EOF

# Make the init script executable
echo "Making init script executable..."
chmod +x rootfs/init || { echo "Failed to make init script executable"; exit 1; }

# Verify if init script is created
echo "Verifying init script creation..."
ls -l rootfs/init

# Final check
echo "Final directory listing of rootfs:"
ls -lR rootfs

# Packing rootfs into initramfs
echo "Packing rootfs into initramfs:"
cd rootfs
find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../initramfs.cpio.gz


