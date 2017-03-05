TITLE Programming Assignment #5 (assn5.asm)

; ====================================================================================================================
; Author: Alec Merdler
; Description:
;   Write and test a MASM program to perform the following tasks:
;   1. Introduce the program.
;   2. Get a user request in the range [min = 10 .. max = 200].
;   3. Generate request random integers in the range [lo = 100 .. hi = 999], storing them in consecutive elements
;      of an array.
;   4. Display the list of integers before sorting, 10 numbers per line.
;   5. Sort the list in descending order (i.e., largest first).
;   6. Calculate and display the median value, rounded to the nearest integer.
;   7. Display the sorted list, 10 numbers per line.
; ====================================================================================================================

INCLUDE Irvine32.inc

.data
MIN				=		 10
MAX				=		 200
LO				=		 100
HI				=		 999
MAX_SIZE		=		 200

welcomeMessage		       BYTE	  "Sorting Random Integers, programmed by Alec Merdler.", 0
descriptionMessage1        BYTE   "This program generates random numbers in the range [100 .. 999],", 0
descriptionMessage2        BYTE   "displays the original list, sorts the list, and calculates the", 0
descriptionMessage3        BYTE   "median value.  Finally, it displays the list sorted in descending order.", 0
inputPrompt			       BYTE	  "How many numbers should be generated? [10 .. 200]: ", 0
invalidLowMessage		   BYTE   "The number you entered was too small. ", 0
invalidHighMessage		   BYTE   "The number you entered was too big. ", 0
medianMessage			   BYTE	  "The median is: ",0
spaces					   BYTE	  "   ", 0
farewellMessage			   BYTE	  "Farewell!", 0
preSortMessage		       BYTE	  "The array before sorting: ", 0
postSortMessage			   BYTE	  "The array after sorting: ", 0
number					   DWORD  ?
request					   DWORD  ?
requestTemp			       DWORD  ?
list					   DWORD MAX_SIZE DUP(?)


.code
; ==============================================================================
;   Procedure: main
; Description: Calls other procedures to drive the program.
; ==============================================================================
main PROC
    call introduction

    push OFFSET request
    call getData

    ; Seed for generating random numbers
    call Randomize

    push OFFSET list
    push request
    call fillArray

    mov  edx, OFFSET preSortMessage
    call WriteString
    call CrLf
    push OFFSET list
    push request
    call displayList

    push OFFSET list
    push request
    call sortList

    call CrLf
    push OFFSET list
    push request
    call displayMedian


    call CrLf
    mov  edx, OFFSET postSortMessage
    call WriteString
    call CrLf
    push OFFSET list
    push request
    call displayList

    call farewell

    exit
main ENDP


; ====================================================================================================================
;         Procedure: introduction
;       Description: Prints welcome message and extra credit messages.
;          Receives: welcomeMessage is a global variable
;           Returns: nothing
;     Preconditions: welcome must be set to a string
; Registers Changed: edx
; ====================================================================================================================
introduction PROC
    call	 CrLf
    mov		 edx, OFFSET welcomeMessage
    call	 WriteString
    call	 CrLf

    ret
introduction ENDP


; ====================================================================================================================
;         Procedure: getData
;       Description: Get and validate an integer between 10 and 200 from the user.
;          Receives: inputPrompt is global variable. Receives OFFSET of request variable. MAX and MIN global constants.
;           Returns: Puts user's request integer into the request variable.
;     Preconditions: inputPrompt must be set to strings. Request must be declared as a DWORD
; Registers Changed: edx, eax,
; ====================================================================================================================
getData PROC
    ; Loop to allow user to continue entering numbers until within range of MIN and MAX
    push ebp
    mov	 ebp, esp
    mov	 ebx, [ebp + 8]

    getInput:
    mov     edx, OFFSET inputPrompt
    call	WriteString
    call    ReadInt
    ; Save the user's request into var request
    mov     [ebx], eax
    cmp		eax, MIN
    jb		invalidLow
    cmp		eax, MAX
    jg		invalidHigh
    jmp		continue

    invalidLow:
    mov		edx, OFFSET invalidLowMessage
    call	WriteString
    call	CrLf
    jmp		getInput

    invalidHigh:
    mov		edx, OFFSET invalidHighMessage
    call	WriteString
    call	CrLf
    jmp		getInput

    continue:
    pop ebp

    ; Clean up the stack by removing extra DWORD
    ret 4
getData ENDP


; ====================================================================================================================
;         Procedure: fillArray
;       Description: Fills an array with random numbers
;          Receives: list: @array
;                    request: number of array elements
;           Returns: nothing
;     Preconditions: request must be set to an integer between 10 and 200
; Registers Changed: eax, ecx, esi
; ====================================================================================================================
fillArray PROC
    push ebp
    mov  ebp, esp
    mov  esi, [ebp + 12]
    mov	 ecx, [ebp + 8]

    fillArrLoop:
    mov		eax, HI
    sub		eax, LO
    inc		eax
    ; Put random number in array
    call	RandomRange
    add		eax, LO
    mov		[esi], eax

    ; Proceed to next element
    add		esi, 4
    loop	fillArrLoop

    pop  ebp
    ret  8
