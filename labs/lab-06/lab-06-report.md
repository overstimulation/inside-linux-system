# Budowa pakietu deb ze źródeł
## System Linux od podszewki
### Kacper Bednarczuk

---

## 1. Wprowadzenie i charakterystyka oprogramowania

Przedmiotem prac opisanych w niniejszym raporcie było skompilowanie i zbudowanie pakietu instalacyjnego deb dla oprogramowania Open On-Chip Debugger (OpenOCD).

Budowę pakietu przeprowadzono w kontenerze środowiskowym opartym na dystrybucji Debian Trixie. W celu wygenerowania instalatora wykorzystano wbudowane mechanizmy pobierania gotowych struktur konfiguracyjnych paczek, co pozwoliło pominąć ręczną budowę struktury katalogów i plików konfiguracyjnych narzędziem dh_make, znacznie automatyzując pracę.

---

## 2. Przygotowanie zależności i środowiska

Proces rozpoczęto od pobrania obrazu i uruchomienia kontenera środowiskowego. Następnie włączono repozytoria kodów źródłowych w systemie, aby przygotować środowisko do pobrania pakietów wymaganych podczas kompilacji.

```bash
docker pull debian:trixie
docker run -it --name openocd-deb debian:trixie bash
```
<figure>
  <img src="screenshots/01-environment/env-01-docker-run.png">
  <figcaption align="center"><i>Uruchomienie kontenera środowiskowego</i></figcaption>
</figure>

```bash
sed -i 's/Types: deb/Types: deb deb-src/g' /etc/apt/sources.list.d/debian.sources
cat /etc/apt/sources.list.d/debian.sources
```

<div style="page-break-after: always;"></div>

<figure>
  <img src="screenshots/01-environment/env-02-edit-sources.png">
  <figcaption align="center"><i>Dodanie obsługi repozytoriów źródłowych</i></figcaption>
</figure>

```bash
apt update && apt upgrade -y
```
<figure>
  <img src="screenshots/01-environment/env-03-apt-update.png">
  <figcaption align="center"><i>Aktualizacja indeksów pakietów</i></figcaption>
</figure>

```bash
apt install -y dpkg-dev devscripts fakeroot build-essential
```
<figure>
  <img src="screenshots/01-environment/env-04-apt-install-tools-start.png">
  <figcaption align="center"><i>Rozpoczęcie pobierania podstawowych narzędzi kompilacji</i></figcaption>
</figure>

<figure>
  <img src="screenshots/01-environment/env-05-apt-install-tools-done.png">
  <figcaption align="center"><i>Instalacja pakietów deweloperskich w środowisku</i></figcaption>
</figure>

---

## 3. Kompilacja i budowa pakietu deb

W pierwszej kolejności zainstalowano wszystkie biblioteki oraz pakiety deweloperskie niezbędne do przeprowadzenia poprawnej kompilacji oprogramowania. Zamiast manualnie identyfikować każdą zależność, wykorzystano dedykowane narzędzie pobierające kompletne listy wymogów powiązanych bezpośrednio z plikami źródłowymi wybranego programu. Następnie pobrano właściwy kod źródłowy wraz ze skonfigurowanymi strukturami debianowymi.

```bash
mkdir -p /usr/src/openocd-pkg
cd /usr/src/openocd-pkg
apt build-dep -y openocd
```
<figure>
  <img src="screenshots/02-packaging/pkg-01-apt-build-dep-start.png">
  <figcaption align="center"><i>Instalacja zależności kompilacyjnych</i></figcaption>
</figure>

<figure>
  <img src="screenshots/02-packaging/pkg-02-apt-build-dep-done.png">
  <figcaption align="center"><i>Zakończenie pobierania zależności kompilacyjnych</i></figcaption>
</figure>

```bash
apt source openocd
```
<figure>
  <img src="screenshots/02-packaging/pkg-03-apt-source.png">
  <figcaption align="center"><i>Pobranie i rozpakowanie kodów źródłowych aplikacji</i></figcaption>
</figure>

```bash
cd openocd-*/
debuild -b -uc -us
```
<figure>
  <img src="screenshots/02-packaging/pkg-04-debuild-start.png">
  <figcaption align="center"><i>Rozpoczęcie kompilacji kodu źródłowego</i></figcaption>
</figure>

<figure>
  <img src="screenshots/02-packaging/pkg-05-debuild-done.png">
  <figcaption align="center"><i>Wygenerowanie pakietu deb</i></figcaption>
