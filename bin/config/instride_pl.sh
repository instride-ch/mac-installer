# Settings only for instride - PL

### Variables
SRC=/Volumes/recycling/_install_macbooks    # src path for manual software
DEST=~/MacInstaller/ToInstall               # destination path for manual software

### Install software without brew

# Filezilla
mkdir -p $DEST/filezilla/ && cp -R $SRC/filezilla/ $DEST/filezilla/
