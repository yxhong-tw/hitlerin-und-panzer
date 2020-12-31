TITLE Bullet (Bullet.asm)

; ==========
; = Bullet =
; ==========

; The main handler of the bullets


;; PrintBullet
;; print bullet
PrintBullet PROC USES eax ebx esi edi,
    thisBullet: PTR bullet,
    thisGameMap: PTR BYTE
    
    ; print bullet
    mov esi, thisBullet
    INVOKE PushRenderBufferImageDiscardable, 
        RENDER_BUFFER_LAYER_BULLETS, 
        OFFSET bulletCmdImage,
        (BULLET PTR [esi]).position

    ; record in map
    mov edi, gameMap
    INVOKE GetRenderBufferIndex, (BULLET PTR [esi]).position
    movzx eax, ax
    movzx ebx, (BULLET PTR [esi]).role

    .IF ebx == ROLE_PLAYER
        mov (BYTE PTR [edi + eax]), GAME_MAP_CHAR_PLAYER_BULLET
    .ELSEIF ebx == ROLE_ENEMY
        mov (BYTE PTR [edi + eax]), GAME_MAP_CHAR_ENEMY_BULLET
    .ENDIF
    ret
PrintBullet ENDP

;; EraseBullet
;; before print new bullet, remove the old bullet 
; EraseBullet PROC USES ecx esi edi, 
;     thisOutputHandle: DWORD,
;    thisBullet: PTR BULLET,
;    thisGameMap: PTR BYTE,
;    countWord: PTR DWORD
;
;    mov esi, thisBullet
;
;    INVOKE PushRenderBufferImageBlank,
;        RENDER_BUFFER_LAYER_BULLETS,
;        (TANK PTR [esi]).position,
;        bulletSize
;
;    ; record in map
;    movzx ecx, (BULLET PTR [esi]).position.Y
;    mov edi, thisGameMap
;EraseBullet_ChangeRow:
;    add edi, GAME_MAP_WIDTH
;    loop EraseBullet_ChangeRow
;
;    movzx ecx, (BULLET PTR [esi]).position.X
;    add edi, ecx
;       
;    mov (BYTE PTR [edi]), GAME_MAP_CHAR_EMPTY
;
;    ret
;EraseBullet ENDP


EraseBullet PROC USES eax ecx esi edi,
    thisBullet: PTR Bullet,
    thisGameMap: PTR BYTE

    mov esi, thisBullet

    ; erase bullet
    INVOKE PushRenderBufferImageBlank,
        RENDER_BUFFER_LAYER_BULLETS,
        (BULLET PTR [esi]).position,
        bulletSize

    ; record in map
    mov edi, thisGameMap
    INVOKE GetRenderBufferIndex, (BULLET PTR [esi]).position
    movzx eax, ax
       
    mov (BYTE PTR [edi + eax]), GAME_MAP_CHAR_EMPTY
    ret
EraseBullet ENDP

;; BulletMove
;; move one byte toward bullet's direction
BulletMove PROC USES eax esi,
    thisBullet: PTR bullet,
    thisGameMap: PTR BYTE,
    bulletAmount: byte,
    bulletList: PTR BULLET

    LOCAL checkPosition:COORD

    ; erase tank
    INVOKE eraseBullet, thisBullet, thisGameMap
    
    mov esi, thisBullet
    mov al, (Bullet PTR [esi]).direction 
    movzx ebx, (Bullet PTR [esi]).role
    ; different check
    cmp al, FACE_UP
    je BulletMove_FlyUp
    cmp al, FACE_RIGHT
    je BulletMove_FlyRight
    cmp al, FACE_DOWN
    je BulletMove_FlyDown
    cmp al, FACE_LEFT
    je BulletMove_FlyLeft
