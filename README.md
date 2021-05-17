# davapp

Applicazione ufficiale del Liceo Scientifico Statale "Leonardo Da Vinci" di Treviso.

## Dipendenze

## Compilazione ed esecuzione

Per eseguire una versione debug su un dispositivo locale (virtuale o fisico):
```
make run API_URL="https://example.org/api" AUTH_URL="https://sso.example.org/"
```
assicurandosi di specificare gli URL corretti dell'API e per l'autenticazione.

## Rilascio

Seguire le istruzioni ai seguenti link:

* [Android](https://flutter.dev/docs/deployment/android)
* [iOS](https://flutter.dev/docs/deployment/ios)

Per produrre gli archivi, però, utilizzare `make` in modo da includere automaticamente i metadati:
```
make apk API_URL="https://example.org/api" AUTH_URL="https://sso.example.org/"
```
```
make appbundle API_URL="https://example.org/api" AUTH_URL="https://sso.example.org/"
```
```
make ipa API_URL="https://example.org/api" AUTH_URL="https://sso.example.org/"
```

## Progetti correlati

* [webapi-dav](https://github.com/Baldomo/webapi-dav)
* [ssodav](/napaalm/ssodav)
* [syncom](/napaalm/syncom)
