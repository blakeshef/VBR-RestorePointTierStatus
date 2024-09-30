# VBR Restore Point Tier Status

A simple script to find where restore points are created.

## About and Usage

In v12 of VBR there was an added feature for having multiple capacity tiers. While this is an amazing add, with the VBR GUI alone it's hard to tell where exactly restore points are located on which Capacity Tier Extent. This script aims to solve that per backup set by listing out where exactly each restore point is located.

To use this script, modify the first line to point to a backup set you are interested in looking at. Once modified run the script and it will give an output showing the location of the point on Performance Tier, Capacity Tier, and Archive Tier.

This script is bare bones for now, but I am looking to add more features like being able to point it to an entire SOBR and have it look through all the restore points there. This only works for Image Level backups for now.