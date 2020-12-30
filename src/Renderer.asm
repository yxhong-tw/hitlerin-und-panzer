TITLE Renderer (Renderer.asm)

; ============
; = Renderer =
; ============

; The major rendering part of the game


;; InitRenderer
InitRenderer PROC USES ecx esi edi
    call Clrscr

    ; Clear all render buffer layers
    mov ecx, RENDER_BUFFER_LAYERS
InitRenderer_ClearRenderBufferLayersAll:
    dec ecx
    mClearRenderBuffer ecx
    cmp ecx, 0
    jbe InitRenderer_ClearRenderBufferLayersAll

    ; Set default cursor style
    INVOKE SetConsoleCursorInfo, stdOutputHandle, ADDR stdConsoleCursorInfo

    ; Initialize the game map to show
    cld
    mov ecx, GAME_MAP_WIDTH * GAME_MAP_HEIGHT
    mov esi, OFFSET mapCmdImage_characters
    mov edi, OFFSET mapCmdImage.characters
    rep movsb
    INVOKE PushRenderBufferImageDiscardable, RENDER_BUFFER_LAYER_GAME_MAP, ADDR mapCmdImage, stdRenderOrigin

    ret
InitRenderer ENDP

;; GetCutSize
GetCutSize PROC USES ax edi,
    innerPosition:COORD,
    innerSize:COORD,
    outerlimit:COORD,
    renderSize:PTR COORD

    mov edi, renderSize

    mGetCutSizeAxis ax, innerPosition.x, innerSize.x, outerlimit.x
    mov (COORD PTR[edi]).x, ax
    mGetCutSizeAxis ax, innerPosition.y, innerSize.y, outerlimit.y
    mov (COORD PTR[edi]).y, ax

    ret
GetCutSize ENDP

;; GetRenderBufferIndex
;; To find the corresponging index to a coordinate of the render buffer
;; Parameters:
;;     position:COORD: The coordination to be caculated
;; Returns:
;;     AX: The corresponging index of the render buffer
GetRenderBufferIndex PROC,
    position:COORD

    ; position.y * SCREEN_BUFFER_WIDTH + position.x

    ; In default
    ; SCREEN_BUFFER_WIDTH  = 128 = 2^7
    ; SCREEN_BUFFER_HEIGHT =  32 = 2^5

    mov ax, position.y
    shl ax, 7
    add ax, position.x

    ret
GetRenderBufferIndex ENDP

;; GetRenderBufferCoord
GetRenderBufferCoord PROC USES ax cx esi,
    index:WORD,
    position:PTR COORD

    ; x = index - y * SCREEN_BUFFER_WIDTH
    ; y = index / SCREEN_BUFFER_WIDTH

    ; In default
    ; SCREEN_BUFFER_WIDTH  = 128 = 2^7
    ; SCREEN_BUFFER_HEIGHT =  32 = 2^5

    mov ax, index
    and ax, 007Fh
    mov cx, index
    shr cx, 7

    mov esi, position
    mov (COORD PTR [esi]).x, ax
    mov (COORD PTR [esi]).y, cx

    ret
GetRenderBufferCoord ENDP

;; CoverRenderBufferLayer
CoverRenderBufferLayer PROC USES eax ecx edx esi edi,
    sourceLayer:DWORD,
    targetLayer:DWORD

    cld
    mGetRenderBufferLayerIndex eax, sourceLayer
    mGetRenderBufferLayerIndex edx, targetLayer

    mov ecx, SCREEN_BUFFER_WIDTH * SCREEN_BUFFER_HEIGHT
    lea esi, stdRenderBuffer[eax].characters
    lea edi, stdRenderBuffer[edx].characters
    rep movsb

    mov ecx, SCREEN_BUFFER_WIDTH * SCREEN_BUFFER_HEIGHT
    ; lea esi, stdRenderBuffer[eax].attributes
    ; lea edi, stdRenderBuffer[edx].attributes
    rep movsw

    ret
CoverRenderBufferLayer ENDP

;; CoverRenderBufferLayerDiscardable
CoverRenderBufferLayerDiscardable PROC USES eax ecx esi edi,
    sourceLayer:DWORD,
    targetLayer:DWORD

    cld
    mGetRenderBufferLayerIndex esi, sourceLayer
    mGetRenderBufferLayerIndex edi, targetLayer

    mov ecx, SCREEN_BUFFER_WIDTH * SCREEN_BUFFER_HEIGHT
    xor eax, eax
