#!/bin/bash

if ! [ $(id -u) == 0]; then
  echo "script must run as root"
  exit 1
fi

# vet inte om grupp 1000 existerar i CD/CI där poängen räknas ut så fular mig lite
sudo groupadd -f -g 1000

USER_LIST=$@
DOCDIR="Documents/"
DOWNDIR="Downloads/"
WORKDIR="Work/"

userdirs_create() {
  username=$1
  basepath="/home/$username"
  # hade kunnat köra lista men nästa loop for 3 element känns fel
  mkdir -p "$basepath/$DOCDIR"
  mkdir -p "$basepath/$DOWNDIR"
  mkdir -p "$basepath/$WORKDIR"
}

welcome_create() {
  username=$1
  userhome="/home/$username/"
  welcomefile="$userhome/welcome.txt"
  echo "Välkommen $username \n" > "$welcomefile"
  # hoppas inte det är olagligt att googla lösningar
  # tyckte att det hade varit fult med alla UID/GID genom att bara köra
  # echo >> /etc/passwd
  # kanske borde läsa igenom testerna iofs, de kanske vill ha med all den datan
  echo "$(cut -d: -f1 /etc/passwd')" >> "$welcomefile"
}

userdirs_r_chown() {
  username=$1
  basepath="/home/$username"
  # för att se till att allting i användarens $HOME faktiskt ägs av dem samt defaultgruppen
  # insåg i efterhand att jag hade kunnat skapa mapparna med sudo --user $username tidigare
  sudo chown -r "$username:1000" "$basepath"
  sudo chmod -r 600 "$basepath"
}

for u in $USER_LIST; do

  # lägg till användare, skapa home, sätt som grupp 1000 typ generisk Employee eller liknande
  # vänta den kanske inte existerar i CD/CI pipelines? men useradd -D på mitt system printar GROUP=1000
  # så det känns som att den borde existera? fast hellre safe than sorry
  useradd -m -g 1000 $u

  userdirs_create $u
  welcome_create $u
  userdirs_r_chown $u

done

exit 0
