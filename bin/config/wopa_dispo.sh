# Settings only for WoPa - Dispo

### Variables
SRC=/Volumes/recycling/_install_macbooks    # src path for manual software
DEST=~/MacInstaller/ToInstall               # destination path for manual software

### Install software without brew
# Trend micro
mkdir -p $DEST/trend_micro/ && cp -R $SRC/trend_micro/ $DEST/trend_micro/
# Filezilla
mkdir -p $DEST/filezilla/ && cp -R $SRC/filezilla/ $DEST/filezilla/