CoverRenderBufferLayerDiscardable_CoverLoop:
    mov bl, stdRenderBuffer[esi].characters[eax]
    cmp bl, RENDER_BUFFER_DISCARD
    je CoverRenderBufferLayerDiscardable_CoverLoop_Discard
    mov stdRenderBuffer[edi].characters[eax], bl

    shl eax, 1
    mov bx, stdRenderBuffer[esi].attributes[eax]
    mov stdRenderBuffer[edi].attributes[eax], bx
    shr eax, 1

CoverRenderBufferLayerDiscardable_CoverLoop_Discard:
    inc eax
    loop CoverRenderBufferLayerDiscardable_CoverLoop

    ret
CoverRenderBufferLayerDiscardable ENDP

;; SetRenderBuffer
SetRenderBuffer PROC USES ax ebx ecx edi,
    layer:DWORD,
    characterValue:BYTE,
    attributeValue:WORD

    cld
    mGetRenderBufferLayerIndex ebx, layer

    mov al, characterValue
    mov ecx, SCREEN_BUFFER_WIDTH * SCREEN_BUFFER_HEIGHT
    lea edi, stdRenderBuffer[ebx].characters
    rep stosb

    mov ax, attributeValue
    mov ecx, SCREEN_BUFFER_WIDTH * SCREEN_BUFFER_HEIGHT
    lea edi, stdRenderBuffer[ebx].attributes
    rep stosw

    ret
SetRenderBuffer ENDP

;; PushRenderBufferImage
;; TODO: Improvement?
PushRenderBufferImage PROC USES eax ebx ecx edx esi edi,
    layer:DWORD,
    cmdImage:PTR CMD_IMAGE,
    position:COORD
    LOCAL renderSize:COORD

    cld
    mov edx, cmdImage

    INVOKE GetCutSize,
        position,
        (CMD_IMAGE PTR [edx]).imageSize,
        screenBufferSize,
        ADDR renderSize
    .IF renderSize.x <= 0 || renderSize.y <= 0
        jmp PushRenderBufferImage_AllDiscard
    .ENDIF

    INVOKE GetRenderBufferIndex, position
    movzx eax, ax
    xor ebx, ebx
    movzx ecx, renderSize.y
PushRenderBufferImage_ColumnLoop:
    push ecx

    mGetRenderBufferLayerIndex ecx, layer
    lea esi, (CMD_IMAGE PTR [edx]).characters[ebx]
    lea edi, stdRenderBuffer[ecx].characters[eax]
    movzx ecx, renderSize.x
    rep movsb

    shl ebx, 1
    shl eax, 1
    mGetRenderBufferLayerIndex ecx, layer
    lea esi, (CMD_IMAGE PTR [edx]).attributes[ebx]
    lea edi, stdRenderBuffer[ecx].attributes[eax]
    movzx ecx, renderSize.x
    rep movsw
    shr ebx, 1
    shr eax, 1

    add eax, SCREEN_BUFFER_WIDTH
    add bx, (CMD_IMAGE PTR [edx]).imageSize.x

    pop ecx
    loop PushRenderBufferImage_ColumnLoop

PushRenderBufferImage_AllDiscard:
    ret
PushRenderBufferImage ENDP

;; PushRenderBufferImageBlank
PushRenderBufferImageBlank PROC USES ax,
    layer:DWORD,
    position:COORD,
    blankSize:COORD

    mov ax, blankSize.x
    mov blankCmdImage.imageSize.x, ax
    mov ax, blankSize.y
    mov blankCmdImage.imageSize.y, ax
    INVOKE PushRenderBufferImage, layer, ADDR blankCmdImage, position

    ret
PushRenderBufferImageBlank ENDP

;; PushRenderBufferImageDiscardable
;; TODO: Improvement? Check correctness?
PushRenderBufferImageDiscardable PROC USES eax ebx ecx edx esi edi,
    layer:DWORD,
    cmdImage:PTR CMD_IMAGE,
    position:COORD
    LOCAL renderSize:COORD

    mov esi, cmdImage
    mGetRenderBufferLayerIndex edi, layer

    INVOKE GetCutSize,
        position,
        (CMD_IMAGE PTR [esi]).imageSize,
        screenBufferSize,
        ADDR renderSize
    .IF renderSize.x <= 0 || renderSize.y <= 0
        jmp PushRenderBufferImageDiscardable_AllDiscard
    .ENDIF

    INVOKE GetRenderBufferIndex, position
    movzx eax, ax
    xor ebx, ebx
    movzx ecx, renderSize.y
PushRenderBufferImageDiscardable_ColumnLoop:
    push ecx
    movzx ecx, renderSize.x

