---
created: 2026-05-27T17:02
updated: 2026-05-27T17:15
tags:
  - task
status: In progress
depends_on: []
dependency_completion: 100%
---
```meta-bind
INPUT[listSuggester(
	optionQuery(#task)
):depends_on]
```

```dataviewjs
const {update} = this.app.plugins.plugins["metaedit"].api;
const result = {result: {}};
await dv.view('_Assets/Scripts/dv-StatusCategoryUtils', result);
update('dependency_completion', `${result.result}%`, dv.current().file.path)
```
```dataviewjs
// 1. Get all tasks from the current page that are NOT completed
let tasks = dv.current().file.tasks.where(t => !t.completed);

// 2. Check if there are any tasks found
if (tasks.length > 0) {
    // Optional: Add a header so you know what this list is
    dv.header(3, "To Do");
    
    // 3. Render the list
    dv.taskList(tasks);
}
```
---

## Requirements & Preparation

- **Processor Capability:** Virtualization must be enabled in the BIOS/UEFI.
  - **Host CPU (AMD Ryzen 5 5600):** AMD-V / SVM (Secure Virtual Machine) must be active.
- **Installation Image (.ISO):** You need the official installer image **ending in `.iso`** to boot and install onto a clean VirtIO Zvol in TrueNAS SCALE. 
  - **Where to Download:** 
    - The official website portal is [blissos.org](https://blissos.org/).
    - The direct folder for stable releases is the [BlissOS-x86 SourceForge Repository](https://sourceforge.net/projects/blissos-x86/files/).
    - Direct iso link for [OS16](https://sourceforge.net/projects/blissos-x86/files/Official/BlissOS16/Gapps/Generic/Bliss-v16.9.7-x86_64-OFFICIAL-gapps-20241011.iso/download)
  - **Selecting the Correct File:**
    - Navigate into the official release folders (e.g., `Official/` -> `BlissOS 14` / `BlissOS 15` / `BlissOS 16`).
    - Choose files containing **`OFFICIAL`** in their name (e.g., `Bliss-v14.10-x86_64-OFFICIAL-...iso`) to ensure stability.
    - **`gapps` vs. `foss`:** Select a build containing **`gapps`** if you want Google Play Services and Play Store pre-installed. Choose **`foss`** if you prefer a completely open-source, Google-free version.
  - **What to AVOID:** Do **NOT** download preconfigured virtual disks (such as `.vmdk` or `.vdi` files from sites like OSBoxes). Those are designed as pre-installed templates for VirtualBox/VMware and will not boot or install correctly under TrueNAS SCALE's KVM virtualization.
- **Evaluation Warning:** Android is not natively optimized for virtualized displays and lacks specialized virtual GPU drivers. Running Bliss OS in a VM should be used for **evaluation, testing, or basic app debugging**, as it will not reflect the high performance achieved on bare-metal hardware.

---

## 1. TrueNAS SCALE Virtual Machine Wizard

This configuration is optimized specifically for running Bliss OS on **TrueNAS SCALE (Goldeye 25.10.1)** using KVM/QEMU. Follow the step-by-step fields exactly as laid out in the 4 creation wizard screens below.

### Step 1: Operating System

Configure the system parameters and enable remote access display:

| Field | Configuration Value | Context / Notes |
| :--- | :--- | :--- |
| **Guest Operating System** | `Linux` | Standard Linux compatibility. |
| **Name** | `blissos_android` | Unique virtual machine hostname. |
| **Description** | *Optional* | Can be left blank. |
| **System Clock** | `Local` | Sets guest clock to local timezone offset. |
| **Boot Method** | `UEFI` | **CRITICAL:** Modern Bliss OS builds require UEFI. Do NOT use Legacy BIOS. |
| **Enable Secure Boot** | [ ] *Unchecked* | Disables signature checks (required for custom Android kernels). |
| **Enable Trusted Platform Module (TPM)**| [ ] *Unchecked* | TPM is unnecessary for Android-x86. |
| **Shutdown Timeout** | `90` | Default system timeout in seconds. |
| **Start on Boot** | [x] *Checked* | Automatically boots the VM on TrueNAS system startup. |
| **Enable Display (VNC)** | [x] *Checked* | Exposes a VNC interface for system display. |
| **Bind** | `0.0.0.0` | Listens on all host interfaces for local VNC client access. |
| **Password** | *See 1Password Secret* | **CRITICAL:** Set VNC connection password. |

---

### Step 2: CPU And Memory

Ensure correct CPU instruction sets are passed to the guest to optimize translation:

| Field | Configuration Value | Context / Notes |
| :--- | :--- | :--- |
| **Virtual CPUs** | `2` | Number of virtual sockets. |
| **Cores** | `2` | Slices from your AMD Ryzen 5 5600. |
| **Threads** | `2` | Maps threads to core sockets. Total product (8) is well within limits. |
| **Optional: CPU Set** | *Blank* | Leave unpinned for standard scheduling. |
| **Pin vcpus** | [ ] *Unchecked* | Do not lock threads to specific host CPU cores. |
| **CPU Mode** | **`Host Passthrough`** | **CRITICAL:** Passes your physical CPU instruction sets directly to Android, improving engine translation. |
| **Memory Size** | `4 GiB` | Crucial sweet spot for modern Android-x86 smooth operations. |
| **Minimum Memory Size** | `512 MiB` | Lower boundary for guest memory allocation ballooning. |
| **Optional: NUMA nodeset** | *Blank* | Not required for single-socket AMD 5600 setups. |

---

### Step 3: Disks

Configure high-speed ZFS backed block storage using VirtIO:

*   Select **Create new disk image** (Selected).
*   Ensure **Import Image** is [ ] *Unchecked*.

| Field | Configuration Value | Context / Notes |
| :--- | :--- | :--- |
| **Select Disk Type** | **`VirtIO`** | High-performance paravirtualized disk driver. Supported in Bliss OS kernels. |
| **Zvol Location** | `ssd-data0/vm-data` | Fast SSD-backed pool dataset allocated for VM disks. |
| **Size** | `16 GiB` | Sufficient capacity for testing and base system applications. |

---

### Step 4: Network Interface

Map paravirtualized network controllers to the host physical interface bridge:

| Field | Configuration Value | Context / Notes |
| :--- | :--- | :--- |
| **Adapter Type** | **`VirtIO`** | Standard paravirtualized NIC driver. |
| **Mac Address** | `00:a0:98:18:5c:78` | Unique adapter address (matches your static allocation). |
| **Attach NIC** | `bond0` | Bind interface to physical network interface. |
| **Trust Guest Filters** | [ ] *Unchecked* | Keeps guest interface filters protected. |

---

### Step 5: CD-ROM / Installation Media
*   Once the VM shell is created, add a **CD-ROM Device** mapped to your uploaded Bliss OS `.iso` file.
*   Arrange boot order in VM devices so that the **CD-ROM** is placed first for initial installation, and then shifted behind the **VirtIO Zvol** once setup is complete.

---

## 2. Step-by-Step OS Installation

1. **Boot the VM:**
   - Power on `blissos_android` and connect using your preferred VNC client (using the password from `op://Private/BlissOS AndroidVM VNC/password`).
   - On the GRUB boot menu, select **`Installation - Install Bliss-OS to harddisk`**.

2. **Disk Partitioning (`cfdisk`):**
   - In the partition selection screen, choose **`Create/Modify partitions`**.
   - Select **`gpt`** (required since we configured the boot method as UEFI in Step 1).
   - **Create EFI Partition:**
     - Select **New** -> Size: `512MB` -> Type: **`EFI System`**.
   - **Create Main OS Partition:**
     - Select the remaining free space -> **New** -> Type: **`Linux filesystem`** (or default).
   - **Write & Quit:**
     - Select **Write**, type `yes` to confirm, and then select **Quit** to exit the utility.

3. **Install the OS:**
   - Back in the installer screen, choose the main partition (usually `sda2` or `vda2`).
   - Select **`ext4`** as the filesystem format.
   - Confirm formatting when prompted.
   - Answer **`Yes`** to the following crucial installer questions:
     - *"Do you want to install boot loader GRUB?"*
     - *"Do you want to install EFI GRUB2?"*
     - *"Do you want to format the boot partition?"* (Formats the EFI bootloader partition as FAT32).
     - *"Do you want to install /system directory as read-write?"* (Crucial for graphics troubleshooting and tweaking).
   - Once the progress bar reaches 100%, choose **Reboot**.
   - **CRITICAL:** Stop the VM and edit the devices in TrueNAS. Remove/eject the CD-ROM ISO or move the boot priority so the VM boots directly from the VirtIO zvol disk.

---

## 3. Post-Installation & Graphics Troubleshooting

A common issue with Android-x86 running in KVM hypervisors is booting to a **black screen** or **stuck at a blinking console cursor** immediately after the GRUB boot menu. This is due to virtualized display mismatches.

### 3.1 Temporary Workaround (GRUB Edit)

Use this method to bypass a stuck boot and verify configuration flags:

1. Turn on the VM. When the GRUB bootloader appears, quickly press **`e`** to edit the first boot option.
2. Locate the line that starts with `kernel /android-.../kernel` or `linux /kernel`.
3. Press the right arrow key to reach the end of the line, add a single space, and append one of the following compatibility flags:
   - **`nomodeset`** (Disables kernel mode setting, forcing basic hardware rendering).
   - **`xforcevesa`** (Forces basic VESA graphics driver).
   - **`video=1280x720`** or **`video=1024x768`** (Forces a set framebuffer resolution).
   - **`EXTMOD=virgl`** (Use this only if 3D acceleration/VirtIO GPU active, otherwise stick to basic framebuffer drivers).
4. Press **`Enter`** (and then **`b`** to boot) or **`F10`** to boot with the modified boot parameter.

---

### 3.2 Permanent Graphics Patching

Once you have verified which flag successfully boots the system, apply it permanently so you do not have to edit GRUB on every start:

1. Turn on the VM and select **`Android-x86 (Debug Mode)`** from the GRUB boot menu.
2. Wait for the command-line console to finish loading. If you do not see a prompt, press **`Enter`**.
3. Remount the system/boot partition with read-write permissions:
   ```sh
   mount -o remount,rw /mnt
   ```
4. Edit the GRUB configuration file (typically `/mnt/grub/menu.lst` or `/mnt/boot/grub/grub.cfg` depending on partition layout) using the standard `vi` or `nano` editor:
   ```sh
   vi /mnt/grub/menu.lst
   ```
5. Find the primary boot title entry block (usually the first entry). Locate the `kernel` or `linux` command line and append your working graphics flag (e.g., `nomodeset`) to the end of the list:
   ```txt
   title Bliss OS (Stable)
       kernel /android-x86/kernel root=/dev/ram0 androidboot.selinux=permissive nomodeset
       initrd /android-x86/initrd.img
   ```
6. Save and exit the editor (in `vi`, type `:wq` and press `Enter`).
7. Remount to read-only and force reboot:
   ```sh
   mount -o remount,ro /mnt
   reboot -f
   ```
8. The VM will now boot reliably into the Android graphical user interface on all future starts.
