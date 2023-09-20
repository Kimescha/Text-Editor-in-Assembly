extern printf
extern scanf
extern fflush

%ifndef SYS_EQUAL
%define SYS_EQUAL
    sys_read     equ     0
    sys_write    equ     1
    sys_open     equ     2
    sys_close    equ     3
    
    sys_lseek    equ     8
    sys_create   equ     85
    sys_unlink   equ     87
      

    sys_mmap     equ     9
    sys_mumap    equ     11
    sys_brk      equ     12
    
     
    sys_exit     equ     60
    
    stdin        equ     0
    stdout       equ     1
    stderr       equ     3

 
 
    PROT_READ     equ   0x1
    PROT_WRITE    equ   0x2
    MAP_PRIVATE   equ   0x2
    MAP_ANONYMOUS equ   0x20
    
    ;access mode
    O_DIRECTORY equ     0q0200000
    O_RDONLY    equ     0q000000
    O_WRONLY    equ     0q000001
    O_RDWR      equ     0q000002
    O_CREAT     equ     0q000100
    O_APPEND    equ     0q002000

    
; create permission mode
    sys_IRUSR     equ     0q400      ; user read permission
    sys_IWUSR     equ     0q200      ; user write permission

    NL            equ   0xA
    bufferlen     equ   1000
    Space         equ   0x20

%endif

;----------------------------------------------------
newLine:
   push   rax
   mov    rax, NL
   call   putc
   pop    rax
   ret
;---------------------------------------------------------
putc:	

   push   rcx
   push   rdx
   push   rsi
   push   rdi 
   push   r11 

   push   ax

   mov    rsi, rsp    ; points to our char
   mov    rdx, 1      ; how many characters to print
   mov    rax, sys_write
   mov    rdi, stdout 
   syscall

   pop    ax

   pop    r11
   pop    rdi
   pop    rsi
   pop    rdx
   pop    rcx
   ret
;---------------------------------------------------------
writeNum:
   push   rax
   push   rbx
   push   rcx
   push   rdx

   sub    rdx, rdx
   mov    rbx, 10 
   sub    rcx, rcx
   cmp    rax, 0
   jge    wAgain
   push   rax 
   mov    al, '-'
   call   putc
   pop    rax
   neg    rax  

wAgain:
   cmp    rax, 9	
   jle    cEnd
   div    rbx
   push   rdx
   inc    rcx
   sub    rdx, rdx
   jmp    wAgain

cEnd:
   add    al, 0x30
   call   putc
   dec    rcx
   jl     wEnd
   pop    rax
   jmp    cEnd
wEnd:
   pop    rdx
   pop    rcx
   pop    rbx
   pop    rax
   ret

;---------------------------------------------------------
getc:
   push   rcx
   push   rdx
   push   rsi
   push   rdi 
   push   r11 


   sub    rsp, 1

   mov    rsi, rsp
   mov    rdx, 1
   mov    rax, sys_read
   mov    rdi, stdin
   syscall

   mov    al, [rsi]
   add    rsp, 1

   pop    r11
   pop    rdi
   pop    rsi
   pop    rdx
   pop    rcx

   ret
;---------------------------------------------------------

readNum:
   push   rcx
   push   rbx
   push   rdx

   mov    bl,0
   mov    rdx, 0
rAgain:
   xor    rax, rax
   call   getc
   cmp    al, '-'
   jne    sAgain
   mov    bl,1  
   jmp    rAgain
sAgain:
   cmp    al, NL
   je     rEnd
   cmp    al, ' ' ;Space
   je     rEnd
   sub    rax, 0x30
   imul   rdx, 10
   add    rdx,  rax
   xor    rax, rax
   call   getc
   jmp    sAgain
rEnd:
   mov    rax, rdx 
   cmp    bl, 0
   je     sEnd
   neg    rax 
sEnd:  
   pop    rdx
   pop    rbx
   pop    rcx
   ret

;-------------------------------------------
printString:
    push    rax
    push    rcx
    push    rsi
    push    rdx
    push    rdi

    mov     rdi, rsi
    call    GetStrlen
    mov     rax, sys_write  
    mov     rdi, stdout
    syscall 
    
    pop     rdi
    pop     rdx
    pop     rsi
    pop     rcx
    pop     rax
    ret
;-------------------------------------------
; rsi : zero terminated string start 
GetStrlen:
    push    rbx
    push    rcx
    push    rax  

    xor     rcx, rcx
    not     rcx
    xor     rax, rax
    cld
    repne   scasb
    not     rcx
    lea     rdx, [rcx -1]  ; length in rdx

    pop     rax
    pop     rcx
    pop     rbx
    ret


