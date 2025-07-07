
## 1. Get the VM to run

How to install and run the VM:
I am on an OpenSuse Linux for the following steps

first we need to grant virsh access to the file with `chown`:
```
sudo chown qemu:qemu /home/christian/Downloads/Rocky9SoSe2025-raw/Rocky9SoSe2025
```

we can define the VM with the following command (when in the same folder as the xml)
```
sudo virsh define Rocky9SoSe2025.xml
```

### Install Dependencies

Install required packages:
```bash
sudo zypper install neovim virt-manager virt-viewer libvirt qemu-kvm
```

Start and enable the `libvirtd` service:
```bash
sudo systemctl enable --now libvirtd
```

Add your user to required groups for managing VMs without `sudo`:
```bash
sudo usermod -aG libvirt,kvm $USER
```
we have `$USER`as an environment variable so it knows out username

> Log out and log back in after this step to apply group changes.


#### Move the disk image to the standard libvirt directory:

```bash
sudo mkdir -p /var/lib/libvirt/images/Rocky9SoSe2025
sudo mv ~/Downloads/Rocky9SoSe2025-raw/Rocky9SoSe2025.raw /var/lib/libvirt/images/Rocky9SoSe2025/
```

#### Edit the VM XML to point to the correct image path:

Open the XML file:

```bash
sudo nvim Rocky9SoSe2025.xml
```
Find this line:
```xml
<source file='/path/to/old/image'/>
```
Replace it with:
```xml
<source file='/var/lib/libvirt/images/Rocky9SoSe2025/Rocky9SoSe2025.raw'/>
```
Save and exit (`:wq`).

#### 1. Undefine the old VM if it exists:

```bash
sudo virsh undefine Rocky9SoSe2025
```
### 2. Define the VM from the edited XML:

```bash
sudo virsh define Rocky9SoSe2025.xml
```
### 3. Start the VM:

```bash
sudo virsh start Rocky9SoSe2025
```

You should see:

```
Domain 'Rocky9SoSe2025' started
```

We can open the VM like this:
```bash
virt-viewer --connect qemu:///system Rocky9SoSe2025
```

Or open `virt-manager` and double-click the VM:
```bash
virt-manager
```

##### Virt Manager
![[Pasted image 20250512212800.png]]
We use Virtual Machine Manager to manage our Virtual Machine

---
## 2. Resetting the password

![[Pasted image 20250512213039.png]]
1. In GRUB, we press key down to stop the Linux from booting automatically
2. We then press `e` to edit the boot sequence
### GRUB settings

1. change `ro` to `rw` (read only to read write)
2. add `init=/bin/bash` at the end of line after quiet. This will boot us into the bash instead of the password input
	1. Tipp: the keyboard is set to english, for `=` we need to press `´` and for `/` it is `-`
3. delete rhgb
4. When all is done, press Ctrl-x

It should look like this:
![[Pasted image 20250512214001.png]]

Now we are in bash:
![[Pasted image 20250512214158.png]]
to change Password: 
passwd

![[Pasted image 20250512214500.png]]

The Password was changed successfully
To reboot without corrupting files, we are 
![[Pasted image 20250512214712.png]]

```bash
sync
mount -o remount,ro /
```
#### What it does

