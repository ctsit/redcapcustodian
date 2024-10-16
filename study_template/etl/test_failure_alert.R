print("Hello, example host!")

args <- commandArgs(trailingOnly = TRUE)

# Test that the command line args are read
print(paste0("This is a ", args[1]))
print(paste0("This is ", args[2]))

# This will fail as test.csv does not exist.
read.csv("test.csv")