writeNum_file:
   push   rbx
   push   rcx
   push   rdx

   sub    rdx, rdx
   mov    rbx, 10 
   sub    rcx, rcx
   cmp    rax, 0
   jge    wAgain_file
   push   rax 
   mov    al, '-'
   call   putc_file
   pop    rax
   neg    rax  

wAgain_file:
   cmp    rax, 9	
   jle    cEnd_file
   div    rbx
   push   rdx
   inc    rcx
   sub    rdx, rdx
   jmp    wAgain_file

cEnd_file:
   add    al, 0x30
   call   putc_file
   dec    rcx
   jl     wEnd_file
   pop    rax
   jmp    cEnd_file
wEnd_file:
   pop    rdx
   pop    rcx
   pop    rbx
   ret

putc_file:	

   push   rcx
   push   rdx
   push   rsi
   push   rdi 
   push   r11 

   push   ax
   mov rdi , [FDdes]
   mov rsi , rsp
   mov rdx  , 1
   call writeFile
   ; mov    rsi, rsp    ; points to our char
   ; mov    rdx, 1      ; how many characters to print
   ; mov    rax, sys_write
   ; mov    rdi, stdout 
   ; syscall

   pop    ax

   pop    r11
   pop    rdi
   pop    rsi
   pop    rdx
   pop    rcx
   ret
flush:
    push rdi
    xor rdi, rdi
    call fflush
    pop rdi
    ret
;-------------------------------------------
section .data
   FDdes dq 0
   address_message db 'Please enter file address:',10,0
   len_adrs_msg equ $ - address_message
   file_content_message db 'this is file content:' ,10,0
   number_L db 'number of lines:',0
   number_W db 'number of words:',0
   number_C db 'number of characters:',0
   starss db '****************',10,0
   user_interface_msg db '1-search a word',10,'2-search and replace',10,'3-append',10,'4-remove',10,'5-save',10,'6-save as',0
   user_input db 'enter a number:',0
   user_input_word db 'enter your word:',0
   word_places db 'starting character places are:' ,10,0
   number_of_words db 'number of the word is:',0
   position db 'enter position of starting character:',0
   replaced_word_msg db 'enter the string to be replaced:',0
   succesful_replaced_msg db 'sucessfully replaced',10,0
   append_msg db 'enter your string:',0
   append_successful_msg db 'succesfully appended',10,0
   remove_msg db 'enter numbers of characters:',0
   remove_successful_msg db 'succesfully removed',10,0
   save_success_msg db 'sucessfully saved',10,0
   save_as_destination_msg db 'enter destination:',0
section .bss
   file_address resb 300
   buffer resb bufferlen
   FD resb 100
   target_Word resb 300
   replaced_string resb 300
   append_string resb 300
   save_as_destination resb 300
   n resb 1
   starting_character resb 8
   number_of_character_in_file resb 8
   FDSAVEAS resb 100

section .text
    global main




;;;;;;;;;;;;;;;;;;;;;;;;;
createFile:
    mov     rax, sys_create
    mov     rsi, sys_IRUSR | sys_IWUSR 
    syscall
    cmp     rax, -1   
    jle     createerror
    ret
createerror:
    ret

writeFile:
    mov     rax, sys_write
    syscall
    cmp     rax, -1         
    jle     writeerror
    ret
writeerror:
    ret

openFile:
   mov rax , sys_open
   mov rsi , O_RDWR 
   syscall
   cmp rax , -1
   jle openerror
   ret
openerror:
   mov rax , 999
   ret

readFile:
   mov rax , sys_read
   syscall
   cmp rax , -1
   jle readerror
   mov byte[rsi+rax] , 0
   ret
readerror:
   ret

closefile:
   mov rax , sys_close
   syscall
   cmp rax , -1
   jle closeerror

   ret
closeerror:
   ret


read_replacing_string:
   mov r11 , replaced_string
   read_replc:
      call getc
      cmp rax , 10
      je read_replacing_word_ret
      mov byte[r11] ,al 
      inc r11
      jmp read_replc
   read_replacing_word_ret:
      ret

read_append_string:
   mov r11 , append_string
   jmp read_replc

read_save_as_destination:
   mov r11 , save_as_destination
   jmp read_replc

read_file_address:
   ;print prompt message
   mov ecx, address_message
   mov edx, len_adrs_msg
   mov ebx, 1
   mov eax, 4
   int 0x80
   ;change rbx
   mov rbx , file_address
   read_word:
      call getc
      cmp rax , 10
      je read_word_ret
      mov byte[rbx] ,al 
      inc rbx
      jmp read_word
   read_word_ret:
      ret


