TITLE Programming Assignment #4 (assn4.asm)

; Author: Alec Merdler
; Description:
;   Write a program to calculate composite numbers. First, the user is instructed to enter the number of composites
;   to be displayed, and is prompted to enter an integer in the range [1 .. 400]. The user enters a number, n, and
;   the program verifies that 1 <= n <= 400. If n is out of range, the user is re- prompted until s/he enters a value
;   in the specified range. The program then calculates and displays all of the composite numbers up to and including
;   the nth composite. The results should be displayed 10 composites per line with at least 3 spaces between the numbers.

INCLUDE Irvine32.inc

.data
welcomeMessage			   BYTE	  "Composites Numbers, programmed by Alec Merdler", 0
inputPrompt			       BYTE	  "Enter number of composites to display [1, 400]: ", 0
belowError				   BYTE   "The number you entered was too small. ", 0
aboveError				   BYTE   "The number you entered was too big. ", 0
spaces					   BYTE	  "   ", 0
farewellMessage			   BYTE	  "Farewell!", 0
number					   DWORD  ?
count					   DWORD  1
userNumber				   DWORD  ?
userNumberTemp			   DWORD  ?
innerLoopCount			   DWORD  ?
outerLoopCount			   DWORD  ?
underScore				   BYTE	  " _ ", 0
outerCompare			   DWORD  ?
innerCompare			   DWORD  ?
writeCount				   DWORD  0

LOWER_LIMIT = 1
UPPER_LIMIT = 400


.code
; ==============================================================================
;   Procedure: main
; Description: Calls other procedures to drive the program.
; ==============================================================================
main PROC
    call introduction
    call getUserData
    call showComposites
    call farewell
    exit
main ENDP


; ==============================================================================
;   Procedure: introduction
; Description:
; ==============================================================================
introduction PROC
    call    CrLf
    mov	    edx, OFFSET welcomeMessage
    call    WriteString
    call    CrLf
    ret
introduction ENDP


; ==============================================================================
;   Procedure: getUserData
; Description:
; ==============================================================================
getUserData PROC
    ; loop to allow user to continue entering negative numbers
    userNumberLoop:
    mov		edx, OFFSET inputPrompt
    call	WriteString
    mov		ecx, 0
    mov		eax, count
    add		eax, 1
    mov		count, eax
    call	CrLf
    call    ReadInt
    mov     userNumber, eax
    cmp		eax, LOWER_LIMIT
    jb		errorBelow
    cmp		eax, UPPER_LIMIT
    jg		errorAbove
    jmp		continue

    ; validation
    errorBelow:
    mov		edx, OFFSET belowError
    call	WriteString
    call	CrLf
    jmp		userNumberLoop

    errorAbove:
    mov		edx, OFFSET aboveError
    call	WriteString
    call	CrLf
    jmp		userNumberLoop

    continue:
    ; prep the loop
    mov		ecx, 4
    mov		userNumberTemp, ecx

    cmp		ecx, userNumber
    ja		farewell
    ret
getUserData ENDP


; ==============================================================================
;   Procedure: showComposites
; Description:
; ==============================================================================
showComposites PROC
    ; for inner loop
    mov		eax, userNumber
    sub		eax, 2
    mov		innerLoopCount, eax

    ; for outer loop
    mov		eax, userNumber
    sub		eax, 3
    mov		outerLoopCount, eax
    mov		ecx, outerLoopCount
    mov		eax, 4
    mov		outerCompare, eax

    ; reset inner loop after each complete inner loop cycle
    mov		eax, 2
    mov		innerCompare, eax
    call	CrLf

    outerLoop:
    skipCarry:
    mov		eax, 2
    mov		innerCompare, eax
    mov		eax, outerCompare
    push	ecx
    push	eax
    mov		ecx, innerLoopCount

    isComposite:
    mov		eax, outerCompare
    mov		edx, 0
    div		innerCompare
    cmp		edx, 0
    jne		skipPrint
    ; print out Composites
    mov		eax, outerCompare
    call	WriteDec
    mov		edx, OFFSET spaces
    call	WriteString
    mov		ebx, writeCount
    inc		ebx
    mov		writeCount, ebx
    cmp		ebx, 10
    jne		exitInnerLoop
    call	CrLf
    mov		writeCount,esi
    jmp		exitInnerLoop

    skipPrint:
    mov		ebx, innerCompare
    sub		eax, 1
    cmp		eax, ebx
    jae		skipIncrement
    add		eax, 1
    mov		innerCompare, eax
    skipIncrement:
    loop isComposite
    exitInnerLoop:

    pop		eax
    pop		ecx
    inc		eax
    mov		outerCompare, eax
    loop	outerLoop
    ret
showComposites ENDP


; ==============================================================================
;   Procedure: farewell
; Description: Prints farewell message.
; ==============================================================================
farewell PROC
    call	CrLf
    mov		edx, OFFSET farewellMessage
    call	WriteString
    call	CrLf
    call	CrLf
    exit
farewell ENDP

END main