</figure>

```bash
cd ..
ls *.deb
```
<figure>
  <img src="screenshots/02-packaging/pkg-06-ls-deb.png">
  <figcaption align="center"><i>Potwierdzenie wygenerowania pakietów instalacyjnych</i></figcaption>
</figure>

---

## 4. Weryfikacja działania i archiwizacja

Po zbudowaniu pakietu przetestowano jego działanie, instalując go bezpośrednio w kontenerze. Zweryfikowano również poprawność samej kompilacji, sprawdzając wyświetlaną wersję programu oraz wygenerowaną listę dostępnych adapterów sprzętowych.

```bash
apt install -y ./*.deb
```
<figure>
  <img src="screenshots/03-verification/ver-01-apt-install-deb.png">
  <figcaption align="center"><i>Instalacja oprogramowania z pakietu deb</i></figcaption>
</figure>

```bash
openocd --version
```
<figure>
  <img src="screenshots/03-verification/ver-02-version.png">
  <figcaption align="center"><i>Weryfikacja widoczności programu w systemie</i></figcaption>
</figure>

```bash
openocd -c "adapter list"
```
<figure>
  <img src="screenshots/03-verification/ver-03-adapter-list.png">
  <figcaption align="center"><i>Prezentacja wbudowanych sprzętowych modułów komunikacji</i></figcaption>
</figure>

Ostatnim etapem prac było spakowanie kodu źródłowego programu do archiwum tar.

```bash
tar -czvf openocd-deb-source.tar.gz openocd-*/
```
<figure>
  <img src="screenshots/04-archiving/arc-01-tar-start.png">
  <figcaption align="center"><i>Rozpoczęcie kompresji kodu źródłowego</i></figcaption>
</figure>

<figure>
  <img src="screenshots/04-archiving/arc-02-tar-done.png">
  <figcaption align="center"><i>Utworzenie skompresowanego pliku .tar.gz</i></figcaption>
</figure>

Gotowe pakiety instalacyjne oraz skompresowane źródła przekopiowano następnie z kontenera bezpośrednio do folderu na fizycznej stacji roboczej, używając poleceń dostarczonych w środowisku Docker.

```bash
docker cp openocd-deb:/usr/src/openocd-pkg/openocd_0.12.0-3_amd64.deb ~/Documents/
```
<figure>
  <img src="screenshots/04-archiving/arc-03-docker-cp-deb.png">
  <figcaption align="center"><i>Pobranie pakietu deb na system nadrzędny</i></figcaption>
</figure>

```bash
docker cp openocd-deb:/usr/src/openocd-pkg/openocd-deb-source.tar.gz ~/Documents/
```
<figure>
  <img src="screenshots/04-archiving/arc-04-docker-cp-tar.png">
  <figcaption align="center"><i>Pobranie archiwum wynikowego na system nadrzędny</i></figcaption>
</figure>

---

## 5. Wnioski

Budowanie oprogramowania ze źródeł do ustandaryzowanego formatu deb to procedura lepsza i bezpieczniejsza niż ręczna kompilacja na maszynie docelowej. Taka konwencja pozwala docelowemu oprogramowaniu na korzystanie z bibliotek zawartych już w systemie operacyjnym, zamiast nakazywać procesowi kompilacji budowę ich lokalnych kopii zintegrowanych z kodem źródłowym aplikacji. Ogranicza to znacząco przestrzeń zajmowaną przez finalny plik instalacyjny i umożliwia natywną aktualizację współdzielonych modułów.

Największym atutem metody z włączonymi repozytoriami źródłowymi jest oparcie całego procesu na zintegrowanych mechanizmach dystrybucji, które skutecznie zdejmują z dewelopera obowiązek pilnowania zależności oraz manualnego tworzenia struktury konfiguracyjnej budowanego pakietu.

Gotowy pakiet deb zauważalnie ułatwia proces wdrażania narzędzia. Używany menedżer pakietów samodzielnie przeprowadza weryfikację wszystkich wymagań środowiskowych przed rozpoczęciem instalacji w systemie, minimalizując tym samym ryzyko napotkania problemów z niewłaściwą konfiguracją lub brakującymi pakietami współdzielonymi, co może wystąpić podczas konwencjonalnego przenoszenia skompilowanych plików binarnych do systemu docelowego.