open_folder_handeler:
   mov rdi , file_address
   call openFile
   mov [FD], rax
   mov rdi, [FD]
   mov rsi, buffer
   mov rdx, bufferlen
   call readFile
   ;print stars
   mov rsi , file_content_message
   call printString
   mov rsi , starss
   call printString
   ; print file content
   mov rsi , buffer
   call printString
   mov rsi , starss
   call printString
   ret

count_WLC:
   xor rax , rax
   xor rcx , rcx
   xor rsi , rsi
   mov rbx , buffer
   call jump_over_spaces
counting_process:
   mov dil , byte[rbx]
   cmp dil , 0
   je print_and_return
   cmp dil , 10
   je one_line
   cmp dil , 32
   je one_space
   inc rbx
   inc rsi
   jmp counting_process
one_line:
   inc rax
   inc rbx
   call jump_over_spaces
   jmp counting_process

jump_over_spaces:
   mov dil , byte[rbx]
   cmp dil , 32
   je next_char
   ret
next_char:
   inc rbx
   jmp jump_over_spaces

one_space:
   inc rcx
   next_word:
      inc rbx
      mov dil , byte[rbx]
      cmp dil , 32
      je next_word
   jmp counting_process
print_and_return:
   push rsi
   mov rsi , number_L
   call printString
   call writeNum
   call newLine
   mov rsi , number_W
   call printString
   add rcx , rax
   mov rax , rcx
   call writeNum
   call newLine
   mov rsi , number_C
   call printString
   pop rsi
   mov [number_of_character_in_file] , rsi
   mov rax , rsi
   call writeNum
   call newLine
   ret

count_number_of_words:
   mov rsi , user_input_word
   call printString
   xor rbx , rbx
   mov rbx , target_Word
   read_target_word:
      call getc
      cmp rax , 10
      je continue_count_function
      mov byte[rbx] ,al 
      inc rbx
      jmp read_target_word
   continue_count_function:
   mov rsi , word_places
   call printString
   mov rsi , buffer
   mov rbx , target_Word  
   xor rcx , rcx
   xor r10 , r10

count_numbers_of_word_loop:
   mov al, byte [rsi]
   cmp al, 0
   je count_end
   cmp al, byte [rbx]
   jne count_continue
   mov rdi, rbx

   check_word_loop:
      inc rsi
      inc r10
      inc rdi
      cmp byte [rdi], 0
      je count_increment
      mov al, byte [rsi]
      cmp al, byte [rdi]
      jne count_continue
      cmp al, 0
      jne check_word_loop

   count_increment:
      inc rcx
      mov rax , r10
      push rdi
      mov rdi , target_Word
      call GetStrlen
      pop rdi
      dec rdx
      sub rax , rdx
      call writeNum
      call newLine
      dec rsi
      dec r10

   count_continue:
      inc rsi
      inc r10
      jmp count_numbers_of_word_loop

count_end:
   mov rsi , number_of_words
   call printString
   mov rax , rcx
   call writeNum
   call newLine
   mov [n], rcx
   ret

flush_target_world:
   mov rsi , target_Word
flush_process:
   mov al , byte[rsi]
   cmp al , 0
   jne next_character_flushing
   ret
next_character_flushing:
   mov byte[rsi] , 0
   inc rsi
   jmp flush_process

flush_replaced_string:
   mov rsi , replaced_string
   jmp flush_process

flush_append_String:
   mov rsi , append_string
   jmp  flush_process
flush_save_as_destination:
   mov rsi , save_as_destination
   jmp flush_process

only_search:
   call count_number_of_words
   call flush_target_world
   jmp second_part


search_and_replace:
   call count_number_of_words
   mov rax , [n]
   cmp rax , 0
   je no_word_to_be_replaced
   mov rsi , position
   call printString
   call readNum
   mov [starting_character] , rax
   push rax
   mov rsi , replaced_word_msg
   call printString
   pop rax
   call shifting_function
   jmp second_part
no_word_to_be_replaced:
   jmp second_part

shifting_function:
   call read_replacing_string
   mov rdi , replaced_string
   call GetStrlen
   mov r11 , rdx ; r11 = len replaced string
   mov rdi , target_Word   
   call GetStrlen
   mov r12 , rdx ; r12 = len target word
   cmp r11 , r12
   jg shift_right 
   cmp r11 , r12
   je put_new_word_setter
   cmp r11 , r12
   jl shift_left
   
shift_right:
   sub r11 , r12
   mov rdi , buffer
   call GetStrlen
   mov r13 , rdx ; buffer len
   mov rsi , buffer
   add rsi , r13
   mov rdx , [starting_character]
   add rdx , r12
   dec rdx
   mov rcx , r13