BulletMove_FlyUp:
    ; before move, check
    mov ax, (BULLET PTR [esi]).position.Y
    dec ax
    mov checkPosition.y, ax
    mov ax, (TANK PTR [esi]).position.x
    mov checkPosition.x, ax

    INVOKE GetRenderBufferIndex, checkPosition
    movzx eax, ax

    ; if role's bullet hit wall, enemy's bullet, enemy's tank
    .IF (BYTE PTR [edi + eax]), GAME_MAP_CHAR_WALL_0
        ; remove this bullet from bullet list
        jmp MoveBullet_return  
    .ELSEIF (BYTE PTR [edi + eax]), GAME_MAP_CHAR_WALL_1
        ; remove this bullet form bullet list
        jmp MoveBullet_return
    .ELSEIF (BYTE PTR [edi + eax]), GAME_MAP_CHAR_ENEMY_BULLET
        sub (BULLET PTR [esi]).position.y, 1
        ; remove this bullet form bullet list
        jmp MoveBullet_return 
    .ELSEIF (BYTE PTR [edi + eax]), GAME_MAP_CHAR_PLAYER_BULLET
        sub (BULLET PTR [esi]).position.y, 1
        ; remove this bullet form bullet list
        jmp MoveBullet_return 
    .ENDIF
    
    .IF ebx == ROLE_PLAYER
        .IF (BYTE PTR [edi + eax]), GAME_MAP_ENEMY
            ; remove this bullet from bullet list
            ; remove enemy tank
            jmp MoveBullet_return 
        .ENDIF    
    .ELSEIF ebx == ROLE_ENEMY
        .IF (BYTE PTR [edi + eax]), GAME_MAP_PLAYER
            ; remove this bullet from bullet list
            ; remove enemy tank
            jmp MoveBullet_return 
        .ENDIF
    .ENDIF

    sub (Bullet PTR [esi]).position.y, 1
    jmp Print_bullet
BulletMove_FlyRight:
    ; before move, check
    mov ax, (BULLET PTR [esi]).position.Y
    mov checkPosition.y, ax
    mov ax, (TANK PTR [esi]).position.x
    inc ax
    mov checkPosition.x, ax

    INVOKE GetRenderBufferIndex, checkPosition
    movzx eax, ax

    ; if role's bullet hit wall, enemy's bullet, enemy's tank
    .IF (BYTE PTR [edi + eax]), GAME_MAP_CHAR_WALL_0
        ; remove this bullet from bullet list
        jmp MoveBullet_return  
    .ELSEIF (BYTE PTR [edi + eax]), GAME_MAP_CHAR_WALL_1
        ; remove this bullet form bullet list
        jmp MoveBullet_return
    .ELSEIF (BYTE PTR [edi + eax]), GAME_MAP_CHAR_ENEMY_BULLET
        add (BULLET PTR [esi]).position.x, 1
        ; remove this bullet form bullet list
        jmp MoveBullet_return 
    .ELSEIF (BYTE PTR [edi + eax]), GAME_MAP_CHAR_PLAYER_BULLET
        add (BULLET PTR [esi]).position.x, 1
        ; remove this bullet form bullet list
        jmp MoveBullet_return 
    .ENDIF
    
    .IF ebx == ROLE_PLAYER
        .IF (BYTE PTR [edi + eax]), GAME_MAP_ENEMY
            ; remove this bullet from bullet list
            ; remove enemy tank
            jmp MoveBullet_return 
        .ENDIF    
    .ELSEIF ebx == ROLE_ENEMY
        .IF (BYTE PTR [edi + eax]), GAME_MAP_PLAYER
            ; remove this bullet from bullet list
            ; remove enemy tank
            jmp MoveBullet_return 
        .ENDIF
    .ENDIF

    sub (Bullet PTR [esi]).position.y, 1
    jmp Print_bullet
BulletMove_FlyDown:
    ; before move, check
    mov ax, (BULLET PTR [esi]).position.Y
    mov checkPosition.y, ax
    inc ax
    mov ax, (TANK PTR [esi]).position.x
    mov checkPosition.x, ax

    INVOKE GetRenderBufferIndex, checkPosition
    movzx eax, ax

    ; if role's bullet hit wall, enemy's bullet, enemy's tank
    .IF (BYTE PTR [edi + eax]), GAME_MAP_CHAR_WALL_0
        ; remove this bullet from bullet list
        jmp MoveBullet_return  
    .ELSEIF (BYTE PTR [edi + eax]), GAME_MAP_CHAR_WALL_1
        ; remove this bullet form bullet list
        jmp MoveBullet_return
    .ELSEIF (BYTE PTR [edi + eax]), GAME_MAP_CHAR_ENEMY_BULLET
        add (BULLET PTR [esi]).position.x, 1
        ; remove this bullet form bullet list
        jmp MoveBullet_return 
    .ELSEIF (BYTE PTR [edi + eax]), GAME_MAP_CHAR_PLAYER_BULLET
        add (BULLET PTR [esi]).position.x, 1
        ; remove this bullet form bullet list
        jmp MoveBullet_return 
    .ENDIF
    
    .IF ebx == ROLE_PLAYER
        .IF (BYTE PTR [edi + eax]), GAME_MAP_ENEMY
            ; remove this bullet from bullet list
            ; remove enemy tank
            jmp MoveBullet_return 
        .ENDIF    
    .ELSEIF ebx == ROLE_ENEMY
        .IF (BYTE PTR [edi + eax]), GAME_MAP_PLAYER
            ; remove this bullet from bullet list
            ; remove enemy tank
            jmp MoveBullet_return 
        .ENDIF
    .ENDIF

    add (Bullet PTR [esi]).position.y, 1
    jmp Print_bullet
