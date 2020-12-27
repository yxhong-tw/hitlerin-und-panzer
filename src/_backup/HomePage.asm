TITLE Example of ASM                (asmExample.ASM)

; This program locates the cursor and displays the
; system time. It uses two Win32 API structures.
; Last update: 6/30/2005

INCLUDE Irvine32.inc

; Redefine external symbols for convenience
; Redifinition is necessary for using stdcall in .model directive 
; using "start" is because for linking to WinDbg.  added by Huang
 
main          EQU start@0

.data
StartS BYTE "					        Press SPACE to start", 0
RuleS BYTE "					    Press R to see the game rule", 0
MemberS BYTE "					     Press M to see member list", 0
CloseRS BYTE "	   	Press X to close the game rule", 0
CloseMS BYTE "					     Press X to close member list", 0

;GameRule
GameRuleS1_1 BYTE "	   	- Player's Panzer", 0
GameRuleS1_2 BYTE "		  	- Have one panzer", 0
GameRuleS1_3 BYTE "		  	- Control the direction with ARROW KEYS", 0
GameRuleS1_4 BYTE "		   	- Fire a bullet with SPACE ( fire one per 2 seconds, accumulate three ones at most )", 0
GameRuleS1_5 BYTE "		   	- Have three lives", 0

GameRuleS2_1 BYTE "	   	- Enemy's Panzers",0 
GameRuleS2_2 BYTE "		   	- Have three panzers", 0
GameRuleS2_3 BYTE "		   	- Automatically move and fire through certain rules", 0
GameRuleS2_4 BYTE "		   	- Have one life", 0

GameRuleS3_1 BYTE "	   	- Victory Condition", 0
GameRuleS3_2 BYTE "		   	- Destroy all panzers of the enemy", 0

GameRuleS4_1 BYTE "	  	- Failure Condition", 0
GameRuleS4_2 BYTE "		   	- Run out of all three lives", 0

;MemberList
MemberListS1 BYTE "					     HONG, YU-XIANG", 0				; 洪裕翔
MemberListS2 BYTE "					     LIU, ZI-YONG", 0				; 劉子雍
MemberListS3 BYTE "					     PETER", 0						; 林緯翔
MemberListS4 BYTE "					     QIN, CHENG-YE", 0				; 秦承業

consoleHandle DWORD ?

.code
main PROC
	call Home
main ENDP

Home PROC USES eax edx
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE
	mov consoleHandle, eax
	call Clrscr
	call Crlf
	call Crlf
	call Crlf
	call Crlf
	call Crlf
	call Crlf
	call Crlf
	call Crlf
	call Crlf
	call Crlf
	call Crlf
	call Crlf
	call Crlf
	mov edx, OFFSET StartS
	call WriteString
	call Crlf
	call Crlf
	mov edx, OFFSET RuleS
	call WriteString
	call Crlf
	call Crlf
	mov edx, OFFSET MemberS
	call WriteString
	call Crlf
	call ReadChar
	.IF ax == 3920h							; SPACE
		call Main
	.ENDIF
	.IF ax == 1372h							; R
		call Rule
	.ENDIF
	.IF ax == 326Dh							; M
		call Member
	.ENDIF
	call Home
Home ENDP

Rule PROC USES eax edx
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE
	mov consoleHandle, eax
	call Clrscr
	call Crlf
	call Crlf
	call Crlf
	call Crlf
	call Crlf
	mov edx, OFFSET GameRuleS1_1
	call WriteString
	call Crlf
	mov edx, OFFSET GameRuleS1_2
	call WriteString
	call Crlf
	mov edx, OFFSET GameRuleS1_3
	call WriteString
	call Crlf
	mov edx, OFFSET GameRuleS1_4
	call WriteString
	call Crlf
	mov edx, OFFSET GameRuleS1_5
	call WriteString
	call Crlf
	call Crlf
	mov edx, OFFSET GameRuleS2_1
	call WriteString
	call Crlf
	mov edx, OFFSET GameRuleS2_2
	call WriteString
	call Crlf
	mov edx, OFFSET GameRuleS2_3
	call WriteString
	call Crlf
	mov edx, OFFSET GameRuleS2_4
	call WriteString
	call Crlf
	call Crlf
	mov edx, OFFSET GameRuleS3_1
	call WriteString
	call Crlf
	mov edx, OFFSET GameRuleS3_2
	call WriteString
	call Crlf
	call Crlf
	mov edx, OFFSET GameRuleS4_1
	call WriteString
	call Crlf
	mov edx, OFFSET GameRuleS4_2
	call WriteString
	call Crlf
	call Crlf
	mov edx, OFFSET CloseRS
	call WriteString
	call Crlf
	call ReadChar
	.IF ax == 2D78h							; X
		call Home
	.ENDIF
	call Rule
Rule ENDP

Member PROC USES eax edx
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE
	mov consoleHandle, eax
	call Clrscr
	call Crlf
	call Crlf
	call Crlf
	call Crlf
	call Crlf
	call Crlf
	call Crlf
	call Crlf
	call Crlf
	call Crlf
	mov edx, OFFSET MemberListS1
	call WriteString
	call Crlf
	call Crlf
	mov edx, OFFSET MemberListS2
	call WriteString
	call Crlf
	call Crlf
	mov edx, OFFSET MemberListS3
	call WriteString
	call Crlf
	call Crlf
	mov edx, OFFSET MemberListS4
	call WriteString
	call Crlf
	call Crlf
	mov edx, OFFSET CloseMS
	call WriteString
	call Crlf
	call ReadChar
	.IF ax == 2D78h							; X
		call Home
	.ENDIF
	call Member
Member ENDP

END main