shift_right_handeler:
   cmp rcx , rdx
   jl put_new_word_setter
   mov al , byte[rsi]
   add rsi , r11
   mov byte[rsi] , al
   sub rsi , r11
   dec rsi
   dec rcx
   jmp shift_right_handeler

shift_left:
   sub r12 , r11
   mov rdi , buffer
   call GetStrlen
   mov r13 , rdx ; buffer len
   mov rsi , buffer
   add rsi , [starting_character]
   dec rsi
   add rsi , r11
   dec rsi
   mov rdx , r13
   dec rdx
   mov rcx , [starting_character]
   add rcx , r11
   dec rcx
shift_left_handler:
   cmp rcx , rdx
   jg put_new_word_setter
   mov al , byte[rsi]
   sub rsi , r12
   mov byte[rsi] , al
   add rsi , r12
   inc rsi
   inc rcx
   jmp shift_left_handler

put_new_word_setter:
   mov rsi , buffer
   mov rdi , replaced_string
   add rsi , [starting_character]
   dec rsi

put_new_word_handler:
   cmp byte[rdi] , 0
   je sucessful_replaced_msg
   mov al , byte[rdi]
   mov byte[rsi] , al
   inc rdi
   inc rsi
   jmp put_new_word_handler 

sucessful_replaced_msg:
   call newLine
   mov rsi , buffer
   call printString
   call newLine
   mov rsi , succesful_replaced_msg
   call printString
   call flush_target_world
   call flush_replaced_string
   jmp second_part
   

print_user_interface:
   mov rsi , starss
   call printString
   mov rsi , user_interface_msg
   call printString
   call newLine
   mov rsi , user_input
   call printString
   ret

append_function:
   mov rsi , append_msg
   call printString
   call read_append_string
   mov rdi , buffer
   call GetStrlen
   mov rsi , buffer
   add rsi , rdx
   mov rcx , append_string
append_operator:
   cmp byte[rcx] , 0
   je append_return
   mov al , byte[rcx]
   mov byte[rsi] , al
   inc rcx
   inc rsi
   jmp append_operator
append_return:
   mov rsi , buffer
   call printString
   call newLine
   mov rsi , append_successful_msg
   call printString
   call flush_append_String
   jmp second_part
remove_function:
   mov rsi , remove_msg
   call printString
   call readNum
   mov rsi , buffer
   mov rdi , buffer
   call GetStrlen
   add rsi , rdx
   dec rsi
remove_operator:
   cmp rax , 0
   je remove_return
   cmp rdx , 0
   je remove_return
   cmp byte[rsi], 10
   je go_left
   mov byte[rsi],0
   dec rsi
   dec rax
   dec rdx
   jmp remove_operator

go_left:
   dec rsi
   jmp remove_operator
remove_return:
   mov rsi , buffer
   call printString
   call newLine
   mov rsi , remove_successful_msg
   call printString
   jmp second_part
   
save_to_file:
   mov rax , 8
   mov rdi , [FD]
   mov rsi , 0
   mov rdx , 0
   syscall
   mov rdi , buffer
   call GetStrlen
   mov rdi , [FD]
   mov rsi , buffer
   call writeFile
   mov rsi , save_success_msg
   call printString
   jmp second_part

save_as:
   mov rsi , save_as_destination_msg
   call printString
   call newLine
   call read_save_as_destination
   mov rdi , save_as_destination
   call openFile
   cmp rax , 999
   je save_as_file
   mov rax , 87
   mov rdi , save_as_destination
   syscall
save_as_file:
   mov rdi , save_as_destination
   call createFile
   mov [FDSAVEAS], rax
   mov rdi , buffer
   call GetStrlen
   mov rdi , [FDSAVEAS]
   mov rsi , buffer
   call writeFile
   mov rsi , save_success_msg
   call printString
   call flush_save_as_destination
   mov rdi , [FDdes]
   call closefile
   jmp second_part 

;cursor_editing:

main:
   xor rbx , rbx ; this is where file address is holding
   call read_file_address
first_part:
   call open_folder_handeler
   call count_WLC
second_part:
   call print_user_interface
   call readNum
   cmp rax , 1
   je only_search
   cmp rax , 2
   je search_and_replace
   cmp rax , 3
   je append_function
   cmp rax , 4
   je remove_function
   cmp rax , 5
   je save_to_file
   cmp rax , 6
   je save_as
   ;cmp rax , 7
   ;je cursor_editing


end:

   mov rax , 60
   mov rdi , 0
   syscall









