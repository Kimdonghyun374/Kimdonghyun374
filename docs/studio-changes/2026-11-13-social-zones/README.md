# Studio 변경 사본 — 기지·장난 권총·구역1~3

게임의 원본은 Place122289987934213의 Edit DataModel이다. 이 폴더는 자동 Rojo 반영 대상이 아닌 검토 사본이다.

- 원본 백업: ServerStorage.ProjectMSBackups.BeforeSocialZonesBase_1794511854
- ApplyMap.luau: 기존 배치에서 한 번만 실행하는 부지96×120·연구시설 축소·중앙 동선·구역22건물 배치(중복 실행 방지).
- CreateSocialScene.luau: 기지 출입문/담장·권총 Tool·HUD/Edit 미리보기 생성. 한 번만 실행한다.
- ProgressionRules/ProgressionService는 ServerScriptService.PetMissiles, WorldConfig/SocialConfig는 ReplicatedStorage.PetMissiles에 대응한다.
- SocialService/SocialController는 ServerScriptService.PetMissiles, SocialClient는 StarterPlayerScripts에 대응한다.
- 복원 후 재현할 때 맵·장면 생성과 모듈/스크립트 배치를 모두 끝내고 Play를 시작한다. 실행 중 서버에 이 파일들을 복사해 고치지 않는다.
- 방문 잠금은 저장하지 않고 세션마다 허용으로 시작한다. 두 입구 통과는 클라이언트 충돌 설정, 우회 진입은 서버 위치 검사로 처리한다.
- 권총 체력 피해는0. 서버 사거리160·발사1.5초·랙돌1.2초·피격 보호6초·약한 밀림12/상향6/각속도4. 표시: 이중Beam 금색0.35/흰색0.12stud·0.4초, 탄환0.55stud.
- 구역완파 보상은4/6/10 연구자료(시험). 신규 구역6/8채 HP·코인·좌표는 manifest.json과 BUILDINGS 참조.

검증: Play 1인 Mock에서 구역8/6/8 생성·해금·완료·연구20, 첫 표적 실제 미사일 파괴·나머지 서버피해로 완료 흐름 검증. 잠금 주인/방문자·타인 설정 거절, NPC 권총 판정·회복·체력 보존·연사/연속 피격 방지·추가 관절 정리 검증. 격리 규칙의 저장 정규화·구버전 월드2권한 보존·주기 초기화 검증.

추가 확인: 실제 PC G키·HUD 장착/해제·클릭 발사/서버/클라이언트 궤적 수신 통과. 미검증: 실제2인, 모바일·탄도 실기기 가독성, 게시 저장/재접속, 전체 자연 공략시간. 화면/입력 도구 지연·앱 접근 승인 시간 초과가 있었다. 실측 성공으로 기록하지 않는다. 테스트 러너는 제거했고 두 Studio 모두 Edit 복귀, Save/Publish 미실행.
