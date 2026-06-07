; Microsoft Edge WebView2 Runtime Portable Installer for Wine/Proton
; Extracted from working prefix + manual COM registration
; Compile: wine makensis.exe install.nsi

Unicode true
SetCompressor /SOLID lzma
Name "Microsoft Edge WebView2 Runtime Portable"
OutFile "install-webview2.exe"
RequestExecutionLevel admin
ShowInstDetails show

!include LogicLib.nsh

Var /GLOBAL hasErrors
Var /GLOBAL VERSION
Var /GLOBAL WV_DIR

!define PF86 "$WINDIR\..\Program Files (x86)"

Section "-PreInstall"
  DetailPrint "Setting up environment..."
  StrCpy $VERSION "149.0.4022.52"
  StrCpy $WV_DIR "${PF86}\Microsoft\EdgeWebView\Application\$VERSION"

  DetailPrint "Removing blocking registry keys..."
  nsExec::ExecToLog '"$WINDIR\system32\reg.exe" delete "HKLM\Software\WOW6432Node\Microsoft\EdgeWebView" /f'
  nsExec::ExecToLog '"$WINDIR\system32\reg.exe" delete "HKLM\Software\Microsoft\EdgeWebView" /f'
  nsExec::ExecToLog '"$WINDIR\system32\reg.exe" delete "HKLM\Software\WOW6432Node\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}" /f'
  nsExec::ExecToLog '"$WINDIR\system32\reg.exe" delete "HKLM\Software\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}" /f'

  DetailPrint "Cleaning old WebView2 files..."
  RMDir /r "${PF86}\Microsoft\EdgeWebView"
  RMDir /r "${PF86}\Microsoft\EdgeCore"
SectionEnd

Section "Extract WebView2 Runtime"
  SetOutPath "$TEMP\webview2-installer"

  DetailPrint "Extracting tools..."
  File "7za.exe"
  File "webview2-package.7z"
  File "webview2-full.reg"

  DetailPrint "Extracting to ${PF86}..."
  ExecWait '"$TEMP\webview2-installer\7za.exe" x "$TEMP\webview2-installer\webview2-package.7z" -o"${PF86}" -y' $0

  ${If} $0 != 0
    DetailPrint "ERROR: Extraction failed with code $0"
    MessageBox MB_ICONSTOP "Failed to extract. Error code: $0"
    Abort
  ${EndIf}

  DetailPrint "Extraction complete!"
SectionEnd

Section "Import Registry"
  DetailPrint "Importing registry (COM registration + EdgeUpdate)..."
  ExecWait '"$WINDIR\regedit.exe" /S "$TEMP\webview2-installer\webview2-full.reg"' $0
  ${If} $0 != 0
    DetailPrint "WARNING: regedit returned code $0"
  ${Else}
    DetailPrint "Registry imported!"
  ${EndIf}

  DetailPrint "Setting up x64 CLSID..."
  ; Use sysnative to bypass WOW64 file system redirector and access 64-bit reg.exe
  nsExec::ExecToLog '"$WINDIR\sysnative\reg.exe" add "HKLM\Software\Classes\CLSID\{daa52b27-8897-50af-ada5-c6c71bb64e17}" /ve /d "Embedded Browser WebView" /f'
  nsExec::ExecToLog '"$WINDIR\sysnative\reg.exe" add "HKLM\Software\Classes\CLSID\{daa52b27-8897-50af-ada5-c6c71bb64e17}\InprocServer32" /ve /d "${PF86}\Microsoft\EdgeWebView\Application\149.0.4022.52\EBWebView\x64\EmbeddedBrowserWebView.dll" /f'
  nsExec::ExecToLog '"$WINDIR\sysnative\reg.exe" add "HKLM\Software\Classes\CLSID\{daa52b27-8897-50af-ada5-c6c71bb64e17}\InprocServer32" /v ThreadingModel /d "Apartment" /f'
  DetailPrint "x64 CLSID registered!"
SectionEnd

Section "Verify Installation"
  StrCpy $hasErrors "0"

  DetailPrint ""
  DetailPrint "Verifying installation..."

  ${If} ${FileExists} "$WV_DIR\msedgewebview2.exe"
    DetailPrint "  [OK] msedgewebview2.exe"
  ${Else}
    DetailPrint "  [FAIL] msedgewebview2.exe missing"
    StrCpy $hasErrors "1"
  ${EndIf}

  ${If} ${FileExists} "$WV_DIR\msedge.dll"
    DetailPrint "  [OK] msedge.dll"
  ${Else}
    DetailPrint "  [FAIL] msedge.dll missing"
    StrCpy $hasErrors "1"
  ${EndIf}

  ${If} ${FileExists} "$WV_DIR\EBWebView\x64\EmbeddedBrowserWebView.dll"
    DetailPrint "  [OK] EmbeddedBrowserWebView.dll (x64)"
  ${Else}
    DetailPrint "  [FAIL] EmbeddedBrowserWebView.dll (x64) missing"
    StrCpy $hasErrors "1"
  ${EndIf}

  ${If} ${FileExists} "$WV_DIR\EBWebView\x86\EmbeddedBrowserWebView.dll"
    DetailPrint "  [OK] EmbeddedBrowserWebView.dll (x86)"
  ${Else}
    DetailPrint "  [FAIL] EmbeddedBrowserWebView.dll (x86) missing"
    StrCpy $hasErrors "1"
  ${EndIf}

  ; Registry verification
  DetailPrint "Verifying registry..."
  ExecWait '"$WINDIR\regedit.exe" /E "$TEMP\webview2-installer\regcheck.reg" "HKLM\Software\WOW6432Node\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}"' $0
  ${If} $0 == 0
    ${If} ${FileExists} "$TEMP\webview2-installer\regcheck.reg"
      DetailPrint "  [OK] EdgeUpdate Clients registry key present"
    ${Else}
      DetailPrint "  [FAIL] EdgeUpdate Clients registry key missing"
      StrCpy $hasErrors "1"
    ${EndIf}
  ${Else}
    DetailPrint "  [WARN] Could not verify registry"
  ${EndIf}

  DetailPrint ""
  ${If} $hasErrors == "0"
    DetailPrint "========================================"
    DetailPrint " All files verified. Installation OK!"
    DetailPrint "========================================"
    MessageBox MB_OK "Microsoft Edge WebView2 Runtime installed and verified successfully!"
  ${Else}
    DetailPrint "========================================"
    DetailPrint " Some files could not be installed."
    DetailPrint "========================================"
    MessageBox MB_OK "Some WebView2 files could not be installed. Check details."
  ${EndIf}
SectionEnd
