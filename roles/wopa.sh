# Role: WoPa
# shellcheck disable=SC2034  # variables are used by install.sh

ROLE_NAME="WoPa"
BREWFILES=(Brewfile Brewfile.wopa)
SHARE_ITEMS=(
    filezilla
    fontexplorer
    photoshop_farbraeume        # Photoshop color profiles
    indesign_pdf_joboptions     # InDesign PDF settings
    indesign_scripts
    indesign_preflight
    jjk_produktion_script
    xerox_drucker
    yeastar
)
SETUP_NODE=false
