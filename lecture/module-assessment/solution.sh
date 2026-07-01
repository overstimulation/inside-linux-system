#!/usr/bin/env bash

# Przerwanie działania w przypadku błędu komendy, użycia niezdefiniowanej zmiennej lub błędu w potoku.
set -euo pipefail

# Wymuszenie uprawnień administratora, niezbędnych do modyfikacji systemu i instalacji pakietów.
if [ "$(id -u)" -ne 0 ]; then
    echo "[ERROR] This script must be run as root." >&2
    exit 1
fi

echo ""
echo "========================================================="
echo "[INFO] Initialising Slax assessment script."
echo "========================================================="
echo ""
# ---------------------------------------------------------
# Zad.1 - Aktualizacja
# ---------------------------------------------------------

PATCHES_URL="https://mirrors.slackware.com/slackware/slackware64-15.0/patches"
CHECKSUMS_FILE="/tmp/CHECKSUMS.md5"

# "Pakiety zachować na dysku w katalogu /root/patches."
PATCHES_DIR="/root/patches"

mkdir -p "${PATCHES_DIR}"

# Wykorzystujemy plik z listą sum kontrolnych, by odszukać tam pełne, dokładne ścieżki i nazwy uaktualnień.
wget -q --no-check-certificate "${PATCHES_URL}/CHECKSUMS.md5" -O "${CHECKSUMS_FILE}" || { echo "[ERROR] Failed to download CHECKSUMS.md5." >&2; exit 1; }
echo "[INFO] Successfully downloaded CHECKSUMS.md5."

