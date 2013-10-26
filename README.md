# Server Scripts

This is a loose collection of scripts I use to simplify environment management.
If I haven't instructed you to use one of these files, then the likelihood of
any of them being useful is pretty slim.

## Using Scripts

These scripts can be run using the following syntax:

`curl https://raw.github.com/coreybutler/servers/master/<script> | sh`

**Make sure you replace &lt;script&gt; with the appropriate script name!**

If this doesn't work, you may need higher level privileges. Assuming you're
authorized, you can use the following instead:

`sudo curl https://raw.github.com/coreybutler/servers/master/<script> | sudo sh`

# Special Scripts

Most of the scripts are self-explanatory, but a few may require special explanation.

### centos

Runs updates to configure the CentOS server. This is essentially the _setup_ script.

### git-key

Installs a special wizard to add SSH keys for git projects. This
will generate an SSH key and optionally add it to a Github or BitBucket
machine account.

Once this script is installed, it **does not** need to be run via `curl`.


 