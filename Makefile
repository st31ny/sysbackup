## Installer Makefile
####################################################################################################
BIN                     := usr/sbin
BIN_INST                := $(DESTDIR)/$(BIN)
ETC                     := etc/sysbackup
ETC_INST                := $(DESTDIR)/$(ETC)

####################################################################################################
all:

install:
	# create config dir and subdirs
	install -d $(BIN_INST) $(ETC_INST) $(ETC_INST)/sources $(ETC_INST)/scripts
	# install programs
	install -m755 -t $(BIN_INST) src/sysbackup src/sysbackup-create-ssh-key src/sysbackup-get-ssh-key
	# install example config files
	install -m644 -t $(ETC_INST) config-example/backup.conf
	install -m644 -t $(ETC_INST)/sources config-example/sources/scripts.list
	install -m755 -t $(ETC_INST)/scripts config-example/scripts/package-list

