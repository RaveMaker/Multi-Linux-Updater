bash-linuxupdater
=================

Update multiple Linux OS Distributions from a single server

### Installation

1. Clone this script from github:

        git clone https://github.com/ET-CS/bash-linuxupdater.git

    or copy the files manually to your prefered directory.

2. Create updateall.lst from the included updateall.lst.example,

        cp updateall.lst.example updateall.lst

and fill it with your servers list:

    Hostname Port OS

for example:

    10.0.0.2 22 CentOS


#### Supported OS parameter options
* Debian
* REHL
* Cent0S
* Ubuntu