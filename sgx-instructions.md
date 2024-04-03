Setting Up Intel SGX on Ubuntu

To get started with using SGX (Software Guard Extensions) on an Ubuntu machine for securing parts of a Threshold Signature Scheme (TSS) algorithm, you'll need to follow several steps. SGX provides a way to execute code and handle data in a secure environment, called an enclave, protecting the integrity and confidentiality of the code and data from outside access, including privileged system software.

1. Check Hardware and Enable SGX

- Ensure your CPU supports SGX and that it's enabled in the BIOS.
- Check CPU support by looking for SGX in the processor specifications or using a tool like `cpuid` on Linux.

Install `cpuid` Tool:
sudo apt-get install cpuid

Run `cpuid` and Check for SGX:
cpuid | grep SGX

Enable SGX in BIOS

Verify SGX is Enabled

- After enabling SGX in the BIOS/UEFI, verify it’s enabled in Linux by checking the `isgx` driver status or looking at system logs.

Check `dmesg` Output:
dmesg | grep -i sgx

2. Install SGX Software

- Update and Upgrade Your System:
sudo apt-get update
sudo apt-get upgrade

Install SGX Dependencies:
sudo apt-get install build-essential ocaml ocamlbuild automake autoconf libtool wget python libssl-dev
sudo apt-get install libssl-dev libcurl4-openssl-dev protobuf-compiler libprotobuf-dev debhelper cmake
sudo apt-get install ocaml ocamlbuild

Download and Install the Intel SGX SDK and PSW:
git clone https://github.com/intel/linux-sgx.git
cd linux-sgx
./download_prebuilt.sh
make
sudo make install

Build and Install the Intel SGX SDK and PSW

Follow the instructions based on the detailed README file for building and installing the Intel SGX SDK and PSW on your system.

Prerequisites:

- Install Required Tools and Libraries for Ubuntu:
sudo apt-get install build-essential ocaml ocamlbuild automake autoconf libtool wget python-is-python3 libssl-dev git cmake perl

Build the Intel SGX SDK:

- Clone the SGX SDK Repository and prepare the build environment:
git clone https://github.com/intel/linux-sgx.git
cd linux-sgx
make preparation
make sdk

Install the Intel SGX SDK:

- Build the SGX SDK installer and run the installer script. Set up the environment by sourcing the SDK:
make sdk_install_pkg
cd linux/installer/bin
./sgx_linux_x64_sdk_*.bin
source <sdk-install-path>/environment

Build the Intel SGX PSW:

- Ensure the SDK is installed and the environment variables are sourced, then build the PSW:
make psw

Install the Intel SGX PSW:

- Use the local repository method for Ubuntu/Debian to install the PSW packages.

Additional Configuration and Testing:

- Follow the ECDSA attestation setup instructions if required and manage the `aesmd` service as described.

- Test the SDK installation using sample code provided to ensure everything is working correctly.

This summary guides you through the necessary steps for setting up Intel SGX on Ubuntu. For specific configurations, additional features, or troubleshooting, refer to the README document in linux-sgx.