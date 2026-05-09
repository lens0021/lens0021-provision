# Windows provisioning

Windows 재포맷 후 환경 복원용. Linux 스크립트와 별도로 동작.

## 사전 설치 (수동)

bootstrap 진입 전에 GUI로 처리:

- **winget** (App Installer): Microsoft Store에서 설치
- **Firefox 등 브라우저**: 부트스트랩 URL 접근용

## 실행

```powershell
irm https://raw.githubusercontent.com/lens0021/lens0021-provision/main/windows/bootstrap.ps1 | iex
```

`bootstrap.ps1`은 단일 파일에 모든 자동화를 담고 있습니다 (idempotent — 재실행 안전):

| Section | 내용 |
|---|---|
| A | winget 패키지 + Visual Studio Build Tools + bash-abbrev-alias + DebugView + marcosnils/bin + 날개셋 MSI + Claude Code |
| B | 언어 리스트 (en-US Dvorak + Korean MS IME + 날개셋), PowerToys keymap (CapsLock → Right Alt, Shift+CapsLock → CapsLock) |
| C | 시각 효과, DPI clamp, 24-hour clock, 작업표시줄/시작메뉴 debloat, IME default = 날개셋, WT defaultProfile = Git Bash, `~/.bashrc` (starship + zoxide + COLORTERM + yazi y wrapper), AltSnap Win-key, AutoHotkey startup |
| D | `config/*` 파일들을 NTFS hard link로 런타임 위치에 배포 (helix, yazi, zellij, starship, ahk, powershell, k9s, 날개셋 `imeconf.dat`) |
| E | 그래픽 드라이버 — **MSI GE62 2QL 한정**. `Win32_ComputerSystem`으로 모델 검사 후 일치할 때만 실행. 다른 머신에선 자동 skip |

## 자동화 안 된 수동 단계

bootstrap 후 직접 처리:

1. **PowerToys 첫 실행** — 시작 메뉴에서 띄우면 keymap 로드
2. **`gh auth login`** — 브라우저 인증
3. **SSH 키** — 기존 복원 또는 신규 생성
4. **Sign out → sign in** (Section E가 돌았으면 reboot이 더 깔끔)

## 그래픽 드라이버 (Section E, host-specific)

`bootstrap.ps1` 안의 Section E는 다음 하드웨어 wired:

- Intel HD Graphics 5600 (Broadwell, `VEN_8086&DEV_1612`): Intel 15.40 / DDI 20.19.15.4404
- NVIDIA GeForce GTX 950M (Maxwell, `VEN_10DE&DEV_139A`): MSI OEM 353.74 fallback

다른 기기에서 드라이버 자동화 원하면 Section E의 `$drivers` 배열과 `Test-IsMsiGe62` 검사 함수를 그 머신용으로 수정. URL은 시간이 지나면 deprecated 가능 — 실행 전 벤더 페이지 확인:

- Intel: https://www.intel.com/content/www/us/en/download/18369/intel-graphics-driver-for-windows-15-40.html
- NVIDIA: https://www.nvidia.com/Download/index.aspx

## 키보드 / IME

- 한글: 날개셋 (default) + MS IME 백업. Win+Space로 전환
- 영문: en-US **Dvorak** (시스템 레이아웃) — 단축키(Alt+P 등)가 Dvorak 위치로 정상 동작. 날개셋의 영문 모드는 단축키 처리 안 해서 시스템 레이아웃 우선
- PowerToys: CapsLock → Right Alt (한영 토글 시도), Shift+CapsLock → CapsLock (대소문자 락)
- 날개셋 세벌식 최종 자체 설정은 `config/imeconf.dat`로 자동 배포 (Section D)
- 볼륨: AutoHotkey가 Ctrl+Win+↑/↓로 매핑 (Section C 등록, `config/ahk/keys.ahk` 참고)