# "Korzystając z informacji z katalogu /var/log/packages należy pobrać patche tych pakietów, które są założone w systemie."
for pkg_path in /var/log/packages/*; do
    pkg_name_full=$(basename "${pkg_path}")
# Bezpieczne wydobycie nazwy bazowej. Standard w Slackware to: nazwa-wersja-arch-build. Odwracamy string, odcinamy 3 ostatnie człony i przywracamy do pierwotnego kształtu.
    pkg_base=$(echo "${pkg_name_full}" | rev | cut -d'-' -f4- | rev)
    
    # "Nie aktualizować jądra!"
    if [[ "${pkg_base}" == kernel* ]]; then
        continue
    fi
    
# Wyszukujemy pełną ścieżkę łatki w pliku sum kontrolnych używając wyrażenia regularnego dopasowanego do nazwy bazowej. Zwracamy najświeższy wynik (tail -n1).
    patch_file=$(grep -E " \./packages/${pkg_base}-[^-]+-[^-]+-[^-]+\.txz$" "${CHECKSUMS_FILE}" | awk '{print $2}' | tr -d '\r' | tail -n1 || true)
    
    if [ -n "${patch_file}" ]; then
        patch_file="${patch_file#./}"
        patch_basename=$(basename "${patch_file}")
# W celu optymalizacji pobieramy łatkę tylko wtedy, kiedy nasza lokalnie zainstalowana wersja pakietu fizycznie różni się od wersji z serwera.
        if [ "${patch_basename%.txz}" != "${pkg_name_full}" ]; then
            echo "[INFO] Found update for ${pkg_base}: ${patch_basename}"
            wget -q -c --no-check-certificate "${PATCHES_URL}/${patch_file}" -O "${PATCHES_DIR}/${patch_basename}" || { echo "[ERROR] Failed to download ${patch_basename}" >&2; exit 1; }
        fi
    fi
done

# "Zaktualizować za ich pomocą system."
if [ "$(ls -A "${PATCHES_DIR}/" 2>/dev/null)" ]; then
    echo "[INFO] Updating patched packages."
    upgradepkg "${PATCHES_DIR}"/*.txz || { echo "[ERROR] Failed to update patched packages." >&2; exit 1; }
    echo "[INFO] Successfully updated patched packages."
else
    echo "[INFO] No updates were necessary."
fi

# ---------------------------------------------------------
# Zad.2 - Zegarek
# ---------------------------------------------------------

# "Proszę zmienić strefę czasową zegara systemowego na "Europe/Warsaw"."
# W dystrybucjach bez systemd (jak Slackware/Slax), modyfikacja dowiązania symbolicznego to standardowa metoda zmiany strefy czasowej.
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Europe/Warsaw /etc/localtime
echo "[INFO] Successfully set timezone to Europe/Warsaw."

# ---------------------------------------------------------
# Zad.3 - Podmiana przeglądarki
# ---------------------------------------------------------

# "(a) Proszę usunąć konto guest."
if id -u guest >/dev/null 2>&1; then
    userdel -r guest || { echo "[ERROR] Failed to remove guest account." >&2; exit 1; }
    echo "[INFO] Successfully removed guest account."
fi

# "(b) Proszę dodać swoje konto, bez nadawania mu uprawnień administracyjnych."
# Zakładam, że polecenie wymaga jedynie utworzenia konta (useradd). Pomijam ręczne kopiowanie plików konfiguracyjnych pulpitu, ponieważ w środowisku Slaxa środowisko graficzne jest sprzęgnięte z katalogiem /root (a nie ze standardowym /etc/skel), co czyniłoby operację przenoszenia profilu wykroczeniem poza treść zadania.
if ! id -u kacper >/dev/null 2>&1; then
    useradd -m kacper || { echo "[ERROR] Failed to add user kacper." >&2; exit 1; }
    echo "[INFO] Successfully added user kacper."
fi

# "(c) Proszę usunąć wpis "Chrome" z menu znajdującego się pod prawym przyciskiem myszy."
# Menu pod prawym przyciskiem to natywne menu menedżera okien Fluxbox. Wpis ukrywa się pod nazwą "Web Browser" i wywołuje google-chrome.
# W oparciu o treść polecenia, zakładam usunięcie przeglądarki tylko z menu (wraz z przyciskiem Web Browser), bez deinstalacji pakietu.
sed -i -e '/[Cc]hromium/d' -e '/google-chrome/d' /root/.fluxbox/menu

# "(d) Proszę usunąć wpis "Chrome" z menu pojawiającego się po naciśnięciu zielonego przycisku na pasku zadań."
# Zielony przycisk wywołuje aplikację xlunch, która buduje listę skrótów z plików .dsv oraz klasycznych .desktop.
sed -i '/[Cc]hromium/d' /etc/xlunch/entries.dsv

if [ -f /usr/share/applications/google-chrome.desktop ]; then
    rm -f /usr/share/applications/google-chrome.desktop
fi
echo "[INFO] Successfully removed Chrome entries from menus."

# "(e) Dodać pakiet z przeglądarką Firefox. Najnowszą wersję mozna znaleźć tam, gdzie patche systemowe (patrz zad.1)."
FF_PATCH=$(grep -E " \./packages/mozilla-firefox-[^-]+-[^-]+-[^-]+\.txz$" "${CHECKSUMS_FILE}" | awk '{print $2}' | tr -d '\r' | tail -n1 || true)
if [ -n "${FF_PATCH}" ]; then
    FF_PATCH="${FF_PATCH#./}"
    FF_BASENAME=$(basename "${FF_PATCH}")
    echo "[INFO] Downloading Firefox from: ${PATCHES_URL}/${FF_PATCH}"
    wget -c --no-check-certificate "${PATCHES_URL}/${FF_PATCH}" -O "${PATCHES_DIR}/${FF_BASENAME}" || { echo "[ERROR] Failed to download Firefox patch." >&2; exit 1; }
    # Używamy flagi --install-new, ponieważ standardowe upgradepkg ignoruje pakiety, których nie ma jeszcze w systemie.
    echo "[INFO] Installing Firefox."
    upgradepkg --install-new "${PATCHES_DIR}/${FF_BASENAME}" || { echo "[ERROR] Failed to install Firefox." >&2; exit 1; }
    echo "[INFO] Successfully installed Firefox."
else
    echo "[ERROR] Could not find Firefox in patches." >&2
    exit 1
fi

# "W tym momencie należy zapamiętać stan systemu poprzez mechanizm "persistent changes"."
# Moduły Slaxa (*.sb) ładują się na warstwie OverlayFS w porządku leksykograficznym. Prefiks '80-' gwarantuje, że ten moduł wczyta się niżej niż moduł XNedit ('90-') z Zadania 4, co zapobiegnie maskowaniu plików.
echo "[INFO] Saving persistent system changes."
savechanges /run/initramfs/memory/data/slax/modules/80-system-changes.sb || { echo "[ERROR] Failed to save persistent changes." >&2; exit 1; }
echo "[INFO] Successfully saved persistent system changes (Task 1-3)."

# ---------------------------------------------------------
# Zad.4 - Kompilacja własnego pakietu
# ---------------------------------------------------------

# "Należy skompilować edytor tekstu XNedit i spakować go do postaci pakietu Slaksa."
# Na czystym systemie Slax konieczne jest odświeżenie kluczy GPG bazy pakietów, w przeciwnym razie środowisko odrzuci próbę instalacji.
# Używamy flag -batch=on oraz -default_answer=y, aby wymusić tryb nieinteraktywny we wszystkich wywołaniach. W przeciwnym razie slackpkg zawiesiłby skrypt, oczekując od użytkownika decyzji (K/O/R/P) w sprawie plików konfiguracyjnych .new.
echo "[INFO] Synchronising slackpkg repositories."
slackpkg -batch=on -default_answer=y update gpg || true
slackpkg -batch=on -default_answer=y update || true

# "(a) Pobierz źródła xnedit-1.6.3.tar.gz, rozpakuj je."
XNEDIT_SRC_DIR="/tmp/xnedit-src"
XNEDIT_PKG_DIR="/tmp/xnedit-pkg"
XNEDIT_TAR="/tmp/xnedit.tar.gz"

wget -q --no-check-certificate -O "${XNEDIT_TAR}" "https://downloads.sourceforge.net/project/xnedit/xnedit-1.6.3.tar.gz" || { echo "[ERROR] Failed to download XNedit sources." >&2; exit 1; }
mkdir -p "${XNEDIT_SRC_DIR}"
tar -xzf "${XNEDIT_TAR}" -C "${XNEDIT_SRC_DIR}" --strip-components=1 || { echo "[ERROR] Failed to extract XNedit sources." >&2; exit 1; }
echo "[INFO] Successfully downloaded and extracted XNedit sources."

# "(b) Aby skompilować edytor, będzie trzeba dodać do dystrybucji pakiety Slackware dwóch typów:"
# "- brakujące narzędzia deweloperskie"
DEV_PKGS="gcc make binutils pkg-config guile gc flex"
# " - biblioteki i pliki nagłówkowe jądra"
LIB_PKGS="motif libX11 libXt libXext libSM libICE libXmu libXpm libXaw libXau libXdmcp libxcb libXft libXrender fontconfig freetype harfbuzz glib2 libpng libxml2 xorgproto glibc kernel-headers"

# "Wszystkie je można znaleźć w repozytoriach Slackware'a"
echo "[INFO] Installing development tools and libraries."
slackpkg -batch=on -default_answer=y install ${DEV_PKGS} ${LIB_PKGS} || true
# Slax posiada zainstalowane odchudzone (stripped) wersje bibliotek X11/Motif. Używamy 'reinstall', by wymusić z repozytoriów dociągnięcie pełnych wersji zawierających pliki nagłówkowe (.h) niezbędne do kompilacji.
echo "[INFO] Reinstalling base libraries to restore stripped header files."
slackpkg -batch=on -default_answer=y reinstall ${LIB_PKGS} || true
echo "[INFO] Successfully installed development tools and libraries."

# "Skompiluj edytor."
echo "[INFO] Compiling XNedit."
cd "${XNEDIT_SRC_DIR}"
make linux || { echo "[ERROR] Failed to compile XNedit." >&2; exit 1; }
echo "[INFO] Successfully compiled XNedit."

# "(c) Wgranie tego pakietu powinno spowodować, że xnedit pojawi się w katalogu /usr/local/bin"
echo "[INFO] Packaging XNedit into a Slax module."
mkdir -p "${XNEDIT_PKG_DIR}/usr/local/bin"
cp source/xnedit "${XNEDIT_PKG_DIR}/usr/local/bin/" || { echo "[ERROR] Failed to copy XNedit binary." >&2; exit 1; }

# "Stwórz pakiet 90-xnedit.sb, umieść go w odpowiednim miejscu na pendrivie."
# Wchodzimy do katalogu źródłowego i przekazujemy komendzie dir2sb bezpośrednio katalog 'usr'. Gwarantuje to, że OverlayFS zamontuje edytor prosto w /usr/local/bin, bez powielania drzewa katalogów nadrzędnych.
cd "${XNEDIT_PKG_DIR}"
dir2sb usr /run/initramfs/memory/data/slax/modules/90-xnedit.sb || { echo "[ERROR] Failed to create 90-xnedit.sb module." >&2; exit 1; }
echo "[INFO] Successfully created 90-xnedit.sb module."

# "(d) Sprzątanie: usuń pakiety deweloperskie które trzeba było dograć. Nie usuwaj bibliotek ani plików nagłówkowych jądra."
echo "[INFO] Cleaning up development tools."
slackpkg -batch=on -default_answer=y remove ${DEV_PKGS} || { echo "[ERROR] Failed to remove development tools." >&2; exit 1; }
# "Usuń katalog ze źródłami xnedit."
rm -rf "${XNEDIT_SRC_DIR}" "${XNEDIT_TAR}" "${XNEDIT_PKG_DIR}"
echo "[INFO] Successfully removed development tools and sources (libraries kept)."

# Wymuszenie zrzutu buforów zapisu z RAM na nośnik USB. Zapobiega to uszkodzeniu wygenerowanych modułów w przypadku natychmiastowego restartu po zakończeniu skryptu.
echo "[INFO] Synchronising disks."
sync
echo "[INFO] Successfully synchronised disks."

echo ""
echo "========================================================="
echo "[INFO] Successfully completed assessment script."
echo "========================================================="
echo ""