**sync**
flushed the file system buffers, ensures all pending writes to disk are completed
**mount -o remount,ro /**
Remounts the `/` (root) directory as read only

Now we can force restart without risking data loss and log in with our newly set password as root

![[Pasted image 20250512215655.png]]

---
## 3. Change Keyboard setting

I need to match it with my host setting
![[Pasted image 20250512220020.png]]
so the correct command to do this is
```bash
sudo localectl set-x11-keymap de pc105 mac
```

Test: the characters like `Z` or `-` are working as expected. I now have to remember to switch `Z` and `Y` when entering my password
![[Pasted image 20250512220603.png]]

---
## 4. Get online

I used the provided configuration file, to test if I am online I will Ping google.com

```bash
ping google.com
```

![[Pasted image 20250512220939.png]]

**Result: We are online**


---
## 5. Update the system

![[Pasted image 20250512221707.png]]

we are checking for available updates with
```bash
sudo dnf check-update
```

To actually install them, we are using

```bash
sudo dnf upgrade
```
This upgrades the system and installed packages

![[Pasted image 20250512222353.png]]
We are  prompted if we want to continue and press `y`

**Complete!**
![[Pasted image 20250512223722.png]]

#### Do we need to reboot?

to find out if the system needs rebooting, we can list all files that are still in use but already deleted on the system

listing files in use is done with `sudo lsof`, which also shows deleted files. these have `(deleted)` in the end of the line
 
we can therefore pipe the output of `sudo lsof`, which lists the open files on the system into the input of `grep`, which filters the output to only show the lines that contain the word we provide it with (in our case we want to see the lines that contain `deleted`)
so the command is
```bash
sudo lsof | grep deleted
```

**We have deleted files**
![[Pasted image 20250512223836.png]]

We can also check the current Kernel version that is running with 
```
uname -a
```
![[Pasted image 20250512224132.png]]
We can see the current version is 5.14.0-503.14.1 and so on

and check all installed Kernel versions with

```bash
ll /boot
```
![[Pasted image 20250512225043.png]]

here we can see the current version 5.14.0-503.14.1 and the newly installed one 5.14.0-503.40.1
**The old 14.1 Kernel is still running but the 40.1 is installed**

So we can conclude on the Kernel test that we need to reboot for that as well. Therefore we will do
```bash
sudo reboot
```
![[Pasted image 20250512225236.png]]

GRUB has the new Kernel now

---
## 6. Enable SSH

we need to make sure the openssh-server is running on startup so we are not locked out when rebooting remotely.

therefore we execute the command
```bash
sudo systemctl enable sshd --now
```
`systemctl enable` is the command to enable services. we want to enable sshd (Open SSH Deamon)
the flag `--now` also makes sure it is started now so we don't need to restart

Now we can confirm if it is set up on startup with

```bash
sudo systemctl status sshd
```
![[Pasted image 20250512230641.png]]
**It is enabled and active (running)**

---
## 7 Open SSH port to host

We need to redirect the SSH port (22) to a different free port on our host system ( we choose 2222) so we can access it from our network.

When the VM is running, we can forward the port 22 to 2222 with this command:

```bash
sudo virsh qemu-monitor-command --hmp Rocky9SoSe2025 'hostfwd_add ::2222-:22'
```

then we log in to the root user by connecting to port 2222 with ssh (since it is running locally localhost works, otherwise it would be the IP of our host machine on port 2222)

```bash
ssh -p 2222 root@localhost
```

**We are in the VM from our host terminal now**
![[Pasted image 20250518122252.png]]

## Generate and get copy the SSH keys to our system

### View the existing keys

First we can view the SSH keys that are on the System by showing all the files in the `.ssh` folder:
```
ls -l ~/.ssh/
```

actually they are in /etc/ssh
```
ls -l /etc/ssh/
```

we see for example a key called `authorized_keys`

we can view it with the program cat
```
cat /etc/ssh/ssh_host_ecdsa_key
```
 or since we are in the folder with ls
 ```
 cat ssh_host_ecdsa_key
```

**here is the existing private key we read**
![[Pasted image 20250518130947.png]]
### Generate new Keys

Since we have a copy of the VM images, the keys can be read by anyone with the same VM image and could access it, so we want to remove the existing keys and create our own one. 

Therefor we delete all files in the .ssh folder

```
rm /etc/ssh/ssh_host_*key*
```
 we have `*`  as a wild card character so we remove all ssh keys that fit this pattern

**no more ssh_host files**
![[Pasted image 20250518131650.png]]

Now we need to re-generate the keys

```
sudo ssh-keygen -A
```

**Keys are here again**
![[Pasted image 20250518131759.png]]
then we restart the SSH daemon
```
sudo systemctl restart sshd
```

### Copy the keys

We want to use `ed25519` since it is the newest of the SSH protocols. So this is the key we copy.
We want the public key, so for simplicity we can just copy the output of the file to our host since we are in with ssh anyway.
```
cat /etc/ssh/ssh_host_ed25519_key.pub
```

### Using SSH key to log in 

on our host system we create the ssh key

```
ssh-keygen -t ed25519
```

copy it to our VM to use it as log in
```
ssh-copy-id -p 2222 root@localhost
```

**now there are no more passwords needed to log in to our VM**
![[Pasted image 20250518140928.png]]
