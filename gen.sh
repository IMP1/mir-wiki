# Check to see if site_generation exists
# Also save current dir and use it in the generate call
# Basically get rid of these ugle hard-coded directory paths
PREV_DIR=$(pwd)
cd /c/Users/huwtaylor/Projects/site_generation
ruby generate \
 --source /c/Users/huwtaylor/Projects/mir/wiki \
 --source-branch content \
 --target /c/Users/huwtaylor/Projects/mir/wiki \
 --target-branch master
cd $PREV_DIR