fillArray ENDP


; ====================================================================================================================
;         Procedure: displayList
;       Description: Prints out values in list MIN numbers per row
;          Receives: list: @array
;                    request: number of array elements
;           Returns: nothing
;     Preconditions: request must be set to an integer between 10 and 200
; Registers Changed: eax, ecx, ebx, edx
; ====================================================================================================================
displayList PROC
    push ebp
    mov  ebp, esp
    mov	 ebx, 0
    mov  esi, [ebp + 12]
    mov	 ecx, [ebp + 8]

    displayLoop:
    ; Get current element
    mov		eax, [esi]
    call	WriteDec
    mov		edx, OFFSET spaces
    call	WriteString
    inc		ebx
    cmp		ebx, MIN
    jl		skipCarry
    call	CrLf
    mov		ebx,0

    ; Proceed to next element
    skipCarry:
    add		esi, 4
    loop	displayLoop

    endDisplayLoop:
    pop		ebp
    ret		8
displayList ENDP


; ====================================================================================================================
;         Procedure: sortList
;       Description: Prints out values in list
;          Receives: list: @array
;                    request: number of array elements
;           Returns: nothing
;     Preconditions: request must be set to an integer between 10 and 200
; Registers Changed: eax, ecx, ebx, edx
; ====================================================================================================================
sortList PROC
    push ebp
    mov  ebp, esp
    mov  esi, [ebp + 12]
    mov	 ecx, [ebp + 8]
    dec	 ecx

    ; Get current element and save outer loop counter
    outerLoop:
    mov		eax, [esi]
    mov		edx, esi
    push	ecx

    innerLoop:
    mov		ebx, [esi + 4]
    mov		eax, [edx]
    cmp		eax, ebx
    jge		skipSwitch
    add		esi, 4
    push	esi
    push	edx
    push	ecx
    call	exchange
    sub		esi, 4

    skipSwitch:
    add		esi,4

    loop	innerLoop

    ; Restore outer loop counter and reset esi
    skippit:
    pop		ecx
    mov		esi, edx

    ; Proceed to next element
    add		esi, 4
    loop	outerLoop

    endDisplayLoop:
    pop		ebp
    ret		8
sortList ENDP


; ====================================================================================================================
;         Procedure: exchange
;       Description: Prints out values in list
;          Receives: list: @array
;                    request: number of array elements
;           Returns: nothing
;     Preconditions: request must be set to an integer between 10 and 200
; Registers Changed: eax, ecx, ebx, edx
; ====================================================================================================================
exchange PROC
    push	ebp
    mov		ebp, esp
    pushad

    ; Address of second number
    mov		eax, [ebp + 16]
    ; Address of first number
    mov		ebx, [ebp + 12]
    mov		edx, eax
    ; Give edx the difference between the first and second number
    sub		edx, ebx

    mov		esi, ebx
    mov		ecx, [ebx]
    mov		eax, [eax]
    ; Put eax in array
    mov		[esi], eax
    add		esi, edx
    mov		[esi], ecx

    popad
    pop		ebp
    ret		12
exchange ENDP


; ====================================================================================================================
;         Procedure: displayMedian
;       Description: Fill an array with random numbers
;          Receives: list: @array
;                    request: number of array elements
;           Returns: nothing
;     Preconditions: request must be set to an integer between 10 and 200
; Registers Changed: eax,ebx, ecx, edx,
; ====================================================================================================================
displayMedian PROC
    push ebp
    mov  ebp, esp
    mov  esi, [ebp + 12]
    mov	 eax, [ebp + 8]

    ; Loop control based on request
    mov  edx, 0
    mov	 ebx, 2
    div	 ebx
    mov	 ecx, eax

    medianLoop:
    add		esi, 4
    loop	medianLoop

    ; Check for zero
    cmp		edx, 0
    jnz     isOdd

    isEven:
    mov		eax, [esi - 4]
    add		eax, [esi]
    mov		edx, 0
    mov		ebx, 2
    div		ebx
    mov		edx, OFFSET medianMessage
    call	WriteString
    call	WriteDec
    call	CrLf
    jmp		endDisplayMedian

    isOdd:
    mov		eax, [esi]
    mov		edx, OFFSET medianMessage
    call	WriteString
    call	WriteDec
    call	CrLf

    endDisplayMedian:
    pop  ebp
    ret  8
displayMedian ENDP


; ====================================================================================================================
;         Procedure: farewell
;       Description: Prints farewell message.
;          Receives: farewellMessage is a global variable.
;           Returns: nothing
;     Preconditions: farewellMessage must be set to string.
; Registers Changed: edx
; ====================================================================================================================
farewell PROC
    call	CrLf
    mov		edx, OFFSET farewellMessage
    call	WriteString
    call	CrLf
    call	CrLf

    exit
farewell ENDP

END main
