# Role: WoPa – Vorstufe
# shellcheck disable=SC2034  # variables are used by install.sh

ROLE_NAME="WoPa – Vorstufe"
BREWFILES=(Brewfile Brewfile.wopa_vorstufe)
SHARE_ITEMS=(
    filezilla
    fontexplorer
    photoshop_farbraeume        # Photoshop color profiles
    indesign_pdf_joboptions     # InDesign PDF settings
    indesign_scripts
    indesign_preflight
    enfocus_21                  # Enfocus PitStop
    callas_21
    JJKProduktion3
    jjk_produktion_script
    jjk_mono_framework
    ruler
)
DEFAULTS=()
SETUP_NODE=false
