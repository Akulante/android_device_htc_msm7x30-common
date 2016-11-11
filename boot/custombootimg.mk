# Copyright (C) 2011-2013 The CyanogenMod Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

LOCAL_PATH := $(call my-dir)
LZMA_BIN := $(shell which lzma)

uncompressed_ramdisk := $(PRODUCT_OUT)/ramdisk.cpio
$(uncompressed_ramdisk): $(INSTALLED_RAMDISK_TARGET)
	gunzip -c $< > $@

INSTALLED_BOOTIMAGE_TARGET := $(PRODUCT_OUT)/boot.img
$(INSTALLED_BOOTIMAGE_TARGET): $(PRODUCT_OUT)/kernel $(uncompressed_ramdisk) $(INSTALLED_RAMDISK_TARGET) $(PRODUCT_OUT)/utilities/toybox $(MKBOOTIMG) $(MINIGZIP) $(INTERNAL_BOOTIMAGE_FILES)
	$(call pretty,"Target boot image: $@")

	$(hide) rm -fr $(PRODUCT_OUT)/combinedroot
	$(hide) mkdir -p $(PRODUCT_OUT)/combinedroot/sbin

	$(hide) cp $(uncompressed_ramdisk) $(PRODUCT_OUT)/combinedroot/sbin/
	$(hide) cp $(PRODUCT_OUT)/utilities/toybox $(PRODUCT_OUT)/combinedroot/sbin/toybox_init

	$(hide) $(MKBOOTFS) $(PRODUCT_OUT)/combinedroot/ > $(PRODUCT_OUT)/combinedroot.cpio
	$(hide) cat $(PRODUCT_OUT)/combinedroot.cpio | $(LZMA_BIN) -9 > $(PRODUCT_OUT)/combinedroot.fs

	$(hide) $(MKBOOTIMG) --kernel $(PRODUCT_OUT)/kernel --ramdisk $(PRODUCT_OUT)/combinedroot.fs --base $(BOARD_KERNEL_BASE) --pagesize 4096 -o $(INSTALLED_BOOTIMAGE_TARGET)
	@echo -e ${CL_CYN}"Made boot image: $@"${CL_RST}