BulletMove_FlyLeft:
    ; before move, check
    mov ax, (BULLET PTR [esi]).position.Y
    mov checkPosition.y, ax
    mov ax, (TANK PTR [esi]).position.x
    sub ax, 1
    mov checkPosition.x, ax

    INVOKE GetRenderBufferIndex, checkPosition
    movzx eax, ax

    ; if role's bullet hit wall, enemy's bullet, enemy's tank
    .IF (BYTE PTR [edi + eax]), GAME_MAP_CHAR_WALL_0
        ; remove this bullet from bullet list
        jmp MoveBullet_return  
    .ELSEIF (BYTE PTR [edi + eax]), GAME_MAP_CHAR_WALL_1
        ; remove this bullet form bullet list
        jmp MoveBullet_return
    .ELSEIF (BYTE PTR [edi + eax]), GAME_MAP_CHAR_ENEMY_BULLET
        add (BULLET PTR [esi]).position.x, 1
        ; remove this bullet form bullet list
        jmp MoveBullet_return 
    .ELSEIF (BYTE PTR [edi + eax]), GAME_MAP_CHAR_PLAYER_BULLET
        add (BULLET PTR [esi]).position.x, 1
        ; remove this bullet form bullet list
        jmp MoveBullet_return 
    .ENDIF
    
    .IF ebx == ROLE_PLAYER
        .IF (BYTE PTR [edi + eax]), GAME_MAP_ENEMY
            ; remove this bullet from bullet list
            ; remove enemy tank
            jmp MoveBullet_return 
        .ENDIF    
    .ELSEIF ebx == ROLE_ENEMY
        .IF (BYTE PTR [edi + eax]), GAME_MAP_PLAYER
            ; remove this bullet from bullet list
            ; remove enemy tank
            jmp MoveBullet_return 
        .ENDIF
    .ENDIF

    ; move
    sub (Bullet PTR [esi]).position.x, 1
    jmp Print_bullet
Print_bullet:
    INVOKE printBullet, thisBullet, thisGameMap
MoveBullet_return:
    ret
BulletMove ENDP


; BulletMove PROC USES eax esi,
;     thisOutputHandle: DWORD, 
;     thisBullet: PTR BULLET,
;     thisGameMap: PTR BYTE,
;     countWord: PTR DWORD

;     INVOKE EraseBullet, thisOutputHandle, thisBullet, thisGameMap, countWord
    
;     mov esi, thisBullet
;     mov al, (BULLET PTR [esi]).direction 
    
;     cmp al, FACE_UP
;     je BulletMove_FlyUp
;     cmp al, FACE_RIGHT
;     je BulletMove_FlyRight
;     cmp al, FACE_DOWN
;     je BulletMove_FlyDown
;     cmp al, FACE_LEFT
;     je BulletMove_FlyLeft

; BulletMove_FlyUp:
;     sub (BULLET PTR [esi]).position.Y, 1
;     jmp BulletMove_EndMove
; BulletMove_FlyRight:
;     add (BULLET PTR [esi]).position.X, 1
;     jmp BulletMove_EndMove
; BulletMove_FlyDown:
;     add (BULLET PTR [esi]).position.Y, 1
;     jmp BulletMove_EndMove
; BulletMove_FlyLeft:
;     sub (BULLET PTR[esi]).position.X, 1
;     jmp BulletMove_EndMove
; BulletMove_EndMove:
;     INVOKE PrintBullet, thisOutputHandle, thisBullet, thisGameMap, countWord
;     ret
; BulletMove ENDP

;; NewBullet
;; FIXME:
NewBullet PROC USES eax ecx esi edi,
    thisTank: PTR TANK,
    bulletAmount: PTR BYTE,
    bulletList: PTR BULLET

    ; get the position that the new bullet should appear
    mov esi, bulletList
    mov edi, bulletAmount
    mov al, [edi]
    .IF al == 0h
        jmp NewBullet_SetNewBullet
    .ENDIF
    movzx ecx, al
NewBullet_MoveToNewBullet:
    add esi, 10
    loop NewBullet_MoveToNewBullet

