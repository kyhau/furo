# k-salt

My salt repo.

##### Table of Contents

- [Install salt-master or salt-minion using Salt Bootstrap](#install-salt-master-or-salt-minion-using-salt-bootstrap)
- [Install salt-master and salt-minion on the master machine](#install-salt-master-and-salt-minion-on-the-master-machine)
- [Install salt-minion on a minion](#install-salt-minion-on-a-minion)
- [FAQ / Troubleshooting](#faq---troubleshooting)

### Install salt-master or salt-minion using [Salt Bootstrap](https://docs.saltstack.com/en/latest/topics/tutorials/salt_bootstrap.html)

E.g. Install a specific release version based on the Git tags:
```bash
curl -o bootstrap-salt.sh -L https://bootstrap.saltstack.com
sudo sh bootstrap-salt.sh git v2015.8.8
sed -i -e 's/#master: salt/master: [salt_master_fqdn]/g' /etc/salt/minion
service salt-minion restart
```

Or do it manually as follow.

### Install salt-master and salt-minion on the master machine

   **Ubuntu 16**

   ```bash
   wget -O - https://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
   mkdir -p /etc/apt/sources.list.d/
   cat "deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest xenial main" >> /etc/apt/sources.list.d/saltstack.list
   apt-get update
   apt-get install salt-master salt-minion salt-ssh salt-cloud salt-doc
   ```

See [how-to-install-and-configure-salt-master-and-minion-servers-on-ubuntu-14-04](https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-salt-master-and-minion-servers-on-ubuntu-14-04)
  for detailed steps.

#### salt-master ports

- 4505 : `publish_port` - The network port to set up the publication interface.
- 4506 : `ret_port` - The port used by the return server, this is the server used
 by Salt to receive execution returns and command executions.
 Add these port to the Security Group of a salt-master instance. 

### Install salt-minion on a minion

1. Install the latest installation from the [SaltStack repository](https://repo.saltstack.com/#ubuntu).

   *Notes: The master should always be [updated first](https://docs.saltstack.com/en/latest/topics/installation/index.html#upgrading-salt)!
   See also [SaltStack Installation](https://docs.saltstack.com/en/latest/topics/installation/ubuntu.html)*

   **Ubuntu 16**

   ```bash
   sudo wget -O - https://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
   sudo mkdir -p /etc/apt/sources.list.d/
   echo "deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest xenial main" >> /etc/apt/sources.list.d/saltstack.list
   sudo apt update
   sudo apt install salt-minion
   cat /etc/salt/minion_id             # to confirm minion id is the same as hostname
   ```

   **Ubuntu 14**
    
   ```bash
   sudo wget -O - https://repo.saltstack.com/apt/ubuntu/14.04/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
   echo "deb http://repo.saltstack.com/apt/ubuntu/14.04/amd64/latest trusty main" >> /etc/apt/sources.list
   sudo apt-get update
   sudo apt-get install salt-minion
   cat /etc/salt/minion_id             # to confirm minion id is the same as hostname
   ```

1. Configure salt-minion for connectivity to master.

   ```bash
   sudo vi /etc/salt/minion            # configure for master
  
   master: master.example.com

   # Setup master fingerprint
   master_finger: '' # (use salt-master's public key)

   sudo service salt-minion restart
   ```

1. Salt-master to accept a new minion key.

   ```bash
   # At salt-master
   sudo salt-key -L

   sudo salt-key -L                         # check to see if key is available
   sudo salt-key -a <minion-key>            # Accept the new minion key

   # Check that the server is up
   sudo salt-run manage.status
   ```
   
## FAQ / Troubleshooting

- From version 2016.11.0, the tar_options and zip_options arguments have been deprecated in favor of a single options argument.

    Example: After updating to salt-minion 2016.11.2 (Carbon) , when salting Riise
    
    ```bash
    Warnings: The 'tar_options' argument has been deprecated, please use 'options' instead.
    ```
    
    See [ReleaseNotes-2016.11.0](https://docs.saltstack.com/en/latest/topics/releases/2016.11.0.html)
    
- Error: With 'hash_type: sha256' the specified fingerprint in the master configuration file does not match the authenticating master's key #35617

    ```bash
    With hash_type: sha256 the specified fingerprint in the master configuration
      file does not match the authenticating master's key. Error message:
    2016-08-19 21:05:24,334 [salt.crypt ][CRITICAL][9810] The specified
     fingerprint in the master configuration file: xxxxxxxxxxxxxxxxxxxxxxxxxx 
     Does not match the authenticating master's key: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    ```
    
    Solution: To get around this I have to use hash_type: md5 or delete master_finger from minion config and minions are working fine after restart.


- Failed to salt a server with rabbitmq - the state ".absent" does not work causing KeyError

    ```bash
    "the state "*.absent" does not work causing KeyError when running `rabbitmq_user.absent`."
    ```
    
    This is a known bug in salt-minion-2015.5.3 (26316) - the state "*.absent" does not work causing KeyError when running `rabbitmq_user.absent`.
    
    Solution: Workaround: run `sudo apt-get install rabbitmq-server` manually on the minion server before running `salt` from Jacobi.

- Failed to update server with rabbitmq - signature verification error 

    ```bash
    W: An error occurred during the signature verification. The repository is not updated and the previous index files will be used. 
    GPG error: http://www.rabbitmq.com testing InRelease: The following signatures couldn't be verified because the public key is not available: NO_PUBKEY 6B73A36E6026DFCA
    ```
    
    Solution: http://www.rabbitmq.com/news.html
    
    ```
    gpg --recv-key 0x6B73A36E6026DFCA
     
    # http://www.rabbitmq.com/install-debian.html
    wget -O- https://www.rabbitmq.com/rabbitmq-release-signing-key.asc |
            sudo apt-key add -
    ```

- Error: Data passed to highstate outputter is not a valid highstate return

    ```bash
    {'server-name': ["Rendering SLS 'base:example-https-certs' failed: Jinja variable 'str object' has no attribute 'some_tag'"]}
    server-name:
    - Rendering SLS 'base:example-https-certs' failed: Jinja variable 'str object' has no attribute 'some_tag'
    ERROR: Minions returned with non-zero exit code
    ```

    Solution: Check /etc/hosts, make sure actual server name in the first line, localhost in the second (not the other way around)

- Issue: When you get conflicting IDs

    Solution: Check the key was not added previously and now was moved into some pillar subkey or environment (see conflicting-ids-in-pillar-after-upgrade). eg: When an ID may be accidentally moved into a for loop that is within a pillar option.

- Error: "The function "state.highstate" is running as PID xxxx and was started at xxxx with jid xxxx" and you find that the job is stuck, you want to stop it

    Solution:
    1. Log in to minion
    1. Stop the salt-minion
    1. rm /var/cache/salt/minion/proc/xxx
    1. Start the salt-minion again

- WARNING Key 'file_ignore_glob' with value None has an invalid type of NoneType, a list is required for this value

    Solution: you need to upgrade to 2015.8.10 or later release; see github.com/saltstack/salt/issues/33706

- Error: "SaltStack: [ERROR] The master key has changed and [CRITICAL] The Salt Master has rejected this minion's public key!" after upgrading salt-master

    Solution: you need to delete all salt-minion keys and re-add them; see saltstack-error-master-key-has-changed.
    
    ```
    cd /etc/salt/pki/minion/
    mv minion_master.pub minion_master.pub.old
    mv minion.pem minion.pem.old
    mv minion.pub minion.pub.old
    salt-key --delete-all
    service salt-master restart 
    salt-key --accept-all
```

- Failed to update salt version - 404 Not Found IP: xxx

    ```bash
    Err http://repo.saltstack.com trusty/main amd64 Packages
     404 Not Found [IP: 198.199.77.106 80]
    Fetched 3,732 kB in 6s (551 kB/s)
    W: Failed to fetch http://repo.saltstack.com/apt/ubuntu/ubuntu14/latest/dists/trusty/main/binary-amd64/Packages 404 Not Found [IP: 198.199.77.106 80]
    E: Some index files failed to download. They have been ignored, or old ones used instead.
    ```
    
    Solution: Update salt-minion
    
    ```bash
    sudo wget -O - https://repo.saltstack.com/apt/ubuntu/14.04/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
      
    sudo vi /etc/apt/sources.list
    # Add the following line to /etc/apt/sources.list
    deb http://repo.saltstack.com/apt/ubuntu/14.04/amd64/latest trusty main
      
    sudo apt-get update
    sudo apt-get install salt-minion
    cat /etc/salt/minion_id
    ```
