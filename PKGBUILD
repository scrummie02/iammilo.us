# Maintainer: Proton AG (Proton Mail Bridge developers) <bridge@protonmail.ch>
_pkgname=protonmail-bridge
pkgname=$_pkgname-bin
pkgver=3.23.1
pkgrel=1
pkgdesc="Proton Mail Bridge is a desktop application that runs in the background, encrypting and decrypting messages as they enter and leave your computer."
arch=("x86_64")
url="https://proton.me/mail/bridge"
license=("GPLv3")
depends=( 'libfido2' 'xcb-util-cursor' 'libglvnd' 'glibc' 'gcc-libs' 'glib2' 'ttf-dejavu' )
optdepends=( 'pass: pass support' 'gnome-keyring: gnome-keyring support')
conflicts=("$_pkgname" "$_pkgname-beta-bin")
provides=("$_pkgname")
source=("https://proton.me/download/bridge/protonmail-bridge_3.23.1-1_amd64.deb")
sha256sums=("d29d8373fc5e9b75e02da54d8d9e0dcc8a118dac25dec87fc9969acf4cb3c1b6")

package() {
  tar -xzC "$pkgdir" -f data.tar.gz
  rm -rf "$pkgdir/opt"
}
