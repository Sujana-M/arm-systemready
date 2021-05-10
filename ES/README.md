SystemReady ES  <WIP>


<Introduction to SystemReady ES>

This section contains the build scripts and the live-images for the SystemReady ES Band


## Release details
 - Code Quality: REL v1.0 BETA-1
 - **The latest pre-built release of ACS is available for download here: [v20.10_REL3.0](https://github.com/ARM-software/arm-systemready-acs/tree/release/ES/prebuilt_images/v21.05_REL1.0_BETA-1)**
 - The BSA tests are written for version 1.0 of the BSA specification.
 - The BBR tests are written for version 1.0 of the BBR specification.
 - The compliance suite is not a substitute for design verification.
 - To review the ACS logs, Arm licensees can contact Arm directly through their partner managers.


##Steps to  build SystemReady ES ACS live image

## GitHub branch
- To pick up the release version of the code, checkout the release branch with the appropriate tag.
- To get the latest version of the code with bug fixes and new features, use the master branch.

## ACS build steps

### Prebuilt images
- Prebuilt images for each release are available in the prebuilt_images folder of the release branch. You can either choose to use these images or build your own image by following the steps below.
- To access the prebuilt_images, click this link : [prebuilt_images](https://github.com/ARM-software/arm-systemready-acs/tree/release/ES/prebuilt_images/)
- If you choose to use the prebuilt image, skip the build steps and jump to the test suite execution section below.

### Prerequisites
Before starting the ACS build, ensure that the following requirements are met:
 - Ubuntu 18.04 LTS with at least 64GB of free disk space.
 - Must use Bash shell.
 - User should have **sudo** privilege to install tools required for build
 
### Steps to build SystemReady ES ACS live image
1. Clone the [Arm-SystemReady](https://github.com/ARM-software/arm-systemready-acs) repo.

2. Navigate to the ES/scripts directory
 cd arm-systemready/ES/scripts

3. Run get_source.sh to download all related source for the build. Provide the sudo permission when prompted
 ./build-scripts/get_source.sh
 (Downloads source & tools required , give **sudo** password to install  depended tools )

4. To start the build of the ES ACS live image, execute the below step
 ./build-scripts/build-es-live-image.sh

5. The bootable image will be available in **/path-to-arm-systemready/ES/scripts/output** , if all of above steps are success.
filename: ES_acs_live_image.img
 
## Build output
This image comprises of two FAT file system partitions recognized by UEFI: <br />
- 'acs-results' <br />
  Stores logs and is used to install UEFI-SCT. (Approximate size: 120 MB) <br/>
- 'boot' <br />
  Contains bootable applications and test suites. (Approximate size: 400 MB)


### Verification of the ES Image on Qemu
Command to boot with qemu :
    sudo qemu-system-aarch64 -nographic -cpu cortex-a53 -M virt -m 1024 -bios (**path to QEMU_EFI**)/qemu-efi/QEMU_EFI.fd -drive if=virtio,format=raw,file=(**path to image**)/es_acs_live_image.img

   Note: qemu for aarch64 must be installed  before running above command  by `sudo apt-get install qemu-utils qemu-efi qemu-system-arm`

### Verification of the ES Image on Fixed Virtual Platform (FVP) environment

The steps for running the ES ACS on an FVP are

  - Modify 'run_model.sh' to add a model command argument that loads 'ir_acs_live_image.img' as a virtual disk image. For example, add

    `bp.virtioblockdevice.image path=<path to es image>/es_acs_live_image.img`

    to your model options.
    Or,
  - To launch the FVP model with script â€˜run_model.shâ€™ that supports -v option for virtual disk image, use the following command:
   `./run_model.sh -v <path to es imag>/es_acs_live_image.img`


### Automation
The test suite execution can be automated or manual. Automated execution is the default execution method when no key is pressed during boot. <br />
The live image boots to UEFI Shell. The different test applications can be run in following order:

1. [UEFI Shell application](https://github.com/ARM-software/bsa-acs/blob/master/README.md) for BSA compliance.
2. [SCT tests](https://github.com/ARM-software/bbr-acs/blob/master/README.md) for BBR compliance.
3. [FWTS tests](https://github.com/ARM-software/bbr-acs/blob/master/README.md) for BBR compliance.
4. [OS tests](https://github.com/ARM-software/bsa-acs/blob/master/README.md) for BSA compliance.

## Baselines for Open Source Software in this release:

- [Firmware Test Suite (FWTS) TAG: V21.03.00](http://kernel.ubuntu.com/git/hwe/fwts.git)

- [Server Base System Architecture (BSA)](https://github.com/ARM-software/bsa-acs) TAG: 1b3a37214fe6809e07e471f79d1ef856461bc803

- [UEFI Self Certification Tests (UEFI-SCT)](https://github.com/tianocore/edk2-test) TAG: b558bad25479ec83d43399673d7580294c81c8f8


## Security Implication
Arm Enterprise ACS test suite may run at higher privilege level. An attacker may utilize these tests as a means to elevate privilege which can potentially reveal the platform security assets. To prevent the leakage of secure information, it is strongly recommended that the ACS test suite is run only on development platforms. If it is run on production systems, the system should be scrubbed after running the test suite.


## License

Arm Enterprise ACS is distributed under Apache v2.0 License.


## Feedback, contributions, and support

 - For feedback, use the GitHub Issue Tracker that is associated with this repository.
 - For support, please send an email to "support-systemready-acs@arm.com" with details.
 - Arm licensees can contact Arm directly through their partner managers.
 - Arm welcomes code contributions through GitHub pull requests. For details, see "docs/Contributions.txt".
