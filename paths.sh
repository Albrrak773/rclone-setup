#!/bin/bash
declare -A syncs=(
    # sync
    # ["Gsync"]="/run/media/albrrak773/colorful SSD/Rclone/Gsync"

    # media (legally obtained ofcourse)
    ["Movies"]="/run/media/albrrak773/2T External Disk/Movies"
    ["Backup (legacy)"]="/run/media/albrrak773/2T External Disk/Backup (legacy)"
    ["Anime"]="/run/media/albrrak773/5T Westren Digital Disk/Anime"
    ["my-media"]="/run/media/albrrak773/Mass Storage Disk/media"

    # minecraft
    ["Minecraft"]="/run/media/albrrak773/colorful SSD/CurseForge modpacks/Instances"

)

# a back up is a one-way copy (still doesn't repeat files that exist)
declare -A backups=(

)