PushRenderBufferImageDiscardable_ColumnLoop_OneCell:
    mov dl, (CMD_IMAGE PTR [esi]).characters[ebx]
    cmp dl, RENDER_BUFFER_DISCARD
    je PushRenderBufferImageDiscardable_ColumnLoop_OneCell_Discard
    mov BYTE PTR stdRenderBuffer[edi].characters[eax], dl

    shl ebx, 1
    shl eax, 1
    mov dx, (CMD_IMAGE PTR [esi]).attributes[ebx]
    mov WORD PTR stdRenderBuffer[edi].attributes[eax], dx
    shr ebx, 1
    shr eax, 1

PushRenderBufferImageDiscardable_ColumnLoop_OneCell_Discard:
    inc ebx
    inc eax
    loop PushRenderBufferImageDiscardable_ColumnLoop_OneCell

    add eax, SCREEN_BUFFER_WIDTH
    movzx edx, renderSize.x
    sub eax, edx

    pop ecx
    loop PushRenderBufferImageDiscardable_ColumnLoop

PushRenderBufferImageDiscardable_AllDiscard:
    ret
PushRenderBufferImageDiscardable ENDP

;; IntegrateRenderBufferFinaleAll
IntegrateRenderBufferFinaleAll PROC USES eax ecx
    mov ecx, RENDER_BUFFER_LAYERS
    dec ecx
    xor eax, eax
IntegrateRenderBufferFinaleAll_AllLayers:
    INVOKE CoverRenderBufferLayer, eax, RENDER_BUFFER_LAYER_FINALE
    inc eax
    loop IntegrateRenderBufferFinaleAll_AllLayers

    ret
IntegrateRenderBufferFinaleAll ENDP

;; IntegrateRenderBufferFinaleAllDiscardable
IntegrateRenderBufferFinaleAllDiscardable PROC USES eax ecx
    mov ecx, RENDER_BUFFER_LAYERS
    dec ecx
    xor eax, eax
IntegrateRenderBufferFinaleAllDiscardable_AllLayers:
    INVOKE CoverRenderBufferLayerDiscardable, eax, RENDER_BUFFER_LAYER_FINALE
    inc eax
    loop IntegrateRenderBufferFinaleAllDiscardable_AllLayers

    ret
IntegrateRenderBufferFinaleAllDiscardable ENDP

;; Render
Render PROC USES eax ecx edx,
    layer:DWORD
    LOCAL outputCount:DWORD

    mGetRenderBufferLayerIndex edx, layer
    INVOKE WriteConsoleOutputCharacter,
        stdOutputHandle,
        ADDR stdRenderBuffer[edx].characters,
        SCREEN_BUFFER_WIDTH * SCREEN_BUFFER_HEIGHT,
        stdRenderOrigin,
        ADDR outputCount

    mGetRenderBufferLayerIndex edx, layer
    INVOKE WriteConsoleOutputAttribute,
        stdOutputHandle,
        ADDR stdRenderBuffer[edx].attributes,
        SCREEN_BUFFER_WIDTH * SCREEN_BUFFER_HEIGHT,
        stdRenderOrigin,
        ADDR outputCount

    ret
Render ENDP

;; RenderDiscardable
;; TODO: Improve?
RenderDiscardable PROC USES eax ebx ecx edx esi edi,
    layer:DWORD
    LOCAL outputCount:DWORD,
          renderStart:COORD

    cld
    mGetRenderBufferLayerIndex eax, layer
    mov ecx, SCREEN_BUFFER_WIDTH * SCREEN_BUFFER_HEIGHT
    lea esi, stdRenderBuffer[eax].characters
    lea edx, stdRenderBuffer[eax].attributes
    xor edi, edi
    xor ebx, ebx

RenderDiscardable_ScanAll:
    add esi, edi
    add ebx, edi
    shl edi, 1
    add edx, edi
    mov edi, esi

    mov al, RENDER_BUFFER_DISCARD
    repne scasb
    jnz RenderDiscardable_End
    dec edi
RenderDiscardable_End:
    sub edi, esi
    jz RenderDiscardable_Continued

    INVOKE GetRenderBufferCoord, bx, ADDR renderStart

    push ecx
    push edx
    INVOKE WriteConsoleOutputCharacter,
        stdOutputHandle,
        esi,
        edi,
        renderStart,
        ADDR outputCount
    pop edx

    push edx
    INVOKE WriteConsoleOutputAttribute,
        stdOutputHandle,
        edx,
        edi,
        renderStart,
        ADDR outputCount
    pop edx
    pop ecx

RenderDiscardable_Continued:
    inc edi
    inc ecx
    loop RenderDiscardable_ScanAll

    ret
RenderDiscardable ENDP
