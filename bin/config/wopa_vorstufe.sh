# Settings only for WoPa - Vorstufe

### Variables
SRC=/Volumes/recycling/_install_macbooks    # src path for manual software
DEST=~/MacInstaller/ToInstall               # destination path for manual software

### Install software without brew
# Trend micro
mkdir -p $DEST/trend_micro/ && cp -R $SRC/trend_micro/ $DEST/trend_micro/
# Filezilla
mkdir -p $DEST/filezilla/ && cp -R $SRC/filezilla/ $DEST/filezilla/
# Photoshop profiles
mkdir -p $DEST/photoshop_farbraeume/ && cp -R $SRC/photoshop_farbraeume/ $DEST/photoshop_farbraeume/
# Indesign pdf settings
mkdir -p $DEST/indesign_pdf_joboptions/ && cp -R $SRC/indesign_pdf_joboptions/ $DEST/indesign_pdf_joboptions/
# Indesign scripts
mkdir -p $DEST/indesign_scripts/ && cp -R $SRC/indesign_scripts/ $DEST/indesign_scripts/
# Enfocus Pitstop
mkdir -p $DEST/enfocus_21/ && cp -R $SRC/enfocus_21/ $DEST/enfocus_21/
# Callas
mkdir -p $DEST/callas_21/ && cp -R $SRC/callas_21/ $DEST/callas_21/
# FontExplorer
mkdir -p $DEST/fontexplorer/ && cp -R $SRC/fontexplorer/ $DEST/fontexplorer/
# JJK
mkdir -p $DEST/JJKProduktion3/ && cp -R $SRC/JJKProduktion3/ $DEST/JJKProduktion3/
mkdir -p $DEST/jjk_produktion_script/ && cp -R $SRC/jjk_produktion_script/ $DEST/jjk_produktion_script/
# Ruler
mkdir -p $DEST/ruler/ && cp -R $SRC/ruler/ $DEST/ruler/
