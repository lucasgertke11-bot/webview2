# Microsoft Edge WebView2 Runtime Portable Installer for Wine/Proton

Instala o Microsoft Edge WebView2 Runtime em qualquer prefixo Wine/Proton para habilitar login e telas web embarcadas em jogos/launchers.

## Download

**[install-webview2.exe](https://github.com/lucasgertke11-bot/webview2/releases/download/v1.0.0/install-webview2.exe)** (193 MB)

## Uso

```bash
WINEPREFIX=/caminho/do/prefixo wine install-webview2.exe
```

## O que instala

| Item | Detalhe |
|---|---|
| Runtime | Edge WebView2 v149.0.4022.52 (Evergreen) |
| Arquivos | msedgewebview2.exe, msedge.dll, EmbeddedBrowserWebView.dll (+ 762 arquivos) |
| Registry | EdgeUpdate Clients key (deteccao), COM CLSID (x86 + x64), Uninstall, edgeupdate service |

## Requisitos

- .NET Framework 4.8 (recomendado)
- Visual C++ 2015-2022 Redistributable

## Build

```bash
cd installer
wine makensis.exe install.nsi
```

## Licença MIT
