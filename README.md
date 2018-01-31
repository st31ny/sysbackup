Simple System Backup Tool
=========================

Reads sources from various configuration files and rsyncs them to a configurable
target.

Programs
--------

`sysbackup`

Main program. Performs the backup according to the configuration (see below).

`sysbackup-create-ssh-keys`

Creates a SSH key for the sysbackup user. With reasonable defaults. Any options
are forwarded to `ssh-keygen`.

`sysbackup-get-ssh-key`

Displays contents of `/var/lib/sysbackup/.ssh/id_ed25519.pub`.

Dependencies
------------

* rsync
* ssh-client for `sysbackup-create-ssh-keys`, `sysbackup-get-ssh-key` and to
  transfer data to SSH targets
* standard stuff: getopt, find, mkdir, mktemp

Configuration Files
-------------------

`/etc/sysbackup/backup.conf`

Main configuration file. Specifies backup target (`$TARGET`) and other options.
Unless the variable `$BACKUP` is set to true, calling `sysbackup` does nothing.

$TARGET might be any string accepted by rsync as destination, i.e., it could
contain a remote SSH host, as in:

    TARGET="user@example.org:backup/"

Additional options for `rsync` can be specified in $RSYNC\_OPTIONS.

All source directories are searched for hidden marker files with the file name
".sysbackup-exclude". All directories containing such a marker file, are excluded
from the backup. The marker file name can be configured via $EXCLUDEMARKER and
accepts patterns as `find -name`. Setting $EXCLUDEMARKER to an empty value
disables this feature.

See the provided and commented example configuration file for more information.

`/etc/sysbackup/sources/`

Directory with source files. Each file in this directory that ends in `.list`
is interpreted as containing absolute source directories to be backed up.
Empty lines and lines starting with a `#` are ignored.

Normally, each backup source is assigned a target name by replacing all / with \_.
If you want to assign another name, start the source line with `Name=`. All names
must be globally unique.

The contents of the specified directory are transferred recursively. If you want to
exclude certain directory (i.e., with large downloaded files), create an empty file
`.sysbackup-exclude` in it.

`/etc/sysbackup/scripts/`

Directory with user-defined scripts. Prior to file transfer, each executable file
$file in this directoy is run in the directory `/var/lib/sysbackup/scripts/$file/`
with stdout redirected to a file `stdout` in that directory. So, scripts in this
directory can simply create files and/or write to stdout. The directory
`/var/lib/sysbackup/scripts` is included by default in `/etc/sysbackup/sources`.
If the scripts working directories do not exist, they are created before calling
the scripts. They are not purged after running.

`/var/lib/sysbackup/.ssh/id_25519.pub`

Call `sysbackup-create-ssh-key` (as root) to create an SSH-Key for the sysbackup
user. Call `sysbackup-get-ssh-key` to show the public key.

Environment Variables
---------------------

`SYSBACKUP_ROOT`

All configuration files are resolved relative to `SYSBACKUP_ROOT`. Lines in the
source files are unchanged.

Hooks
-----

ToDo

Data Transfer
-------------

Upon invocation, `sysbackup` reads the configuration and source files. Then,
it executes all scripts, as described above.

Then, the contents of each source directory $src  are transferred using rsync
to $TARGET/$src, where $TARGET is the configured target directory and $src is the
name of the particular source directory.

By default, folling options are passed to rsync:

    --archive --delete --delete-excluded --one-file-system
    --compress --hard-links --inplace
    --numeric-ids

You can override these default options by re-defining $RSYNC\_OPTIONS\_DEFAULT in
the config file.
If files matching the exclude marker (defaults to ".sysbackup-exlude") are found,
the option "--exclude-from=" with an appropriate file is appended automatically.
If verbose output is enabled, the options "--verbose --progress --human-readable"
are appended. Finally, user-defined options in $RSYNC\_OPTIONS are appended.

Normally, you should only need to set $RSYNC\_OPTIONS in the configuration file,
if at all.


Systemd Intergration
--------------------

The package ships with a systemd daemon and timer that runs the system backup
daily at 5:43 in the morning. Override `sysbackup.timer` as you like.

The script is run as user `sysbackup` and so will the user defined scripts. In
order to backup anything, this user must be able to call the requested commands
and read the files to be backed up.

