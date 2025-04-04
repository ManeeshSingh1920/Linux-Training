#!/bin/bash

# Step 1: Create a directory
echo "Creating a directory named 'test_dir'..."
mkdir test_dir

# Step 2: Create a file inside the directory
echo "Creating a file named 'example.txt' inside 'test_dir'..."
touch test_dir/example.txt

# Step 3: Write some content to the file
echo "Adding content to 'example.txt'..."
echo "Hello, this is a sample text file!" > test_dir/example.txt

# Step 4: Display the file content
echo "Displaying the content of 'example.txt'..."
cat test_dir/example.txt

# Step 5: Copy the file to a new location
echo "Copying 'example.txt' to the current directory..."
cp test_dir/example.txt ./copied_example.txt

# Step 6: List the files in the directory
echo "Listing files in 'test_dir'..."
ls -l test_dir

# Step 7: Clean up
echo "Cleaning up..."
rm -r test_dir
rm copied_example.txt

echo "Script execution complete!"