NewBullet_SetNewBullet:
    mov edi, thisTank
    mov al, (tank PTR [edi]).faceTo

    .IF al == FACE_UP
        mov ax, (TANK PTR [edi]).position.x
        add ax, 1h
        mov (bullet PTR [esi]).position.x, ax

        mov ax, (TANK PTR [edi]).position.y
        sub ax, 1h
        mov (bullet PTR [esi]).position.y, ax

        ; mov (bullet PTR [esi]).position.X, (tank PTR [edi]).position.X
        ; add (bullet PTR [esi]).position.X, 1h

        ; mov (bullet PTR [esi]).position.Y, (tank PTR [edi]).position.Y
        ; sub (bullet PTR [esi]).position.Y, 1h

        mov (bullet PTR [esi]).direction, FACE_UP
        jmp NewBullet_NewBulletEnd
    .ENDIF

    .IF al == FACE_RIGHT
        mov ax, (TANK PTR [edi]).position.x
        add ax, 3h
        mov (bullet PTR [esi]).position.x, ax

        mov ax, (TANK PTR [edi]).position.y
        add ax, 1h
        mov (bullet PTR [esi]).position.y, ax

        ; mov (bullet PTR [esi]).position.X, (TANK PTR [edi]).position.X
        ; add (bullet PTR [esi]).position.X, 3h

        ; mov (bullet PTR [edi]).position.Y, (TANK PTR [edi]).position.Y
        ; add (bullet PTR [edi]).position.Y, 1h

        mov (bullet PTR [edi]).direction, FACE_RIGHT
        jmp NewBullet_NewBulletEnd
    .ENDIF

    .IF al == FACE_DOWN
        mov ax, (TANK PTR [edi]).position.x
        add ax, 3h
        mov (bullet PTR [esi]).position.x, ax

        mov ax, (TANK PTR [edi]).position.y
        add ax, 3h
        mov (bullet PTR [esi]).position.y, ax

        ; mov (bullet PTR [esi]).position.X, (TANK PTR [edi]).position.X
        ; add (bullet PTR [esi]).position.X, 1h

        ; mov (bullet PTR [edi]).position.Y, (TANK PTR [edi]).position.Y
        ; add (bullet PTR [edi]).position.Y, 3h

        mov (bullet PTR [edi]).direction, FACE_DOWN
        jmp NewBullet_NewBulletEnd
    .ENDIF

    .IF al == FACE_LEFT
        mov ax, (TANK PTR [edi]).position.x
        sub ax, 1h
        mov (bullet PTR [esi]).position.x, ax

        mov ax, (TANK PTR [edi]).position.y
        add ax, 1h
        mov (bullet PTR [esi]).position.y, ax

        ; mov (bullet PTR [esi]).position.X, (TANK PTR [edi]).position.X
        ; sub (bullet PTR [esi]).position.X, 1

        ; mov (bullet PTR [edi]).position.Y, (TANK PTR [edi]).position.Y
        ; add (bullet PTR [edi]).position.Y, 1

        mov (bullet PTR [edi]).direction, FACE_LEFT
        jmp NewBullet_NewBulletEnd
    .ENDIF
NewBullet_NewBulletEnd:
    mov esi, bulletAmount 
    add (BYTE PTR [esi]), 1
    ret
NewBullet ENDP 


;; this proc is been moved to bullet_move
;; BulletHit
;; check if bullet has hit wall or tank 
;; FIXME:
; BulletHit PROC USES eax ebx ecx esi edi,
;     thisBullet: PTR BULLET,
;     thisBulletAmount: PTR BYTE, 
;     thisGameMap: PTR BYTE

;     mov esi, thisBullet
;     mov edi, thisGameMap
    
;     movzx ecx, (BULLET PTR [esi]).position.Y
; BulletHit_ChangeRow:
;     add edi, GAME_MAP_WIDTH
;     loop BulletHit_ChangeRow

;     movzx ecx, (bullet PTR [esi]).position.X
;     add edi, ecx
    
;     mov ebx, [edi]
;     .IF ebx == GAME_MAP_CHAR_EMPTY
;         jmp BulletHit_BulletHitEnd
;     .ENDIF

;     push esi
;     mov esi, thisBulletAmount               ; hit something (tank or wall)
;     sub (BYTE PTR [esi]), 1                 ; bullet amount - 1
;     pop esi

;     mov al, (bullet PTR [esi]).role
;     .IF ebx == GAME_MAP_CHAR_PALYER                        ; hit our tank
;         .IF al == ROLE_PLAYER
;             jmp BulletHit_BulletHitEnd
;         .ENDIF
;         ; ourTankDestroy
;         ; 
;     .ENDIF

;     .IF ebx == GAME_MAP_CHAR_ENEMY                        ; hit enemy's tank
;         .IF al == ROLE_ENEMY
;             jmp BulletHit_BulletHitEnd                ; enemy hit enemy
;         .ENDIF
;         ; enemyTankDestroy
;     .ENDIF
;                                             ; if hit wall, do nothing      
; BulletHit_BulletHitEnd:
;     ret
; BulletHit ENDP
